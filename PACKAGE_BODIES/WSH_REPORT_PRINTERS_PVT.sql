--------------------------------------------------------
--  DDL for Package Body WSH_REPORT_PRINTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_REPORT_PRINTERS_PVT" AS
/* $Header: WSHRPRNB.pls 120.2.12010000.2 2008/08/22 09:15:36 sankarun ship $ */


   -- Constant
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_REPORT_PRINTERS_PVT';


   -- FORWARD DECLARATIONS
   -- Removed p_label_id parameter for Bug 2996792.
   PROCEDURE Select_Printer(	p_concurrent_program_id IN NUMBER,
				p_organization_id       IN NUMBER,
				p_level_type_id         IN NUMBER,
				p_level_value_id        IN VARCHAR2,
				p_equipment_instance    IN VARCHAR2,
				x_printer               OUT NOCOPY  VARCHAR2);

   --
   -- Name
   --   PROCEDURE Get_Printer
   --
   -- Purpose
   --   Depending upon the set of parameters passed, this procedure tries to
   --   get the most appropriate printer.
   --
   -- Input Parameters
   --   p_concurrent_program_id => document id
   --   p_organization_id => Organization Id
   --   p_equipment_type  => Equipment Type (currently items which have the equipment attribute turned on)
   --   p_equipment_instance  => An instance of Equipment Type. Serial Number of the equipment.
   --   p_label_id        => Label Id
   --   p_user_id 	      => user_id
   --   p_zone 	      => Warehouse zone (currently subinventory)
   --   p_department      => Department (currently BOM departments)
   --   p_responsibility  => Responsibility_Id
   --   p_application_id  => Application_Id
   --   p_site            => Site_Id  -- This is really not necessary.
							   -- We will not remove it for dependency reasons

   -- Output Parameters
   --   x_printer       => Printer Name
   --   x_api_status    => FND_API.G_RET_STS_SUCESSS or
   --                      FND_API.G_RET_STS_ERROR or
   --                      FND_API.G_RET_STS_UNEXP_ERROR
   --   x_error_message => Error message
   --

   PROCEDURE Get_Printer (
	p_concurrent_program_id  IN 	NUMBER,
	p_organization_id		IN   NUMBER  	default NULL,
	p_equipment_type_id 	IN 	NUMBER  	default NULL,
	p_equipment_instance     IN   VARCHAR2 	default NULL,
	p_label_id			IN	NUMBER    default NULL,
	p_user_id 	     	IN 	NUMBER  	default NULL,
	p_zone 	          	IN 	VARCHAR2 	default NULL,
	p_department_id 	     IN 	NUMBER  	default NULL,
	p_responsibility_id 	IN 	NUMBER  	default NULL,
	p_application_id 	     IN 	NUMBER  	default NULL,
	p_site_id 	          IN 	NUMBER  	default NULL,  /* this parameter is really not necessary */
        p_format_id               IN    NUMBER default NULL,
	x_printer		          OUT NOCOPY   VARCHAR2,
	x_api_status       	     OUT NOCOPY   VARCHAR2,
	x_error_message    	     OUT NOCOPY   VARCHAR2
   ) IS
	 counter  number := 0;
	 null_program_id  		EXCEPTION;
	 null_levels  			EXCEPTION;
	 null_equipment_type	EXCEPTION;
	 null_equipment_instance	EXCEPTION;
	 null_organization_id	EXCEPTION;
	 printer_not_found		EXCEPTION;
	 l_organization_id		NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PRINTER';
--
   BEGIN


	-- Concurrent Program Id should not null. Check this condition first.
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_CONCURRENT_PROGRAM_ID',P_CONCURRENT_PROGRAM_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EQUIPMENT_TYPE_ID',P_EQUIPMENT_TYPE_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EQUIPMENT_INSTANCE',P_EQUIPMENT_INSTANCE);
	    WSH_DEBUG_SV.log(l_module_name,'P_USER_ID',P_USER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_ZONE',P_ZONE);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEPARTMENT_ID',P_DEPARTMENT_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_RESPONSIBILITY_ID',P_RESPONSIBILITY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SITE_ID',P_SITE_ID);
	END IF;
	--
	if (p_concurrent_program_id is null )
	then
	    RAISE null_program_id;
	end if;


	-- Now, check the Level parameters. If all are null, throw error.
        -- Removed P_Label_Id from IF condition for Bug 2996792.
	if (p_equipment_type_id is null AND
	    p_equipment_instance is null AND
	    p_user_id is null AND
	    p_zone is null AND
	    p_department_id is null AND
	    p_responsibility_id is null AND
	    p_application_id is null AND
            p_format_id is null )
	then
	    RAISE null_levels;
	end if;

	-- Check for equipment type and equipment instance
	if (p_equipment_type_id is null and p_equipment_instance is null) then
	   null;  -- no problem..
     elsif (p_equipment_type_id is not null and p_equipment_instance is null) then
	    RAISE null_equipment_instance;
     elsif (p_equipment_type_id is null and p_equipment_instance is not null) then
	    RAISE null_equipment_type;
	end if;

	-- For equipment type and zone, organization_id is a must.
	if (p_equipment_type_id is not null or p_zone is not null) and
	   (p_organization_id is null)
	then
	    RAISE null_organization_id;
	end if;

	/* sbhaskar 08/21/00 */
	-- Organiation_Id is not necessary to look at if equipment id and zone are not passed.
	-- We have to do this way since p_organization_id is IN variable and cannot be changed.
