--------------------------------------------------------
--  DDL for Package Body CUG_WF_EMAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_WF_EMAIL_UTIL" AS
/* $Header: CUGWFEUB.pls 120.0 2005/07/20 12:13:45 appldev noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below
 PROCEDURE Get_SR_Details
 (   ITEMTYPE IN VARCHAR2    -- Workflow Item Type := 'JTFTASKS'
    ,ITEMKEY IN VARCHAR2     -- to_char(p_task_id)||'-'||to_char(l_wf_process_id)
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY VARCHAR2
  )IS
      -- Enter the procedure variables here. As shown below
     --variable_name        datatype  NOT NULL DEFAULT default_value;
     lv_itemtype                   VARCHAR2(8);
     lv_itemkey                    VARCHAR2(240);
     lv_task_number     VARCHAR2(30);
     lv_incident_number VARCHAR2(64);
     lv_release_resource_type  VARCHAR2(80);
     X_RETURN_STATUS  VARCHAR2(80):= FND_API.G_RET_STS_SUCCESS;

     lv_task_id         NUMBER := 0;
     lv_task_type_id    NUMBER := 0;
     lv_incident_id     NUMBER := 0;
     lv_incident_type_id NUMBER := 0;

     lv_incident_date   DATE;


  BEGIN
    IF ( funcmode = 'RUN' ) THEN

        lv_itemtype := itemtype;
        lv_itemkey  := itemkey;

   	-- Get the Service Request Id by using the GetItemAttr function for 'TASK_ID' and then
        -- execute a SQL query to find out the source_object_id from JTF_TASKS_VL view for the
	       lv_task_number := wf_engine.GetItemAttrText(
                    			ITEMTYPE => lv_itemtype,
				    	ITEMKEY => lv_itemkey,
				    	ANAME => 'TASK_NUMBER' );

        -- Make sure by putting specific check that it will execute only for EMAIL NOTIFICATION TASK TYPE
        -- for a given Service Request
        select 	ciav.incident_id, ciav.incident_type_id , ciav.incident_number,
		ciav.incident_date, jtv.task_id, jtv.task_type_id
        into   	lv_incident_id, lv_incident_type_id,  lv_incident_number,
		lv_incident_date, lv_task_id, lv_task_type_id
        from   	cs_incidents_all_b ciav,
               	jtf_tasks_b jtv
        where 	ciav.incident_id = jtv.source_object_id
          and   jtv.task_number = lv_task_number
          and   jtv.source_object_type_code ='SR';




        Get_Task_Attrs_Details (
            ITEMTYPE
            , ITEMKEY
            , lv_incident_type_id
            , lv_task_id
            , lv_task_type_id
            , X_RETURN_STATUS );




        IF (X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS ) THEN
            RESULTOUT :=  'COMPLETE:';
            return;
        END IF;

        -- Call the Get_Incident_Addr_Details procedure. This call, after getting the
        -- address details from HZ_LOCATIONS table for the given Service Request, set
        -- the item attribute 'CUG_INC_ADDR' in the workflow.




        Get_Incident_Addr_Details (
  			ITEMTYPE
            		,ITEMKEY
 			,lv_incident_number
            		,X_RETURN_STATUS );


        IF (X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS ) THEN
            RESULTOUT :=  'COMPLETE:';
            return;
        END IF;

         -- Get the Service Request Attributes details and store it in the
        -- Workflow Item Attributes declared from CUG_SR_ATTRS_DET1 to CUG_SR_ATTRS_DET5



        Get_SR_Attrs_Details (
  	 	ITEMTYPE
		, ITEMKEY
 		, lv_incident_id
		, lv_incident_type_id
		, lv_incident_number
		, lv_task_number
		, X_RETURN_STATUS );



        IF (X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS ) THEN
            RESULTOUT :=  'COMPLETE:';
            return;
        END IF;
             RESULTOUT :=  'COMPLETE:';
      return;
      END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
             RESULTOUT :=  'COMPLETE:';
        return;
          When Others then
                WF_CORE.context('CUG_WF_EMAIL_UTIL', 'GET_SR_DETAILS', itemtype, itemkey, actid, funcmode );
                   RAISE;
  END Get_SR_Details;

  PROCEDURE Get_Task_Attrs_Details
     (
        ITEMTYPE       IN VARCHAR2
        , ITEMKEY      IN VARCHAR2
        , INCIDENT_TYPE_ID IN NUMBER
        , TASK_ID      IN NUMBER
        , TASK_TYPE_ID IN NUMBER
        , X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
     ) IS
    --Declaration of all the local variables
     lv_itemtype                VARCHAR2(8);
     lv_itemkey                 VARCHAR2(240);
     lv_incident_type_id        NUMBER;
     lv_task_id                 NUMBER;
     lv_task_type_id            NUMBER;
     lv_attr_name               VARCHAR2(30);
     lv_task_type_attr_value    VARCHAR2(1997);
     lv_task_type_attr_name     VARCHAR2(30);
     lv_task_type_attr_type     VARCHAR2(8);
     lv_task_type_attr_dep_id   NUMBER;
     lv_incident_date           DATE;

    -- Cursor declaration for all the Task  attributes from CUG_TSK_TYP_ATTR_MAPS_VL table
    -- for a given TASK_TYPE_ID, and TASK_ID as input parameter, and ITEMTYPE is the Workflow
    -- internal Name for Task related workflow.

    CURSOR  c_all_task_attrs  IS
    SELECT  task_type_attribute_code
    FROM    cug_tsk_typ_attr_maps_vl
    WHERE   TASK_TYPE_ID = lv_task_type_id;

   BEGIN
      	lv_itemtype := ITEMTYPE;
      	lv_itemkey  := ITEMKEY;
      	lv_task_id  := TASK_ID;
      	lv_task_type_id:= TASK_TYPE_ID;
      	lv_incident_type_id := INCIDENT_TYPE_ID;

	lv_task_type_attr_dep_id := wf_engine.GetItemAttrText(
                    ITEMTYPE => lv_itemtype,
                    ITEMKEY => lv_itemkey,
                    ANAME => 'CUG_TASK_DEP_ID' );

	OPEN  c_all_task_attrs;
	LOOP
       	lv_attr_name := null;
    	-- Fetch all the attributes Name from the cursor.
	FETCH c_all_task_attrs INTO  lv_attr_name;
	EXIT WHEN c_all_task_attrs%NOTFOUND;

    	-- Process for Each Attribute one by one in the loop by getting the attribute name and value.
    	SELECT  cvals.task_type_attr_value, wiav.name,  wiav.type
    	INTO    lv_task_type_attr_value, lv_task_type_attr_name, lv_task_type_attr_type
    	FROM    CUG_TSK_TYP_ATTR_MAPS_VL    cttamv,
            	cug_sr_task_attr_vals_vl    cvals,
    	    	WF_ITEM_ATTRIBUTES_VL       wiav,
            	CUG_TSK_TYP_ATTR_DEPS_VL    cttadv
    	WHERE   cttamv.tsk_typ_attr_map_id = cvals.task_type_attr_map_id
    	AND	cttamv.task_type_attribute_code = wiav.name
    	AND     wiav.name = lv_attr_name
    	AND     cvals.tsk_typ_attr_depend_id =  cttadv.tsk_typ_attr_dep_id
    	AND     cttadv.tsk_typ_attr_dep_id = lv_task_type_attr_dep_id
    	AND     cttadv.task_type_id =  cttamv.task_type_id
    	AND     cttadv.task_type_id = lv_task_type_id
    	AND     cttadv.incident_type_id = lv_incident_type_id
    	AND	    wiav.item_type = 'CUGTASKS';


		IF (lv_task_type_attr_type = 'ROLE' ) THEN
			wf_engine.SetItemAttrText(
                ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME =>lv_task_type_attr_name,
				AVALUE => upper(lv_task_type_attr_value) );
		ELSIF (lv_task_type_attr_type = 'NUMBER' ) THEN
			wf_engine.SetItemAttrNumber(
                ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME =>lv_task_type_attr_name,
                AVALUE => to_number(lv_task_type_attr_value ) );

         ELSIF (lv_task_type_attr_type = 'DATE' ) THEN
			wf_engine.SetItemAttrDate(
                ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME =>lv_task_type_attr_name,
                AVALUE =>to_date(lv_task_type_attr_value,'DD-MM-YYYY') );

         ELSE
            wf_engine.SetItemAttrText(
                ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME =>lv_task_type_attr_name,
				AVALUE => lv_task_type_attr_value );
		 END IF;

	END LOOP;

    CLOSE c_all_task_attrs;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR ;
  END Get_Task_Attrs_Details;




  -----------------------------------------------------------------------
  --  Get_Incident_Addr_Details
  --
  --  Modification History:
  --
  --  Date        Name       Desc
  --  ----------  ---------  -------------------------------------------
  --  05/18/04    RMANABAT   Fix for bug 3630834. Modified cursor
  --			     l_Incident_Addr_csr. Added cursor l_hz_party_site_csr.
  --			     Address is from hz_locations is location type is
  --			     HZ_LOCATION, if HZ_PARTY_SITE then location_id is
  --			     derived from hz_party_sites.
  ----------------------------------------------------------------------

   PROCEDURE Get_Incident_Addr_Details
     (
        ITEMTYPE       IN VARCHAR2
        , ITEMKEY      IN VARCHAR2
        , INCIDENT_NUMBER IN VARCHAR2
        ,X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
     )
   IS
  -- Declaration of all the local variables

    lv_itemtype                VARCHAR2(8);
    lv_itemkey                 VARCHAR2(240);
    lv_incident_number         VARCHAR2(64);
    lv_incident_address  VARCHAR2(2000);

-- Begin of changes by ANEEMUCH 13-May-2002
-- Changed because of GSCC error, to remove CHR(10) and replace with CHR(0)

    /***
    cursor l_Incident_Addr_csr is
       SELECT  hl.address , hl.city, hl.state, hl.province, hl.postal_code, hl.country
       FROM    cs_sr_incident_address_v hl,
                   CS_INCIDENTS_ALL_b cia
       WHERE hl.location_id = cia.incident_location_id
       AND      cia.incident_number = lv_incident_number;
    ***/
    cursor l_Incident_Addr_csr(l_location_id IN NUMBER) is
       SELECT l.address1 ||
	      DECODE(l.address2,NULL,NULL,'; '|| l.address2) ||
	      DECODE(l.address3,NULL,NULL,'; '|| l.address3) ||
	      DECODE(l.address4,NULL,NULL,'; '|| l.address4) address,
	      l.city,
	      l.state,
	      l.province,
	      l.postal_code,
	      l.country
	FROM   hz_locations l
	WHERE l.location_id = l_location_id;
    l_Incident_Addr_rec l_Incident_Addr_csr%rowtype;

    cursor l_SR_Addr_csr is
        SELECT  incident_location_id, incident_address, incident_city, incident_state,
                incident_province, incident_postal_code, incident_country,
		incident_location_type
        FROM    CS_INCIDENTS_ALL_b
        WHERE   incident_number = lv_incident_number;
   l_SR_Addr_rec l_SR_Addr_csr%rowtype;

   CURSOR l_hz_party_site_csr(l_party_site_id IN NUMBER) IS
     SELECT ps.location_id
     FROM hz_party_sites ps
     WHERE ps.party_site_id = l_party_site_id;
   lv_location_id	NUMBER;


