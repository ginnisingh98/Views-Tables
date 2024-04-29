--------------------------------------------------------
--  DDL for Package Body CS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_STD" as
/* $Header: csxcstdb.pls 120.3.12010000.2 2009/04/17 12:35:29 sanjrao ship $ */

   --  Global variables
	CurVal number;		--used by the function GetNextValInPeriod.

/*******************************************************************************
********************************************************************************
   --
   --  Private Functions/procedures
   --
********************************************************************************
*******************************************************************************/

	procedure Get_Mfg_Org_Id(X_org_id OUT NOCOPY NUMBER) is
		Org_id NUMBER;
	BEGIN
		X_org_id := Get_Item_Valdn_Orgzn_ID;
	END Get_Mfg_Org_Id;
	--
	procedure Get_Order_Type_Id(X_order_type IN VARCHAR2,
					    X_order_type_id OUT NOCOPY NUMBER) is
	BEGIN
             null;
	--	select transaction_type_id into X_order_type_id
	--	from so_order_types
	--	where name = X_order_type;
	exception
		when NO_DATA_FOUND then
		Fnd_Message.Set_Name('CS','CS_ALL_INVALID_ORDER_TYPE');
		Fnd_Message.Set_Token('ORDER_TYPE',X_Order_Type);
		App_Exception.Raise_Exception;
	END Get_Order_Type_Id;
	--
	procedure Get_Day_Uom(X_day_uom_code IN VARCHAR2,
				   X_day_uom OUT NOCOPY VARCHAR2) is
	BEGIN
		select unit_of_measure into X_day_uom
		from mtl_units_of_measure
		where uom_code = X_day_uom_code;
	exception
		when NO_DATA_FOUND then
		Fnd_Message.Set_Name('CS','CS_ALL_INVALID_UOM_CODE');
		Fnd_Message.Set_Token('UOM_CODE',X_Day_UOM_Code);
		App_Exception.Raise_Exception;
	END Get_Day_UOM;
	--
	procedure Get_Month_Uom(X_month_uom_code IN VARCHAR2,
					X_month_uom OUT NOCOPY VARCHAR2) is
	BEGIN
		select unit_of_measure into X_month_uom
		from mtl_units_of_measure
		where uom_code = X_month_uom_code;
	exception
		when NO_DATA_FOUND then
		Fnd_Message.Set_Name('CS','CS_ALL_INVALID_UOM_CODE');
		Fnd_Message.Set_Token('UOM_CODE',X_Month_UOM_Code);
		App_Exception.Raise_Exception;
	END Get_Month_UOM;
	--
	procedure Get_Appl_Short_Name(X_flex_code IN VARCHAR2,
						    X_appl_short_name OUT NOCOPY VARCHAR2) is
	BEGIN
		X_appl_short_name := 'INV';
	END Get_Appl_Short_Name;
	--
	/* Get the default order by selection and code. */
	procedure Get_Default_Order_by(x_order_by_code        IN  VARCHAR2,
						x_order_by_lookup_type IN  VARCHAR2,
						x_order_by             OUT NOCOPY VARCHAR2 ) IS
	BEGIN
		SELECT Meaning
		INTO X_order_by
		FROM CS_LOOKUPS
		WHERE lookup_type = x_order_by_lookup_type
		AND   lookup_code = x_order_by_code;
	END Get_Default_Order_By;
	--
	--
	--
	--