--	if (p_organization_id is not null and (p_equipment_type_id is null AND p_zone is null) )  then
--		l_organization_id := null;
  --   else
--		l_organization_id := p_organization_id;
--	end if;

        l_organization_id := p_organization_id;  -- Bug 3534965(3510460 Frontport)

	-- Now, Populate pl/sql table so that we can do the SELECT in a loop.
        /* Bug 7341536 --Increased the Iteration of the for loop from 8 to 9 as there* are 9 Level
                       -- This is regression due to fix done in RFID project done in R12 in
		          version 115.13 (No Bug no specified) */
	for i in 1..9  -- hardcoded 8 since we have 8 levels. 8th value added for Bug 3534965(3510460 Frontport)
	loop

	   level_table(i).priority_seq := i; -- priority seq is not used. Populating it anyway..

	   if (i=1) then
	       level_table(i).level_type_id  := 10007;   -- Equipment Type
		  level_table(i).level_value_id := p_equipment_type_id;
	   elsif (i=2) then
	       level_table(i).level_type_id := 10009;   -- Format
		  level_table(i).level_value_id := p_format_id;
	   elsif (i=3) then
	       level_table(i).level_type_id := 10004;   -- User
		  level_table(i).level_value_id := p_user_id;
	   elsif (i=4) then
	       level_table(i).level_type_id := 10006;   -- Zone
		  level_table(i).level_value_id := p_zone;
	   elsif (i=5) then
	       level_table(i).level_type_id := 10005;   -- Department
		  level_table(i).level_value_id := p_department_id;
	   elsif (i=6) then
	       level_table(i).level_type_id := 10003;   -- Responsibility
		  level_table(i).level_value_id := p_responsibility_id;
	   elsif (i=7) then
	       level_table(i).level_type_id := 10002;   -- Application
		  level_table(i).level_value_id := p_application_id;
	   elsif (i=8) then
	       level_table(i).level_type_id := 10001;   -- Site
		  level_table(i).level_value_id := 0; 	   -- Since this will always be 0 for site.
	   elsif (i=9) then
	       level_table(i).level_type_id := 10008;   -- Organization_id  for Bug 3534965(3510460 Frontport)
		  level_table(i).level_value_id := p_organization_id ;
	   end if;


	end loop;


    /* Check for default printers using the following precedence :

	  Equipment Instance
	  User
	  Zone
	  Department
	  Responsibility
	  Application
	  Site

     */


	-- Call Select_Printer in a loop starting with equipment instance.
	-- If you find a printer, just return. Otherwise, continue with the next
	-- level and so on until you find an appropriate printer.


	for i in 1..level_table.count
	loop
	  if ( level_table(i).level_value_id is not null ) then
	    -- Pass l_organization_id instead of p_organization_id since it gets manipulated above.
            -- Removed Label_Id parameter for Bug 2996792.
	    Select_Printer( p_concurrent_program_id, l_organization_id, level_table(i).level_type_id,
			    level_table(i).level_value_id,  p_equipment_instance, x_printer);
	    if x_printer is not null then   -- was able to get a printer
	      x_api_status := FND_API.G_RET_STS_SUCCESS;
           x_error_message := null;
	      --
	      -- Debug Statements
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.pop(l_module_name);
	      END IF;
	      --
	      RETURN;
	    end if;
 	  end if;
	end loop;


	/** sbhaskar 09/13/00  */
	-- If it falls here, it will mean that we were not able to fetch the default printer.
	-- Could be because label_id or equipment_instance did not match with the levels.
	-- If that is the case, we will just check at the site level.

	-- Warning : We could end up having multiple records if label_id condition is not included.
	-- Therefore, we will include the condition of "label_id is null" in the following select.
	-- Similarly, with equipment_instance.
	-- For safety, include rownum=1.

  --Bug fix 2726195 replaced table name with view wsh_report_printers_v

	if (p_equipment_instance is not null ) then
	  begin
                -- Removed Label_Id from Query for Bug 2996792.
		select printer_name
		into   x_printer
		from   wsh_report_printers_v
		where  nvl(default_printer_flag,'N') = 'Y'
		and    enabled_flag = 'Y'
		and    concurrent_program_id = p_concurrent_program_id
		and    level_type_id = 10001   -- site level
		and    level_value_id = 0 	 -- site value
		and    (equipment_instance is null and p_equipment_instance is not null)
		and    rownum = 1; -- make sure we get only 1 row.

	     if x_printer is not null then   -- was able to get a printer
	       x_api_status := FND_API.G_RET_STS_SUCCESS;
            x_error_message := null;
	       --
	       -- Debug Statements
	       --
	       IF l_debug_on THEN
	           WSH_DEBUG_SV.pop(l_module_name);
	       END IF;
	       --
	       RETURN;
	     end if;
       exception
		when no_data_found then
			null;  -- if the above query returns no data found, just do nothing.
	  end;
	end if;

	-- If it falls here, it will mean that we were not able to fetch the default printer.
	-- Set the error flags.

     RAISE printer_not_found;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	RETURN;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	    when NULL_PROGRAM_ID then
		x_api_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NULL_PROGID');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NULL_PROGRAM_ID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_PROGRAM_ID');