--
-- End of changes added by ANEEMUCH 13-May-2002

    l_address1		VARCHAR2(100);
    l_address2		VARCHAR2(100);
    l_city		VARCHAR2(60);
    l_state		VARCHAR2(60);
    l_province		VARCHAR2(60);
    l_postal_code	VARCHAR2(30);
    l_country		VARCHAR2(60);
BEGIN

    lv_itemtype  := ITEMTYPE;
    lv_itemkey  :=  ITEMKEY;
	lv_incident_number :=  INCIDENT_NUMBER;

    --  Process to get the  Incident Address information from  HZ_LOCATIONS table for the given
    --  Service Request Id. and store it in some local variable v_incident_address

-- Begin of changes by ANEEMUCH 12-May-2002
-- Changed because of GSCC error, to remove CHR(10) and replace with CHR(0)
/*
    SELECT  hl.address1 || CHR(10) || hl.address2  || CHR(10) ||  hl.city || CHR(10) ||
  	        hl.state  || CHR(10) ||  hl.province || CHR(10) ||   hl.postal_code || CHR(10) ||
            hl.country
    INTO    lv_incident_address
    FROM  	HZ_LOCATIONS hl,
        	CS_INCIDENTS_ALL_b cia
    WHERE hl.location_id = cia.install_site_use_id
    AND	cia.incident_number = lv_incident_number;
*/

