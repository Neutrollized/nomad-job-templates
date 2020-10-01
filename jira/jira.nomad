job "jira" {
  datacenters = ["${DC_NAME}"]
  type = "service"

  group "jira" {
    count = 1

    update {
      max_parallel = 1
    }

    task "jira" {
      driver = "docker"

      artifact {
        source = "https://raw.githubusercontent.com/Neutrollized/nomad-job-templates/master/jira/configs/web.xml"
        destination = "local"
      }


      # https://community.atlassian.com/t5/Jira-Software-discussions/Jira-behind-AWS-ELB-with-SSL-offloading-and-http-https-redirect/td-p/653816
      template {
        destination = "local/server.xml.j2"
        data = <<EOH
<?xml version="1.0" encoding="utf-8"?>

<Server port="8005"
        shutdown="SHUTDOWN">

  <Listener className="org.apache.catalina.startup.VersionLoggerListener"/>
  <Listener className="org.apache.catalina.core.AprLifecycleListener"
            SSLEngine="on"/>
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener"/>
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener"/>
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener"/>

  <Service name="Catalina">

    <Connector port="8080"
               maxThreads="100"
               minSpareThreads="10"
               connectionTimeout="20000"
               enableLookups="false"
               protocol="HTTP/1.1"
               redirectPort="443"
               acceptCount="10"
               secure="true"
               scheme="http"
               proxyName=""
               proxyPort=""

               relaxedPathChars="[]|"
               relaxedQueryChars="[]|{}^\`&quot;&lt;&gt;"
               bindOnInit="false"
               maxHttpHeaderSize="8192"
               disableUploadTimeout="true" />

               URIEncoding="UTF-8"
               protocol="org.apache.coyote.http11.Http11NioProtocol"
               proxyName="${URL}"
               proxyPort="443"
               scheme="https"

    <Engine name="Catalina"
            defaultHost="localhost">

      <Host name="localhost"
            appBase="webapps"
            unpackWARs="true"
            autoDeploy="true">

        <Context path=""
                 docBase="${catalina.home}/atlassian-jira"
                 reloadable="false"
                 useHttpOnly="true">
          <Resource name="UserTransaction"
                    auth="Container"
                    type="javax.transaction.UserTransaction"
                    factory="org.objectweb.jotm.UserTransactionFactory"
                    jotm.timeout="60"/>
          <Manager pathname=""/>
          <JarScanner scanManifest="false"/>
          <Valve className="org.apache.catalina.valves.StuckThreadDetectionValve"
                 threshold="120" />
        </Context>

        <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="x-forwarded-for" protocolHeader="x-forwarded-proto" protocolHeaderHttpsValue="https" />
      </Host>
      <Valve className="org.apache.catalina.valves.AccessLogValve"
             pattern="%a %{jira.request.id}r %{jira.request.username}r %t &quot;%m %U%q %H&quot; %s %b %D &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot; &quot;%{jira.request.assession.id}r&quot;"/>
    </Engine>

  </Service>
</Server>
EOH
      }

      config {
        image = "atlassian/jira-software:8.5.4"

        port_map {
          http = 8080
        }
        port_map {
          https = 443
        }

        # https://community.atlassian.com/t5/Jira-questions/How-to-use-a-custom-server-xml-on-Jira-Docker-image/qaq-p/1166929
        volumes = [
          "local/server.xml.j2:/opt/atlassian/etc/server.xml.j2",
          "local/web.xml:/opt/atlassian/jira/atlassian-jira/WEB-INF/web.xml"
        ]
      }

      resources {
        cpu = 500
        memory = 2048
        network {
          port "http" {}
          port "https" {}
        }
      }

      service {
        name = "jira"
        tags = ["jira", "8.5.4", "urlprefix-${URL}"]
        port = "http"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

    }
  }
}