END IF;
--
	    when NULL_LEVELS then
		x_api_status := FND_API.G_RET_STS_ERROR;
	     FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NULL_LEVEL');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NULL_LEVELS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_LEVELS');
END IF;
--
	    when NULL_EQUIPMENT_INSTANCE then
		x_api_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NULL_EQINST');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NULL_EQUIPMENT_INSTANCE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_EQUIPMENT_INSTANCE');
END IF;
--
	    when NULL_EQUIPMENT_TYPE then
		x_api_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NULL_EQUIP');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NULL_EQUIPMENT_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_EQUIPMENT_TYPE');
END IF;
--
	    when NULL_organization_id then
		x_api_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NULL_ORG');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'NULL_ORGANIZATION_ID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NULL_ORGANIZATION_ID');
END IF;
--
	    when PRINTER_NOT_FOUND then
		x_api_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_DEFPRT_NOTFOUND');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'PRINTER_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:PRINTER_NOT_FOUND');
END IF;
--
	    when OTHERS then
		x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.Set_Name('WSH', 'WSH_UNEXP_ERROR');
	     FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
	     FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
          FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
		x_error_message := fnd_message.get;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
   END Get_Printer;


   --
   -- 07/27/00 : Added label_id and equipment_instance parameters.
   --

   -- Removed Parameter p_label_id for Bug 2996792.
   PROCEDURE Select_Printer(  p_concurrent_program_id IN NUMBER,
						p_organization_id       IN NUMBER,
						p_level_type_id         IN NUMBER,
						p_level_value_id        IN VARCHAR2,
						p_equipment_instance    IN VARCHAR2,
						x_printer               OUT NOCOPY  VARCHAR2) is
--
--Bug fix 2726195 replaced table name with view wsh_report_printers_v
--
          cursor printer is
		select printer_name
		from   wsh_report_printers_v
		where  nvl(default_printer_flag,'N') = 'Y'
		and    enabled_flag = 'Y'
		and    concurrent_program_id = p_concurrent_program_id
		and    level_type_id = p_level_type_id
		and    nvl(equipment_instance,'NOTHING') = nvl(p_equipment_instance, 'NOTHING')
		and    decode(level_type_id, 10006, subinventory, level_value_id) = p_level_value_id
                -- consider organization_id only for Zone or Equipment type only. Bugfix 3980388
                and    decode(level_type_id, 10006, nvl(organization_id,-9),
                                             10007, nvl(organization_id,-9),
                                             nvl(p_organization_id,-9)) = nvl(p_organization_id,-9);



--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SELECT_PRINTER';
--
   BEGIN
		--
		-- Debug Statements
		--
		--
		l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
		--
		IF l_debug_on IS NULL
		THEN
		    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
		END IF;
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.push(l_module_name);
		    --
		    WSH_DEBUG_SV.log(l_module_name,'P_CONCURRENT_PROGRAM_ID',P_CONCURRENT_PROGRAM_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_LEVEL_TYPE_ID',P_LEVEL_TYPE_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_LEVEL_VALUE_ID',P_LEVEL_VALUE_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_EQUIPMENT_INSTANCE',P_EQUIPMENT_INSTANCE);
		END IF;
		--
		open printer;
		fetch printer into x_printer;
		close printer;
		--
		-- Debug Statements
		--
                WSH_DEBUG_SV.log(l_module_name,'Printer Selected : ',x_printer);
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		RETURN; -- irrespective of whether cursor failed to fetch anything, just return.

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   END Select_Printer;


END WSH_REPORT_PRINTERS_PVT;

/