-- Changes added by ANEEMUCH dated 13-May-2002
-- Incident Address capture done in SR Tab
/*
    SELECT  hl.address1, hl.address2, hl.city, hl.state, hl.province, hl.postal_code, hl.country
    INTO    l_address1, l_address2, l_city, l_state, l_province, l_postal_code, l_country
    FROM        HZ_LOCATIONS hl,
                CS_INCIDENTS_ALL_b cia
    WHERE hl.location_id = cia.install_site_use_id
    AND cia.incident_number = lv_incident_number;

    lv_incident_address := l_address1 || '
'|| l_address2 || '
'|| l_city || '
'|| l_state || '
'|| l_province || '
'|| l_postal_code || '
'|| l_country;
*/

    OPEN l_SR_Addr_csr;
    FETCH l_SR_Addr_csr INTO l_SR_Addr_rec;
    IF l_SR_Addr_rec.incident_location_id IS NOT NULL THEN

	IF (l_SR_Addr_rec.incident_location_type = 'HZ_LOCATION') THEN

          OPEN l_Incident_Addr_csr(l_SR_Addr_rec.incident_location_id);
          FETCH l_Incident_Addr_csr INTO l_Incident_Addr_rec;
          IF (l_Incident_Addr_csr%FOUND) THEN
            lv_incident_address := l_Incident_Addr_rec.address || '
			       '|| l_Incident_Addr_rec.city || '
			       '|| l_Incident_Addr_rec.state || '
			       '|| l_Incident_Addr_rec.province || '
			       '|| l_Incident_Addr_rec.postal_code || '
			       '|| l_Incident_Addr_rec.country;
          ELSE
            lv_incident_address := '';
          END IF;

	  IF l_Incident_Addr_csr%ISOPEN THEN
	    CLOSE l_Incident_Addr_csr;
	  END IF;

	ELSIF (l_SR_Addr_rec.incident_location_type = 'HZ_PARTY_SITE') THEN

	  OPEN l_hz_party_site_csr(l_SR_Addr_rec.incident_location_id);
	  FETCH l_hz_party_site_csr INTO lv_location_id;

	  IF (l_hz_party_site_csr%FOUND AND lv_location_id IS NOT NULL) THEN
	    OPEN l_Incident_Addr_csr(lv_location_id);
	    FETCH l_Incident_Addr_csr INTO l_Incident_Addr_rec;
	    IF (l_Incident_Addr_csr%FOUND) THEN
              lv_incident_address := l_Incident_Addr_rec.address || '
                                 '|| l_Incident_Addr_rec.city || '
                                 '|| l_Incident_Addr_rec.state || '
                                 '|| l_Incident_Addr_rec.province || '
                                 '|| l_Incident_Addr_rec.postal_code || '
                                 '|| l_Incident_Addr_rec.country;
            ELSE
              lv_incident_address := '';
            END IF;
	    IF l_Incident_Addr_csr%ISOPEN THEN
	      CLOSE l_Incident_Addr_csr;
	    END IF;

	  ELSE
	    lv_incident_address := '';
	  END IF;

	  IF l_hz_party_site_csr%ISOPEN THEN
	    CLOSE l_hz_party_site_csr;
	  END IF;

	END IF;		-- IF (l_SR_Addr_rec.incident_location_type = 'HZ_LOCATION')


    ELSE
      lv_incident_address := l_SR_Addr_rec.incident_address || '
			'|| l_SR_Addr_rec.incident_city || '
			'|| l_SR_Addr_rec.incident_state || '
			'|| l_SR_Addr_rec.incident_province || '
			'|| l_SR_Addr_rec.incident_postal_code || '
			'|| l_SR_Addr_rec.incident_country;
    END IF;

    IF l_SR_Addr_csr%ISOPEN THEN
      CLOSE l_SR_Addr_csr;
    END IF;

