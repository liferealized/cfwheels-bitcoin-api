<cfcomponent output="false">

  <cffunction name="init" access="public" output="false">
    <cfscript>
      this.version = "1.1.8"; 
    </cfscript>
    <cfreturn this />
  </cffunction>

  <!--- address validation --->

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

  <!--- formatting helpers --->

  <cffunction name="formatSatoshi" access="public" output="false" returntype="string">
    <cfargument name="satoshi" type="any" required="true" />
    <cfargument name="addLabel" type="boolean" required="false" default="true" />
    <cfscript>
      arguments.satoshi = (not len(arguments.satoshi) or not isNumeric(arguments.satoshi)) ? 0 : arguments.satoshi;
      arguments.satoshi = numberFormat(arguments.satoshi / 100000000, ".99999999");

      if (arguments.addLabel)
        arguments.satoshi &= " BTC";
    </cfscript>
    <cfreturn arguments.satoshi />
  </cffunction>

  <cffunction name="formatMhs" access="public" output="false" returntype="string">
    <cfargument name="mhs" type="numeric" required="true" />
    <cfargument name="phsFormat" type="string" required="false" default="Ph/s" />
    <cfargument name="thsFormat" type="string" required="false" default="Th/s" />
    <cfargument name="ghsFormat" type="string" required="false" default="Gh/s" />
    <cfargument name="mhsFormat" type="string" required="false" default="Mh/s" />
    <cfscript>
      if (arguments.mhs / 1000000000 gte 1)
        return decimalFormat(arguments.mhs / 1000000000) & arguments.phsFormat;
      else if (arguments.mhs / 1000000 gte 1)
        return decimalFormat(arguments.mhs / 1000000) & arguments.thsFormat;
      else if (arguments.mhs / 1000 gte 1)
        return decimalFormat(arguments.mhs / 1000) & arguments.ghsFormat;
    </cfscript>
    <cfreturn decimalFormat(arguments.mhs) & arguments.mhsFormat />
  </cffunction>

  <cffunction name="calculateHashRate" access="public" output="false" returntype="numeric">
    <cfargument name="shares" type="numeric" required="true" />
    <cfargument name="seconds" type="numeric" required="true" />
    <cfreturn int(int(arguments.shares) * 2^32) / (int(arguments.seconds) * 1000 * 1000) />
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