/*******************************************************************************
********************************************************************************
	--
	--  Public Functions/procedures
	--
********************************************************************************
*******************************************************************************/

	procedure Get_Default_Values(
				order_by_code          IN     VARCHAR2,
                    order_by_lookup_type   IN     VARCHAR2,
                    flex_code              IN     VARCHAR2 DEFAULT  'MSTK',
                    mfg_org_id             IN OUT NOCOPY NUMBER,
                    appl_short_name        IN OUT NOCOPY VARCHAR2,
                    order_by               IN OUT NOCOPY VARCHAR2,
                    order_type             IN     VARCHAR2,
                    order_type_id          IN OUT NOCOPY NUMBER,
                    day_uom_code           IN     VARCHAR2,
                    day_uom                IN OUT NOCOPY VARCHAR2,
                    month_uom_code         IN     VARCHAR2,
                    month_uom              IN OUT NOCOPY VARCHAR2
                                 ) is
	BEGIN
		Get_Mfg_Org_Id(mfg_org_id);
		Get_Appl_Short_Name(flex_code,appl_short_name);
		Get_Default_Order_by(order_by_code,order_by_lookup_type,order_by);
		--Get_Order_Type_Id(order_type, order_type_id);
		Get_Day_Uom(day_uom_code, day_uom);
		Get_Month_Uom(month_uom_code, month_uom);
	END Get_Default_Values;
	--
	/* Overloaded Procedures Get_Default_Values */
	procedure Get_Default_Values(
				  flex_code     IN  VARCHAR2 DEFAULT  'MSTK',
				  mfg_org_id             IN OUT NOCOPY NUMBER,
				  appl_short_name        IN OUT NOCOPY VARCHAR2
						  ) IS
	BEGIN
		Get_Mfg_Org_Id(mfg_org_id);
		Get_Appl_Short_Name(flex_code,appl_short_name);
	END Get_Default_Values;
	--
	procedure Get_Default_Values(flex_code               IN  VARCHAR2,
						    mfg_org_id              IN OUT NOCOPY NUMBER,
						    mfg_org_name            IN OUT NOCOPY VARCHAR2,
						    appl_short_name         IN OUT NOCOPY VARCHAR2) is
	begin
		get_default_values(flex_code,mfg_org_id,appl_short_name);
		--
		select name
		into mfg_org_name
		from hr_organization_units
		where organization_id = mfg_org_id;
	end get_default_values;
	--
	procedure Get_Default_Values(
                      order_by_code          IN  VARCHAR2,
                      order_by_lookup_type   IN  VARCHAR2,
                      flex_code              IN  VARCHAR2 DEFAULT  'MSTK',
                      mfg_org_id         IN     OUT NOCOPY NUMBER,
                      appl_short_name    IN     OUT NOCOPY VARCHAR2,
                      order_by           IN     OUT NOCOPY VARCHAR2
                                ) IS
	BEGIN
		Get_Mfg_Org_Id(mfg_org_id);
		Get_Appl_Short_Name(flex_code,appl_short_name);
		Get_Default_Order_by(order_by_code,order_by_lookup_type,order_by);
	END Get_Default_Values;
	--
