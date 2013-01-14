<cfcomponent output="false">

  <cffunction name="init" access="public" output="false">
    <cfscript>
      this.version = "1.1.8"; 
    </cfscript>
    <cfreturn this />
  </cffunction>

  <cffunction name="validateBitcoinAddress" access="public" output="false" returntype="boolean">
    <cfargument name="address" type="string" required="true" />
    <cfscript>
      var loc = {};

      loc.javaloader = _createBitcoinApiJavaLoader();

      // get the address object
      loc.network = loc.javaloader.create("com.bccapi.bitlib.model.NetworkParameters").productionNetwork;
      loc.address = loc.javaloader.create("com.bccapi.bitlib.model.Address").fromString(arguments.address, loc.network);

      if (!structKeyExists(loc, "address"))
        return false;
    </cfscript>
    <cfreturn loc.address.isValidAddress(loc.network) />
  </cffunction>

  <cffunction name="_createBitcoinApiJavaLoader" access="public" output="false" returntype="any">
    <cfscript>
      var loc = {};
      
      if (!StructKeyExists(server, "javaloader") || !IsStruct(server.javaloader))
        server.javaloader = {};
      
      if (StructKeyExists(server.javaloader, "bitcoinapi"))
        return server.javaloader.bitcoinapi;
      
      loc.relativePluginPath = application.wheels.webPath & application.wheels.pluginPath & "/bitcoinapi/";
      loc.classPath = Replace(Replace(loc.relativePluginPath, "/", ".", "all") & "javaloader", ".", "", "one");
      
      loc.paths = ArrayNew(1);
      loc.paths[1] = ExpandPath(loc.relativePluginPath & "lib/bccapi.jar");
      
      // set the javaLoader to the request in case we use it again
      server.javaloader.bitcoinapi = $createObjectFromRoot(path=loc.classPath, fileName="JavaLoader", method="init", loadPaths=loc.paths, loadColdFusionClassPath=false);
    </cfscript>
    <cfreturn server.javaloader.bitcoinapi />
  </cffunction>
  
</cfcomponent>