-- End of changes by ANEEMUCH 12-May-2002

    --  Set the value of the incident address in the Workflow Item attribute Incident Address
	wf_engine.SetItemAttrText(
        ITEMTYPE => lv_itemtype ,
		ITEMKEY  => lv_itemkey,
		ANAME    =>'CUG_INC_ADDR',
		AVALUE   => lv_incident_address  );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR ;
 End Get_Incident_Addr_Details;

 PROCEDURE Get_SR_Attrs_Details (
    ITEMTYPE       IN VARCHAR2
    , ITEMKEY      IN VARCHAR2
    , INCIDENT_ID IN NUMBER
    , INCIDENT_TYPE_ID IN NUMBER
    , INCIDENT_NUMBER  IN VARCHAR2
    , TASK_NUMBER      IN VARCHAR2
    , X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
 )
 IS

 -- Declaration of all the local variables
    lv_itemtype         VARCHAR2(8);
    lv_itemkey          VARCHAR2(240);
    lv_attr_code   	    VARCHAR2(30);
    lv_attr_name	    VARCHAR2(240);
    lv_attr_value	    VARCHAR2(1997):= NULL;
    str_attr_det        VARCHAR2(4000);
    lv_sr_attrs_det     VARCHAR2(4000);
    lv_incident_number  VARCHAR2(64);
    lv_task_number  	VARCHAR2(30) ;
    lv_incident_id      NUMBER;
    lv_incident_type_id NUMBER;
    lv_wf_item_attr_nm  VARCHAR2(30) := 'CUG_SR_ATTR_DETAILS1';
    lv_item_attr_cnt    NUMBER := 1;
    lv_item_attr_max_cnt NUMBER := 5;
    i                   NUMBER := 0;
    set_Flag            VARCHAR2(1):= 'N';
    lv_incident_name    VARCHAR2(30);

 -- DECLARE a CURSOR to select all the attributes related to that Service  Request
