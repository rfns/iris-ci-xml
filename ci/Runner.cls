Include ci

Class CI.Runner
{

ClassMethod Run(configuration As CI.Configuration) As %Status
{
  new $namespace

  set environmentNS = configuration.GetEnv("CI_NAMESPACE")
  set $namespace = $get(environmentNS, $namespace)

  set name = ..ResolveApplicationName(configuration)
  set stagingWorkspace = ..ResolveStagingWorkspace(name)

  do ..ConfigurePort(configuration, .name, .logLevel, .xmlCharset, .xmlSpec)

  $$$QuitOnError(..PopulateWorkspace(stagingWorkspace))
  $$$QuitOnError(..ImportWorkspace(stagingWorkspace, logLevel))
  return ..ExportToXML(stagingWorkspace)

  return $$$OK
}

ClassMethod ResolveApplicationName(configuration As CI.Configuration) As %String [ Private ]
{
  set name = configuration.GetEnv("PORT_CONFIGURATION_PROJECTNAME")
  if name = "" set name = "app"
  return name
}

ClassMethod ResolveStagingWorkspace(name) As %Status [ Private ]
{
  return "/opt/ci/.staging/"_name
}

ClassMethod ExportToXML(stagingWorkspace As %String) As %Status
{
  set name = $piece(stagingWorkspace, "/", *)
  set path = "/opt/ci/app/"_name_".xml"

  write "Runner: Exporting project to XML ..."
  set project = ##class(%Studio.Project).%OpenId(name)
  $$$QuitOnError(project.Export(path, "/nodisplay"))
  write " done."

  do ..DisplayXMLGenerationNotice(name)
  return $$$OK
}

ClassMethod DisplayXMLGenerationNotice(name As %String) [ Private ]
{
  write !!, $$$BOLDDEFAULT("A XML file has been generated with the name "_name_".xml.")
}

ClassMethod PopulateWorkspace(workspace As %String) As %Status [ Private ]
{
  write "Runner: Creating workspace "_workspace_" and populating with sources from /opt/ci/app ..."

  if '##class(%File).CopyDir("/opt/ci/app", workspace) && (%objlasterror '= "") {
    return $$$ERROR($$$GeneralError, "Failed to duplicate sources to staging workspace. Received the the following error: "_$System.Status.GetErrorText(%objlasterror))
  }
  write " done.", !

  return $$$OK
}

ClassMethod ImportWorkspace(workspace As %String, logLevel As %Integer = 2) As %Status [ Private ]
{
  write "Runner: Starting Port", !!
  $$$QuitOnError(##class(Port.Project.Manager).Import(workspace, logLevel, 0, 1))
  write !
  return $$$OK
}

ClassMethod ConfigurePort(configuration As CI.Configuration, Output projectName As %String = "app", Output logLevel As %Integer = 2, Output xlmCharset As %String = "UTF8", Output xmlSpec As %String = "")
{
  do ##class(Port.Configuration).SetPrimaryWorkspace("/opt/ci/staging/{PROJECT}")

  do ConfigureIOCharset("PORT_CONFIGURATION_INTERNAL_CHARSET")
  do ConfigureIOCharset("PORT_CONFIGURATION_EXTERNAL_CHARSET")

  set logLevel = configuration.GetEnv("PORT_CONFIGURATION_LOGLEVEL")
  if logLevel = "" set logLevel = 2

ConfigureIOCharset(name)
  set env = configuration.GetEnv(name)
  if env '= "" {
    set configs = $listfromstring(configuration.GetEnv(name), ";")
    for i=1:1:$listlength(configs) {
      set extension = $$$ucase($piece($listget(configs, i),  ":", 1))
      set charset = $$$ucase($piece($listget(configs, i),  ":", 2))

      if name [ "EXTERNAL" { do ##class(Port.Configuration).SetExternalCharset(extension, charset) }
      elseif name [ "INTERNAL" { do ##class(Port.Configuration).SetInternalCharset(extension, charset) }
    }
  }
  quit
}

ClassMethod OnAfterRun(configuration As CI.Configuration) As %Status
{
  return $$$OK
}

}