/*
	function get_coterminated_end_dt
	(
		p_cot_day_mth      varchar2,					--in DD-MON fmt
		p_start_dt         date       default sysdate
	) return date is
		l_start_dt  date;
		l_end_dt    date;
		l_cot_day_mth varchar2(5);					--in DD-MM fmt
	begin
		l_cot_day_mth := to_char(to_date(p_cot_day_mth,'DD-MON',
							'NLS_DATE_LANGUAGE=American'),
							'DD-MM');
		l_start_dt := p_start_dt;
		if l_start_dt is null then
			l_start_dt := sysdate;
		end if;
		l_start_dt := trunc(l_start_dt);
		--
		l_end_dt := to_date(l_cot_day_mth||'-'||
					to_char(l_start_dt,'RR'),'DD-MM-RR');
		if l_end_dt < l_start_dt then
			l_end_dt := add_months(l_end_dt,12);
		end if;
		--
		return(l_end_dt);
	end get_coterminated_end_dt;
*/

	--
	--
	--Get the phone# for the contact after determining whether the contact is
	--a contact for a cust, or a contact for a cust for an addr.
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The function is being stubbed as it is not used
-- -----------------------------------------------------------------------------
	function get_contact_phone
	(
		p_contact_id       number
	) return varchar2 is
		l_customer_id      number;
		l_address_id      number;
		l_phone_no         varchar2(80);
		--
		l_sql_count        number;
	begin
        /******
		if p_contact_id is null then
			return null;
		end if;
		--
		l_sql_count := 1;
		select customer_id,address_id
		into l_customer_id,l_address_id
		from ra_contacts
		where contact_id = p_contact_id;
		--
		l_sql_count := 2;
		if l_address_id is null then	--contact for a cust.
			select decode(area_code,null,null,'('||area_code||')')||
					phone_number||
					decode(extension,null,null,' x'||extension)
			into l_phone_no
			from ra_phones
			where contact_id = p_contact_id
			and   customer_id = l_customer_id
			and   address_id is null
			and   primary_flag = 'Y'
			and   status = 'A';
		else						--contact for a cust for an address.
			select decode(area_code,null,null,'('||area_code||')')||
					phone_number||
					decode(extension,null,null,' x'||extension)
			into l_phone_no
			from ra_phones
			where contact_id = p_contact_id
			and   customer_id = l_customer_id
			and   address_id = l_address_id
			and   primary_flag = 'Y'
			and   status = 'A';
		end if;
        *************************/
		--
		return l_phone_no;
		--
	exception
	when NO_DATA_FOUND then
		if l_sql_count = 1 then
			raise;
		else
			return null;
		end if;
	end get_contact_phone;
	--
	--
	--Get the item's revision description.
	--If p_error_flag is 'FALSE', then a NULL is returned if the revision is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the revision is invalid, and it is upto the calling code to handle it.
	function get_item_rev_desc
	(
		p_org_id           number,
		p_inv_item_id      number,
		p_revision         varchar2,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2 is
		l_rev_desc         mtl_item_revisions.description%type;
	begin
		if p_org_id is null or
		   p_inv_item_id is null or
		   p_revision is null then
			return(null);
		end if;
		--
		select description
		into l_rev_desc
		from mtl_item_revisions
		where organization_id = p_org_id
		and   inventory_item_id = p_inv_item_id
		and   revision = p_revision;
		--
		return(l_rev_desc);
		--
	exception
	when NO_DATA_FOUND then
		if p_error_flag  = 'TRUE' then
			raise;
		else
			return(null);
		end if;
	end get_item_rev_desc;
	--
	--
	--Get the site_use_id's location.
	--If p_error_flag is 'FALSE', then a NULL is returned if the site_use is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the site_use is invalid, and it is upto the calling code to handle it.
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The function is being stubbed as it is not used
-- -----------------------------------------------------------------------------
	function get_site_use_location
	(
		p_site_use_id      number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2 is
	--	l_location	ra_site_uses.location%type;
	begin
                /**************
		if p_site_use_id is null then
			raise NO_DATA_FOUND;
		end if;
		--
		select location
		into l_location
		from ra_site_uses
		where site_use_id = p_site_use_id;
		--
		return(l_location);
		--
                ********/
                return null;
	exception
	when NO_DATA_FOUND then
		if p_error_flag  = 'TRUE' then
			raise;
		else
			return(null);
		end if;
	end get_site_use_location;
	--
	--
	--Get the customer name.
	--If p_error_flag is 'FALSE', then a NULL is returned if the PK is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the PK is invalid, and it is upto the calling code to handle it.
        -- 12/08/05 smisra replaced ra_customers with hz_parties
	function get_cust_name
	(
		p_customer_id      number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2 is
		l_cust_name	hz_parties.party_name%type;
	begin
		if p_customer_id is null then
			raise NO_DATA_FOUND;
		end if;
		--
		select party_name
		into l_cust_name
		from hz_parties
		where party_id = p_customer_id;
		--
		return(l_cust_name);
		--
	exception
	when NO_DATA_FOUND then
		if p_error_flag  = 'TRUE' then
			raise;
		else
			return(null);
		end if;
	end get_cust_name;


	function warranty_exists(cp_id NUMBER)
	return VARCHAR2 is
          return_val VARCHAR2(1) ;
	begin

	    select 'Y' INTO return_val
	    from cs_cp_services CSS
	    where  css.customer_product_id = cp_id
	    and css.warranty_flag='Y' ;
         return(return_val);


     exception

	   WHEN NO_DATA_FOUND THEN
		   return_val := 'N' ;
		   return(return_val);

        WHEN TOO_MANY_ROWS THEN
		   return_val := 'Y' ;
		   return(return_val);


     end warranty_exists ;

	--
	--
	--Note: Used by CSOEBAT and CSXSUDCP form as of 1/29/97.
	function get_war_item_ids
	(
		p_organization_id   number,
		p_inventory_item_id number,
		p_war_date          date    default sysdate
	) return varchar2 is
		l_war_date		date;
		l_last_delim_pos	number;
		l_war_item_ids		varchar2(2000);
		l_com_bill_seq_id	number;
		--
		cursor c_war_items(c_bill_seq_id number) is
		select bic.component_item_id       war_item_id
		from bom_inventory_components bic
		where bic.bill_sequence_id = c_bill_seq_id
--
--Fix to bug#479703. vharihar 4/16/97.
--		and   trunc(l_war_date) between trunc(bic.effectivity_date) and
--					trunc(nvl(bic.disable_date,l_war_date))
		and   l_war_date >= bic.effectivity_date
		and   l_war_date < nvl(bic.disable_date,l_war_date+1)
--
		and exists
		(
			select 'Component is a Warranty'
			from mtl_system_items mtl
			where mtl.organization_id = p_organization_id
			and   mtl.inventory_item_id = bic.component_item_id
			and   mtl.vendor_warranty_flag = 'Y'
		)
		order by bic.component_item_id;
		--
	begin
		if p_organization_id is null or
		   p_inventory_item_id is null then
			raise NO_DATA_FOUND;
		end if;
		--
		l_war_date := nvl(p_war_date,sysdate);
		--
		select common_bill_sequence_id
		into l_com_bill_seq_id
		from bom_bill_of_materials
		where organization_id = p_organization_id
		and   assembly_item_id = p_inventory_item_id
		and   alternate_bom_designator is null;
		--
		l_war_item_ids := null;
		for c_war_items_rec in c_war_items(l_com_bill_seq_id) loop
			l_war_item_ids := l_war_item_ids ||
						to_char(c_war_items_rec.war_item_id)||',';
		end loop;
		--
		if l_war_item_ids is null then
			raise NO_DATA_FOUND;
		end if;
		--
		--Strip off the last comma. Intentionally used instr() and
		--substr() here, and not instrb() and substrb(), as these
		--will suffice, and wont cause any harm in this case.
		l_last_delim_pos := instr(l_war_item_ids,',',-1);
		l_war_item_ids := substr(l_war_item_ids,1,l_last_delim_pos-1);
		--
		return(l_war_item_ids);
		--
	exception
	when NO_DATA_FOUND then
		return(null);
	end get_war_item_ids;
	--
	--
	--Get the system's name.
	--If p_error_flag is 'FALSE', then a NULL is returned if the PK is
	--invalid. If p_error_flag is 'TRUE', the NO_DATA_FOUND exception is raised
	--if the PK is invalid, and it is upto the calling code to handle it.
	function get_system_name
	(
		p_system_id		number,
		p_error_flag       varchar2 default 'TRUE'
	) return varchar2 is
		l_system_name		cs_systems.name%type;
	begin
		if p_system_id is null then
			raise NO_DATA_FOUND;
		end if;
		--
		select name
		into l_system_name
		from cs_systems
		where system_id = p_system_id;
		--
		return(l_system_name);
		--
	exception
	when NO_DATA_FOUND then
		if p_error_flag  = 'TRUE' then
			raise;
		else
			return(null);
		end if;
	end get_system_name;
	--
	--
	--

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
	procedure Get_Primary_Address(x_id NUMBER,
							x_site_use_code VARCHAR2,
							x_location OUT NOCOPY VARCHAR2,
							x_site_use_id OUT NOCOPY NUMBER,
							x_address1 OUT NOCOPY VARCHAR2,
							x_address2 OUT NOCOPY VARCHAR2,
							x_address3 OUT NOCOPY VARCHAR2,
							error_flag OUT NOCOPY NUMBER) IS

     begin
     null;

      /*******
       select su1.location,
       su1.site_use_id,
	  addr1.address1 || DECODE(ADDR1.ADDRESS1,'','',
					DECODE(ADDR1.ADDRESS2,'','',', ')) ||
					ADDR1.address2 ,
       addr1.address3 || DECODE(addr1.address3,'','',
					DECODE(addr1.address4,'','',', ')) ||
					ADDR1.address4 ,
       SUBSTR(ADDR1.CITY || DECODE(ADDR1.CITY,'','',
	  DECODE(ADDR1.STATE || ADDR1.COUNTRY || ADDR1.POSTAL_CODE,'','',
	  ', ')) || ADDR1.STATE || '  ' ||
	  ADDR1.POSTAL_CODE || '  ' || ADDR1.COUNTRY,1,220)

	  INTO  x_location,
		   x_site_use_id,
		   x_address1,
		   x_address2,
		   x_address3

       FROM   RA_SITE_USES su1,
	  RA_ADDRESSES ADDR1
       WHERE addr1.customer_id = x_id
       AND   addr1.address_id = su1.address_id
       AND   su1.primary_flag = 'Y'
	  AND   su1.status = 'A'
       AND   su1.site_use_code = x_site_use_code ;


	  EXCEPTION
			 WHEN NO_DATA_FOUND THEN
				 error_flag := 0 ;

     *******/

     end  Get_Primary_Address ;

     --
     -- CS_GET_SERVICED_STATUS
     --
     FUNCTION CS_Get_Serviced_Status
	( X_CP_ID IN NUMBER
	) RETURN VARCHAR2 IS
	CURSOR serv_cur IS
	SELECT trunc(nvl(serv.start_date_active, sysdate)) start_date_active,
             trunc(nvl(serv.end_date_active, sysdate))   end_date_active
        	FROM cs_cp_services serv
       		WHERE serv.customer_product_id = X_CP_ID;

    	X_Sysdate           DATE := TRUNC(sysdate);
    	X_Start_Date    DATE;
    	X_End_Date      DATE;
    	ret_val         VARCHAR2(1) := 'N';
    	future          BOOLEAN := FALSE;

     BEGIN

     	OPEN serv_cur;

    	LOOP
      		FETCH serv_cur INTO X_Start_Date, X_End_Date;
      		EXIT WHEN serv_cur%NOTFOUND;

      		if (X_Sysdate between X_Start_Date and X_End_Date) then
     			ret_val := 'Y';
     			EXIT;
      		elsif (X_Sysdate < X_Start_Date) then
        		future := TRUE;
      		end if;
    	END LOOP;

    	if (ret_val <> 'Y') then
      		if (future = TRUE) then
        		ret_val := 'F';
      		end if;
    	end if;

    	CLOSE serv_cur;
    	return ret_val;

     END CS_Get_Serviced_Status;

/********
      procedure Output_Messages( p_return_status   VARCHAR2,
                                 p_msg_count       NUMBER) IS
        l_message  VARCHAR2(2000);
      BEGIN
        IF (p_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          DBMS_OUTPUT.PUT_LINE('Result: Successful');
        ELSIF (p_return_status = FND_API.G_RET_STS_ERROR) THEN
          DBMS_OUTPUT.PUT_LINE('Result: Error');
        ELSIF (p_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          DBMS_OUTPUT.PUT_LINE('Result: Unexpected Error');
        ELSE
          DBMS_OUTPUT.PUT_LINE('Result: Fatal Error - unrecognized return status code');
        END IF;

        IF (p_msg_count > 0) THEN

          FOR counter IN REVERSE 1..p_msg_count LOOP

            l_message := fnd_msg_pub.get(counter, FND_API.G_FALSE);
            DBMS_OUTPUT.PUT_LINE('  MSG('||to_char(counter)||'): '||
                                 l_message);

          END LOOP;

          fnd_msg_pub.delete_msg ;

        END IF;


      END Output_Messages;
******/
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The procedure is being stubbed as it is not used
-- -----------------------------------------------------------------------------
	procedure Get_Address_from_id(x_id NUMBER,
							x_location OUT NOCOPY VARCHAR2,
							x_address1 OUT NOCOPY VARCHAR2,
							x_address2 OUT NOCOPY VARCHAR2,
							x_address3 OUT NOCOPY VARCHAR2,
							error_flag OUT NOCOPY NUMBER) IS

     begin
       null;
     /*************************

       select su1.location,
	  addr1.address1 || DECODE(ADDR1.ADDRESS1,'','',
					DECODE(ADDR1.ADDRESS2,'','',', ')) ||
					ADDR1.address2 ,
       addr1.address3 || DECODE(addr1.address3,'','',
					DECODE(addr1.address4,'','',', ')) ||
					ADDR1.address4 ,
       SUBSTR(ADDR1.CITY || DECODE(ADDR1.CITY,'','',
	  DECODE(ADDR1.STATE || ADDR1.COUNTRY || ADDR1.POSTAL_CODE,'','',
	  ', ')) || ADDR1.STATE || '  ' ||
	  ADDR1.POSTAL_CODE || '  ' || ADDR1.COUNTRY,1,220)

	  INTO  x_location,
		   x_address1,
		   x_address2,
		   x_address3

       FROM   RA_SITE_USES su1,
	  RA_ADDRESSES ADDR1
       WHERE su1.site_use_id = x_id
       AND   addr1.address_id = su1.address_id ;


	  EXCEPTION
			 WHEN NO_DATA_FOUND THEN
				 error_flag := 0 ;
       *******/

       END GET_ADDRESS_FROM_ID ;

	-- This function returns the next entry in a periodic cycle.
	-- As of 9/1/98, only 12 mth periods are supported. Thus, on subsequent
	-- invocations, this functions currently returns 1, 2, ... 12, 1, 2, ...
	-- p_reset = 1 will reset cycle.
	function GetNextValInPeriod
	(
	    p_reset  NUMBER
     ) return number is
		Var1 number;
	begin
		if CurVal >= 12 then
			CurVal := 1;
			return (1);
		end if;
		CurVal := CurVal + 1;
		Var1 := CurVal;
		if p_reset = 1 then
			CurVal := 0;
		end if;
		return (Var1);
	end GetNextValInPeriod;
	--
	--
	-- This function returns the item category of an item in the OE
	-- category set.
	function GetItemCategory
	(
	    p_inv_item_id number,
	    p_inv_orgn_id number
     ) return varchar2 is
		l_cat varchar2(50);
	begin
		if p_inv_item_id is null or
		   p_inv_orgn_id is null then
			return (null);		/*****/
		end if;
		--
		select mc.description
		into l_cat
		from
			mtl_categories mc,
			mtl_default_category_sets mdc,
			mtl_item_categories mic
		where mic.inventory_item_id  = p_inv_item_id
		and mic.organization_id = p_inv_orgn_id
		and mdc.functional_area_id+0 = 7
		and mic.category_set_id = mdc.category_set_id
		and mc.category_id = mic.category_id;
		--
		return(l_cat);		/*****/
		--
	exception
	when NO_DATA_FOUND then
		return(null);		/*****/
	end GetItemCategory;
--
--
--
--
--package initialization part

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 08/08/05 smisra   bug 4532643
--                   The function is being stubbed as it is not used
-- -----------------------------------------------------------------------------
FUNCTION SITE_USE_ADDRESS(site_id IN NUMBER) RETURN VARCHAR2 IS
  address	VARCHAR2(2000);
  temp_address1	VARCHAR2(240);
  temp_address2	VARCHAR2(240);
  temp_address3	VARCHAR2(240);
  temp_address4	VARCHAR2(240);
  temp_city	VARCHAR2(60);
  temp_state	VARCHAR2(60);
  temp_code	VARCHAR2(60);
  temp_country	VARCHAR2(60);

BEGIN
  return(null);
  /*****
  SELECT address1, address2, address3, address4, city, state, postal_code, country
  INTO temp_address1, temp_address2, temp_address3, temp_address4, temp_city,
       temp_state, temp_code, temp_country
  FROM CS_RA_ADDR_LOC_RG_V
  WHERE site_use_id = site_id;

  address := temp_address1;

  IF temp_address2 IS NOT NULL THEN
    address := address||', '||temp_address2;
  END IF;

  IF temp_address3 IS NOT NULL THEN
    address := address||', '||temp_address3;
  END IF;

  IF temp_address4 IS NOT NULL THEN
    address := address||', '||temp_address4;
  END IF;

  IF temp_city IS NOT NULL THEN
    address := address||', '||temp_city;
  END IF;

  IF temp_state IS NOT NULL THEN
    address := address||', '||temp_state;
  END IF;

  IF temp_code IS NOT NULL THEN
    address := address||' '||temp_code;
  END IF;

  IF temp_country IS NOT NULL THEN
    address := address||' '||temp_country;
  END IF;

  RETURN address;
  ****/

END Site_Use_Address;


	-- This function returns the "inventory organization" ID (or whats also
	-- called the "warehouse" ID that the Service suite of products should
	-- use for validating items

        function Get_Item_Valdn_Orgzn_ID return number is
	Orgzn_ID   varchar2(250);
	begin
		fnd_profile.get('CS_INV_VALIDATION_ORG',Orgzn_ID);
		return(to_number(Orgzn_ID));
--		return(to_number(fnd_profile.value_wnps('ASO_PRODUCT_ORGANIZATION_ID')));
	end;

/* The Following Functions will take address fields and Format them based on
   HZ_FORMAT_PUB. In case of error, it returns a simple concatenation of fields.*/

FUNCTION format_address_concat( address_style IN VARCHAR2,
                         address1 IN VARCHAR2,
                         address2 IN VARCHAR2,
                         address3 IN VARCHAR2,
                         address4 IN VARCHAR2,
                         city IN VARCHAR2,
                         county IN VARCHAR2,
                         state IN VARCHAR2,
                         province IN VARCHAR2,
                         postal_code IN VARCHAR2,
                         territory_short_name IN VARCHAR2
                        )return VARCHAR2 IS
    l_address varchar2(1000);
BEGIN
   l_address := address1;

   IF ( address2 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address2;
   END IF;

   IF ( address3 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address3;
   END IF;

   IF ( address4 IS NOT NULL ) THEN
      l_address := l_address || ', ' || address4;
   END IF;

   IF ( city IS NOT NULL ) THEN
      l_address := l_address || ', ' || city;
   END IF;

   IF ( county IS NOT NULL ) THEN
      l_address := l_address || ', ' || county;
   END IF;

   IF ( state IS NOT NULL ) THEN
      l_address := l_address || ', ' || state;
   END IF;

   IF ( province IS NOT NULL ) THEN
      l_address := l_address || ', ' || province;
   END IF;

   IF ( postal_code IS NOT NULL ) THEN
      l_address := l_address || ', ' || postal_code;
   END IF;

   IF ( territory_short_name IS NOT NULL ) THEN
      l_address := l_address || ', ' || territory_short_name;
   END IF;

   RETURN( l_address );
END format_address_concat;


FUNCTION format_address( address_style IN VARCHAR2,
                         address1 IN VARCHAR2,
                         address2 IN VARCHAR2,
                         address3 IN VARCHAR2,
                         address4 IN VARCHAR2,
                         city IN VARCHAR2,
                         county IN VARCHAR2,
                         state IN VARCHAR2,
                         province IN VARCHAR2,
                         postal_code IN VARCHAR2,
                         territory_short_name IN VARCHAR2,
                         country_code IN VARCHAR2 default NULL,
                         customer_name IN VARCHAR2 default NULL,
                         first_name IN VARCHAR2 default NULL,
                         last_name IN VARCHAR2 default NULL,
                         mail_stop IN VARCHAR2 default NULL,
                         default_country_code IN VARCHAR2 default NULL,
                         default_country_desc IN VARCHAR2 default NULL,
                         print_home_country_flag IN VARCHAR2 default NULL,
                         print_default_attn_flag IN VARCHAR2 default NULL,
                         width IN NUMBER default NULL,
                         height_min IN NUMBER default NULL,
                         height_max IN NUMBER default NULL
                        )return VARCHAR2 IS

    l_formatted_address      VARCHAR2(2000);
    l_formatted_lines_cnt    NUMBER;
    l_formatted_address_tbl  hz_format_pub.string_tbl_type;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

BEGIN

        hz_format_pub.format_address (
            p_line_break                => ', ',
            p_from_territory_code       => 'x',   -- force country short name be displayed
            p_address_line_1            => address1,
            p_address_line_2            => address2,
            p_address_line_3            => address3,
            p_address_line_4            => address4,
            p_city                      => city,
            p_postal_code               => postal_code,
            p_state                     => state,
            p_province                  => province,
            p_county                    => county,
            p_country                   => country_code,
            -- output parameters
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data,
            x_formatted_address         => l_formatted_address,
            x_formatted_lines_cnt       => l_formatted_lines_cnt,
            x_formatted_address_tbl     => l_formatted_address_tbl
          );
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           return l_formatted_address;
        ELSE
           return(format_address_concat(  address_style,
                                   address1,
                                   address2,
                                   address3,
                                   address4,
                                   city,
                                   county,
                                   state,
                                   province,
                                   postal_code,
                                   territory_short_name ) );
        END IF;
END format_address;

function return_primary_phone
(
	party_id  IN number
) return varchar2 is
l_phone	varchar2(50);
begin

	select decode(phone_country_code,'','',phone_country_code || '-' ) ||
               decode(phone_area_code,'','',phone_area_code || '-' ) || phone_number
        into l_phone
	from (select phone_number, phone_area_code, phone_country_code
		from hz_contact_points
		where owner_table_id = party_id
		and owner_table_name ='HZ_PARTY_SITES'
		and contact_point_type = 'PHONE'
		order by primary_flag desc, creation_date asc)
	where rownum = 1;

	return l_phone;

exception
	when NO_DATA_FOUND then
		l_phone := null;
                return l_phone;
end return_primary_phone;

-- Added for 12.1.2
function check_onetime
(
  incident_location_id IN number
) return varchar2 IS
  addrswitch varchar2(100);
begin
  select
    decode(created_by_module,'SR_ONETIME' ,'UnValidAddrXRN','ValidXAddrRN') into addrswitch
  from hz_party_sites
  where party_site_id = incident_location_id;

  return(addrswitch);
  exception when others then
    addrswitch:=null;
    return(addrswitch);
end check_onetime;

END CS_STD;

/