/* Roopa begin - to fix bug 2347352
    This cursor has been changed to also get sr attributes that were
    end-dated AFTER the SR was submitted */
    l_incident_date DATE;

	CURSOR  c_all_sr_attrs_details IS
		SELECT  flv.lookup_code, flv.description
    		FROM 	FND_LOOKUPS flv,
		    	CUG_SR_TYPE_ATTR_MAPS_VL cstamv
    		WHERE	flv.lookup_code = cstamv.sr_attribute_code
    		AND	cstamv.incident_type_id = lv_incident_type_id
    		AND     lookup_type = 'CUG_SR_TYPE_ATTRIBUTES';
--    		AND 	(cstamv.end_date_active is null or
--         		cstamv.end_date_active >= l_incident_date) ;
/* Roopa end - to fix bug 2347352 */


/* Roopa begin - to fix bug 2347352 */


    CURSOR c_get_incident_date IS
        SELECT incident_date
            FROM CS_INCIDENTS_ALL_B
            WHERE INCIDENT_ID = lv_incident_id;

    CURSOR c_get_sr_attr_value IS
		SELECT 	sr_attribute_value
		FROM	CUG_INCIDNT_ATTR_VALS_VL
		WHERE	sr_attribute_code = lv_attr_code
		AND	incident_id	= lv_incident_id ;


/* Roopa end - to fix bug 2347352 */

 BEGIN

    lv_itemtype  := ITEMTYPE;
    lv_itemkey  :=  ITEMKEY;
    lv_incident_id :=  INCIDENT_ID;
    lv_incident_type_id := INCIDENT_TYPE_ID;
    lv_incident_number := INCIDENT_NUMBER;
    lv_task_number := TASK_NUMBER;

        SELECT name
	INTO	lv_incident_name
	FROM	cs_incident_types
	WHERE 	INCIDENT_TYPE_ID = lv_incident_type_id;



    OPEN c_get_incident_date;
    FETCH c_get_incident_date into l_incident_date;
    CLOSE   c_get_incident_date;


	OPEN c_all_sr_attrs_details;
	lv_sr_attrs_det := NULL;
	lv_sr_attrs_det := 'Service Request #' ||' : ' || lv_incident_number || '
';
	lv_sr_attrs_det := lv_sr_attrs_det || 'Service Request Type'||' : ' ||lv_incident_name || '
';
	lv_sr_attrs_det := lv_sr_attrs_det || 'Task #' ||' : ' || lv_task_number || '
';
	LOOP
        i := i + 1 ;
    --  Fetch all the attributes code and name from the cursor.
		FETCH c_all_sr_attrs_details INTO  lv_attr_code, lv_attr_name;
		EXIT WHEN c_all_sr_attrs_details%NOTFOUND;
        lv_attr_value := NULL;

    --  CHANGES REQUIRED IN THIS QUERY

/* Roopa begin - to fix bug 2347352 */
-- removed the following explicit select and using a cursor instead to fetch records
--		SELECT 	sr_attribute_value
--		INTO    lv_attr_value
--		FROM	CUG_INCIDNT_ATTR_VALS_VL
--		WHERE	sr_attribute_code = lv_attr_code
--		AND	incident_id	= lv_incident_id ;

        OPEN c_get_sr_attr_value;
        FETCH c_get_sr_attr_value INTO lv_attr_value;
        IF(c_get_sr_attr_value%NOTFOUND) THEN
            null;
        ELSE
/* Roopa end - to fix bug 2347352 */
		str_attr_det := lv_attr_name ||' : ' || lv_attr_value || '
';
		IF ( length(str_attr_det) <= (4000-length(lv_sr_attrs_det))) THEN
			lv_sr_attrs_det := lv_sr_attrs_det || str_attr_det;
            		set_Flag := 'N';
		ELSE
            		wf_engine.SetItemAttrText (
              			ITEMTYPE => lv_itemtype ,
		      		ITEMKEY  => lv_itemkey,
		      		ANAME    => lv_wf_item_attr_nm,
		      		AVALUE   => lv_sr_attrs_det);

           		lv_item_attr_cnt := lv_item_attr_cnt + 1;
			lv_wf_item_attr_nm := 'CUG_SR_ATTR_DETAILS'|| to_char(lv_item_attr_cnt);
			IF ( lv_item_attr_cnt > lv_item_attr_max_cnt ) THEN
				EXIT;
			END IF;
            lv_sr_attrs_det := str_attr_det ;
            set_Flag := 'Y';
		END IF;
/* Roopa begin - to fix bug 2347352 */
		END IF;
        CLOSE c_get_sr_attr_value;
/* Roopa end - to fix bug 2347352 */
	END LOOP;
    	if (set_Flag = 'N' ) then
        	wf_engine.SetItemAttrText (
            		ITEMTYPE => lv_itemtype ,
		  	ITEMKEY  => lv_itemkey,
		  	ANAME    => lv_wf_item_attr_nm,
		  	AVALUE   => lv_sr_attrs_det);
        end if;
	CLOSE c_all_sr_attrs_details;
    return;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR ;
            return;
End Get_SR_Attrs_Details;

PROCEDURE  Set_Reminder_Interval
        (   ITEMTYPE IN VARCHAR2
           ,ITEMKEY IN VARCHAR2
           ,ACTID IN NUMBER
           ,FUNCMODE IN VARCHAR2
           ,RESULTOUT OUT NOCOPY VARCHAR2
         )
 IS
lv_itemtype         VARCHAR2(8);
lv_itemkey          VARCHAR2(240);
lv_task_number      NUMBER;
lv_reminder_interval NUMBER;
lv_uom_type         VARCHAR2(30);
lv_offset_value     NUMBER;
lv_conversion_rate  NUMBER;

begin

  lv_itemtype  := ITEMTYPE ;
  lv_itemkey   := ITEMKEY;

  IF (  funcmode = 'RUN' ) THEN
        lv_reminder_interval := wf_engine.getItemAttrNumber (
                    			ITEMTYPE => lv_itemtype,
				    	ITEMKEY => lv_itemkey,
				    	ANAME => 'CUG_REMINDER_INTERVAL');

        if ( lv_reminder_interval is NULL ) then

            -- Get the UOM Type from the 'Email Notification' workflow
            lv_uom_type := wf_engine.getItemAttrText (
                    		ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME => 'CUG_UOM_DUE_DATE');

            -- Get the Offset Value for the calculation of the due Date from
  	    -- 'Email Notification' workflow
            lv_offset_value := wf_engine.getItemAttrText (
                    		ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME => 'CUG_OFFSET_DUE_DATE');

            -- get the Conversion rate for the given UOM Type
            select  conversion_rate
            into    lv_conversion_rate
            from  mtl_uom_conversions
            where uom_class='Time'
            and inventory_item_id=0
            and upper(unit_of_measure)=upper(lv_uom_type);

            -- Calculate the Reminder Interval and set that Item Attribute
	    -- 'CUG_REMINDER_INTERVAL' in the Workflow.

            lv_reminder_interval := (lv_conversion_rate * lv_offset_value * 60);
            wf_engine.SetItemAttrNumber(
                    ITEMTYPE => lv_itemtype ,
				ITEMKEY => lv_itemkey,
				ANAME => 'CUG_REMINDER_INTERVAL',
				AVALUE => lv_reminder_intervaL );

            RESULTOUT :=  'COMPLETE:';
            return;
        end if;
    End if;
EXCEPTION
    When NO_DATA_FOUND Then
	wf_engine.SetItemAttrNumber(
        	ITEMTYPE => lv_itemtype ,
                ITEMKEY => lv_itemkey,
                ANAME => 'CUG_REMINDER_INTERVAL',
                AVALUE => 0 );
        RESULTOUT :=   'COMPLETE:';
        return;
   When Others then
        WF_CORE.context('CUG_WF_EMAIL_UTIL', 'SET_REMINDER_INTERVAL', itemtype, itemkey, actid, funcmode );
        RAISE;

End Set_Reminder_Interval;

PROCEDURE Check_For_CIC_SR
 (   ITEMTYPE IN VARCHAR2    -- Workflow Item Type := 'JTFTASKS'
    ,ITEMKEY IN VARCHAR2 	 -- to_char(p_task_id)||'-'||to_char(l_wf_process_id)
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY  VARCHAR2
  )IS
  lv_itemtype                   VARCHAR2(8);
  lv_itemkey                    VARCHAR2(240);
  lv_task_number                VARCHAR2(30);
  lv_task_id                    NUMBER;
  lv_task_type_id               NUMBER;
  lv_source_object_type_code    VARCHAR2(30);
  lv_task_attr_cnt              NUMBER := 0;

Begin
    lv_itemtype := itemtype;
    lv_itemkey  := itemkey;


    IF ( funcmode = 'RUN' ) THEN
        -- Get the Service Request Id by using the GetItemAttr function for 'TASK_ID' and then
        -- execute a SQL query to find out the source_object_id from JTF_TASKS_VL view for the

	    lv_task_number := wf_engine.GetItemAttrText(
                    		ITEMTYPE => lv_itemtype,
				ITEMKEY => lv_itemkey,
				ANAME => 'TASK_NUMBER' );

        -- Make sure by putting specific check that it will execute only for EMAIL NOTIFICATION TASK TYPE
        -- for a given Service Request
          select jtv.task_id, jtv.task_type_id, jtv.source_object_type_code
          into   lv_task_id, lv_task_type_id, lv_source_object_type_code
          from   cs_incidents_all_b ciav,
                 jtf_tasks_b jtv
          where  ciav.incident_id = jtv.source_object_id
          and    jtv.task_number = lv_task_number;

        if (lv_source_object_type_code = 'SR' ) then
           select count(*)
           into lv_task_attr_cnt
           from cug_tsk_typ_attr_maps_b
           where task_type_id=lv_task_type_id;

           if (lv_task_attr_cnt > 0) then
            RESULTOUT := 'COMPLETE:Y' ;
            return ;
           end if;
        end if;
         RESULTOUT := 'COMPLETE:N';
          RETURN;
    end if;

    EXCEPTION
        When NO_DATA_FOUND then
            RESULTOUT := 'COMPLETE:N';
            RETURN;
        When OTHERS then
            WF_CORE.context('CUG_WF_EMAIL_UTIL', 'Check_For_CIC_SR', itemtype, itemkey, actid, funcmode );
            RAISE;
   End Check_For_CIC_SR;



------------------------------------------------------------
-- Procedure name : Set_Email_status
--
-- Parameters
-- IN
--   p_source_type: Source Type
--   ITEMTYPE     : Workflow Item Type
--   ITEMKEY      : Workflow Item Key
--   ACTID        : Action ID
--   FUNCMODE     : Function Mode
--
-- OUT
--   RESULTOUT    : Return result
--
--
-- Description    : This procedure checks the return action for the notification set
--                  and updates the task with either success or failure.
--
-- Modification History :
-- Date        Name       Desc
-- ----------  ---------  ----------------------------------
-- 04/13/2004  PSKANNAN   Created.
-- 05/16/2005  ANEEMUCH   Fixed bug 4323360. CUG Task Success and Failure profile stored
--                        translatable values instead of ID's. Change in profile, to store
--                        id, resulted change in this procedure.
-- ------------------------------------------------------------


   PROCEDURE Set_Email_status
 (   ITEMTYPE IN VARCHAR2    -- Workflow Item Type := 'JTFTASKS'
    ,ITEMKEY IN VARCHAR2 	 -- to_char(p_task_id)||'-'||to_char(l_wf_process_id)
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY VARCHAR2
  )IS

  lv_itemtype                   VARCHAR2(8);
  lv_itemkey                    VARCHAR2(240);
  lv_task_number                VARCHAR2(30);
  lv_activity_result_code       VARCHAR2(30);
  lv_result_code                VARCHAR2(30);
  lv_source_object_id           NUMBER;
  lv_task_id                    NUMBER;
  lv_source_object_type_code    VARCHAR2(60);
  lv_task_status_id             NUMBER;
  lv_object_version_number	NUMBER;
  x_return_status 		VARCHAR2(240);
  x_msg_count 			NUMBER;
  x_msg_data			VARCHAR2(240);
  begin

    lv_itemtype :=  ITEMTYPE;
    lv_itemkey  :=  ITEMKEY;

    IF ( funcmode = 'RUN' ) THEN

    -- Get the Service Request Id by using the GetItemAttr function for 'TASK_ID' and then
    -- execute a SQL query to find out the source_object_id from JTF_TASKS_VL view for the
	   lv_task_number := wf_engine.GetItemAttrText(
          ITEMTYPE => lv_itemtype,
		  ITEMKEY => lv_itemkey,
		  ANAME => 'TASK_NUMBER' );

        -- Find out the SOURCE_OBJECT_ID, TASK_ID, SOURCE_OBJECT_TYPE_CODE
        -- and OBJECT_VERSION_NUMBER for a given TASK_NUMBER
        select  jtb.source_object_id , jtb.task_id,
		jtb.source_object_type_code, jtb.object_version_number
        into    lv_source_object_id  , lv_task_id ,
		lv_source_object_type_code, lv_object_version_number
        from    JTF_TASKS_B jtb
        where   jtb.TASK_NUMBER= lv_task_number;

        begin
            select  ACTIVITY_RESULT_CODE
            into    lv_activity_result_code
            from    wf_item_activity_statuses
            where   item_type = lv_itemtype
            and     item_key  = lv_itemkey
            and     (ACTIVITY_RESULT_CODE = 'CUG_ACKNOWLEDGED' or
                     ACTIVITY_RESULT_CODE = 'N' );

            lv_result_code := 'CUG_COMPLETED';
        exception
            When NO_DATA_FOUND then
                    lv_result_code := 'CUG_CANCELLED';
        end;

	begin
           if (lv_result_code = 'CUG_COMPLETED') then
               -- set value for Successful completition.
             lv_task_status_id := fnd_profile.value('CUG_TASK_SUCCESS_STATUS');

           else
               -- Set value for Failure Competition.
             lv_task_status_id := fnd_profile.value('CUG_TASK_FAILED_STATUS');

           end if;

	   if (lv_task_status_id is null ) then
               WF_CORE.context('CUG_WF_EMAIL_UTIL', 'Set_Email_Status:task_status_id', itemtype, itemkey, actid, funcmode );
	   end if;

        exception
            When NO_DATA_FOUND then
               WF_CORE.context('CUG_WF_EMAIL_UTIL', 'Set_Email_Status:profile_not_set', itemtype, itemkey, actid, funcmode );
               RAISE;
        end;

	x_return_status := fnd_api.g_ret_sts_success ;

        -- Update the status in the

	jtf_tasks_pub.update_task (
			p_api_version => 1.0,
			p_init_msg_list => fnd_api.g_false ,
			p_commit => fnd_api.g_true,
			p_object_version_number => lv_object_version_number ,
			p_task_id => lv_task_id ,
		 	p_task_status_id => lv_task_status_id ,
			x_return_status => x_return_status ,
			x_msg_count => x_msg_count ,
			x_msg_data => x_msg_data );

	IF NOT (x_return_status <> fnd_api.g_ret_sts_success ) THEN
            WF_CORE.context('CUG_WF_EMAIL_UTIL', 'Set_Email_Status:update_task', itemtype, itemkey, actid, funcmode );
	END IF;

        RESULTOUT := 'COMPLETE:';
        return;

     end if;
     exception
            When NO_DATA_FOUND then
             RESULTOUT := 'COMPLETE:';
            RETURN;
        When OTHERS then
            WF_CORE.context('CUG_WF_EMAIL_UTIL', 'Set_Email_Status', itemtype, itemkey, actid, funcmode );
            RAISE;
  end Set_Email_Status;

END;

/
