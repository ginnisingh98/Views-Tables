--------------------------------------------------------
--  DDL for Package Body PN_CAD_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_CAD_IMPORT" AS
  -- $Header: PNVLOSPB.pls 120.12.12010000.4 2008/11/27 05:06:36 rthumma ship $

-------------------------------------------------------------------------------
--  NAME         : IMPORT_CAD
--  DESCRIPTION  : Wrapper Procedure for Import of Locations/Space_Allocations
--                 Data
--  NOTES        : Called from within "Import from CAFM" form
--                 Based on value function_flag, branches off into
--                 locations_itf()  or  space_allocations_itf() procedures below
--  SCOPE        : PRIVATE
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    : IN:  p_Batch_Name
--                      Function_Flag (L for Locations, S for Space)
--                 OUT: Errbuf
--                      RetCode
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :

--  1998         Naga Vijayapuram  o Created
--  1999         Naga Vijayapuram  o Modified - Included Validations
--  12-NOV-02    Kiran Hegde       o Removed all calls to PNP_DEBUG_PKG.
--                                   enable_file_debug().
--  01-APR-05    piagrawa          o Modified the signature to include org_id
--                                   and updated the calls to locations_itf and
--                                   space_allocations_itf to pass org_id as
--                                   argument
-------------------------------------------------------------------------------

PROCEDURE IMPORT_CAD (
  errbuf         OUT NOCOPY VARCHAR2,
  retcode        OUT NOCOPY VARCHAR2,
  p_batch_name   VARCHAR2,
  function_flag  VARCHAR2,
  p_org_id       NUMBER
) IS

    l_filename VARCHAR2(40) := 'IMPORT'||to_char(SYSDATE,'DDMMYYHHMMSS');
    l_org_ID   NUMBER;

BEGIN
  /* init the ORG */
  IF pn_mo_cache_utils.is_MOAC_enabled THEN
    l_org_ID := p_org_ID;
  ELSE
    l_org_ID := fnd_profile.value('ORG_ID');
  END IF;

  IF (function_flag = 'L') then
    BEGIN
      locations_itf(p_batch_name, l_org_ID, errbuf, retcode);
    EXCEPTION
      when OTHERS then
      put_log('at exception');
    END;

  ELSE
    BEGIN
      space_allocations_itf(p_batch_name, l_org_ID, errbuf, retcode);
    EXCEPTION
      when OTHERS then
        APP_EXCEPTION.raise_exception;
    END;

  END IF;

END IMPORT_CAD;


/*=============================================================================+
 | PROCEDURE
 |   Locations_Itf
 |
 | DESCRIPTION
 |   Handles Import of Locations Data
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_Batch_Name
 |   OUT: Errbuf
 |        RetCode
 |
 | NOTES:
 |   Called by IMPORT_CAD Procedure Above
 |
 | MODIFICATION HISTORY
 | Created   Naga Vijayapuram   1998
 | Modified  Naga Vijayapuram   1999  Included Validations
 | 23-APR-02  Kiran Hegde   o Fixed Bug#2324687. Added columns Location_Alias,
 |                            Property_Id to PN_LOCATIONS_ITF. Modified the
 |                            Inserts and Updates. Added function
 |                            Exists_Property_Id for validating Property_id.
 |                            Added validations for Locations_Alias.
 | 08-MAY-02  Kiran Hegde   o Fixed Bug#2341761. Added column
 |                            Standard_Type_Lookup_Code to PN_LOCATIONS_ITF.
 |                            Modified inserts and updates appropriately.
 |                            Changed the validations of Usable, Rentable,
 |                            Assignable to match the validations in the form
 | 14-MAY-02  Kiran Hegde   o Added validations to Locations_Itf to behave
 |                            similar to the forms for Assgn and Common Area
 | 12-nov-02  Kiran Hegde   o Removed all calls to enable_file_debug().
 | 22-JAN-03  MRinal Misra  o Put a check for rentable area must not be
 |                            greater than gross area of parent and displayed
 |                            msg. PN_GROSS_RENTABLE in log.
 | 24-JAN-03  Kiran         o Made several changes to Locations_Itf procedure
 |                            1. Added validations for Active Start Date and
 |                               End date to behave like the Locations form.
 |                            2. Removed rollback from exception handling
 |                            3. Added validations for a valid combination of
 |                               Id and Code for Locations.
 |                            4. Changed several messages
 | 07-AUG-03  Kiran         o Populated the Addresses %ROWTYPE variable
 |                            before passing it to PNT_LOCATIONS_PKG.
 |                            correct_update_row. Removd explicit update
 |                            statements to update pn_addresses_all. Bug #
 |                            3079433. Changed 'IF' condition for calling
 |                            validate_gross_area in 'COrrect' and 'Update'
 |                            mode.
 | 07-JAN-04  Daniel Thota  o Added OUT param l_total_allocated_area_pct
 |                            in call to pnp_util_func.get_allocated_area
 |                            bug # 3354278
 | 01-APR-05  piagrawa      o Modified the signature to include org_id,
 |                            Modified the select statements to retrieve values
 |                            from _ALL tables and in INSERT_ROW call passed
 |                            the value of p_org_id in place of
 |                            fnd_profile.value('ORG_ID')
 | 14-JUL-05  piagrawa      o passed org id in call to Is_Id_Code_Valid
 | 27-JUL-05 SatyaDeep      o Added a check for office/section in the call to
 |                            PNT_LOCATIONS_PKG.check_location_gaps for Bug#4503407
 | 27-JUL-05 SatyaDeep      o Added validation for NEW_ACTIVE_START_DATE
 |                            and NEW_ACTIVE_END_DATE for Bug#4503407
 | 23-NOV-05 Hareesha       o Fetched org_id using cursor
 | 01-DEC-05 Pikhar         o Passed org_id in
 |                            PNT_LOCATIONS_PKG.check_unique_building_alias
 | 26-Nov-08 rthumma        o Bug 6670882 : Modified to do a commit after the
 |                            processing loop.
 | 27-Nov-08 rthumma        o Bug 6861678 : Selected the occupancy_status_code
 |                            of the parent_location in cursor loccur to
 |                            set the occupancy_status_code for the child.
 +===========================================================================*/

PROCEDURE LOCATIONS_ITF (
  p_batch_name             VARCHAR2,
  p_org_id           NUMBER,
  errbuf       OUT NOCOPY  VARCHAR2,
  retcode      OUT NOCOPY  VARCHAR2
)
IS
l_succ             NUMBER          DEFAULT 0;
l_fail             NUMBER          DEFAULT 0;
l_total            NUMBER          DEFAULT 0;
l_returnStatus     VARCHAR2(30)    DEFAULT NULL;
l_return_message   VARCHAR2(32767) := NULL;
l_total_for_commit NUMBER          DEFAULT 0; -- Bug 6670882
l_occ_status       varchar2(1) := '';   /* Bug 6861678  */

CURSOR loccur IS
  SELECT  pli.*, pli.rowid,occupancy_status_code
  FROM PN_LOCATIONS_ITF pli,
       PN_LOCATIONS_ALL pnl
  WHERE pli.parent_location_id = pnl.location_id(+)
  AND pli.batch_name  = p_batch_name
  AND   pli.transferred_to_pn IS NULL
  ORDER BY pli.location_type_lookup_code, pli.active_start_date;

l_address_id           NUMBER;
l_error_message        VARCHAR2(512);
l_retcode              VARCHAR2(1);
l_rowid                VARCHAR2(30);
l_as_of_date           DATE := SYSDATE;
l_allocated_area       NUMBER;
l_allocated_area_pct   NUMBER;
l_future               VARCHAR2(1);
l_asgn_area_chng_flag  VARCHAR2(1);

INVALID_RECORD         EXCEPTION;
DELETE_RECORD          EXCEPTION;

l_last_update_date     DATE;
l_location_id          NUMBER;
l_loc_id               NUMBER;
v_loc_rec              PN_LOCATIONS%ROWTYPE;
v_addr_rec             PN_ADDRESSES%ROWTYPE;
l_act_str_dt           DATE;
l_pn_locations_rec     PN_LOCATIONS_ALL%ROWTYPE;
l_pn_addresses_rec     PN_ADDRESSES_ALL%ROWTYPE;
l_active_start_date    DATE;
l_active_end_date      DATE;
l_filename             VARCHAR2(50) := 'IMPORT_'||to_char(sysdate,'DDMMYYYYHHMMSS');
l_org_id               NUMBER;

BEGIN

IF pn_mo_cache_utils.is_MOAC_enabled AND p_org_id IS NULL THEN
  l_org_id := pn_mo_cache_utils.get_current_org_id;
ELSE
  l_org_id := p_org_id;
END IF;

retcode := '0';

FOR loc in loccur LOOP

  l_total := l_total + 1;
  l_total_for_commit := l_total_for_commit + 1; -- Bug 6670882
  l_occ_status := loc.occupancy_status_code; -- Bug 6861678

  BEGIN
    Put_Log('=============== Record #: ' || l_total || ' ===============');

    --------------------
    -- Set save point --
    --------------------
    put_log('Setting the save point');
    SAVEPOINT S1;

    Put_Log('Validate Entry Types');
    ------------------------------
    -- Validate Entry Types
    ------------------------------
    if (loc.ENTRY_TYPE not in ('A', 'U','R')) then   --added the 'R' for fix BUG#2127286
      fnd_message.set_name('PN', 'PN_CAFM_LOCATION_ENTRY_TYPE');
      fnd_message.set_token('LOCATION_ID', loc.LOCATION_ID);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Location Type Lookup_Code');
    --------------------------------------
    -- Validate Location Type Lookup_Code
    --------------------------------------
    if (NOT PNP_UTIL_FUNC.valid_lookup_code(
    'PN_LOCATION_TYPE', loc.LOCATION_TYPE_LOOKUP_CODE)) then
      fnd_message.set_name('PN', 'PN_CAFM_LOCATION_TYPE');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    ------------------------------------------------------------------
    -- NOTE: If we are here, it means we are handling INSERT/UPDATE --
    -- The entry type, locations type are both fine                 --
    ------------------------------------------------------------------

    put_log('Validate BUILDING/LAND');
    --------------------------------------
    -- Validate BUILDING/LAND
    --------------------------------------
    if (loc.LOCATION_TYPE_LOOKUP_CODE  IN ( 'BUILDING', 'LAND' ) and
    loc.BUILDING is NULL) then
      fnd_message.set_name('PN', 'PN_CAFM_BUILDING');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate FLOOR/PARCEL');
    --------------------------------------
    -- Validate FLOOR/PARCEL
    --------------------------------------
    if (loc.LOCATION_TYPE_LOOKUP_CODE IN ( 'FLOOR' , 'PARCEL' ) and
    loc.FLOOR is NULL) then
      fnd_message.set_name('PN', 'PN_CAFM_FLOOR');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate OFFICE/SECTION');
    --------------------------------------
    -- Validate OFFICE/SECTION
    --------------------------------------
    if (loc.LOCATION_TYPE_LOOKUP_CODE IN ( 'OFFICE' , 'SECTION' ) and
     loc.OFFICE is NULL) then
      fnd_message.set_name('PN', 'PN_CAFM_OFFICE');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Space Type Lookup_Code');
    --------------------------------------
    -- Validate Space Type Lookup_Code
    --------------------------------------
    IF (loc.LOCATION_TYPE_LOOKUP_CODE IN ('OFFICE','FLOOR' )) THEN
      if (loc.SPACE_TYPE_LOOKUP_CODE is NOT NULL and
         NOT PNP_UTIL_FUNC.valid_lookup_code(
           'PN_SPACE_TYPE', loc.SPACE_TYPE_LOOKUP_CODE)) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_TYPE');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    END IF;

    put_log('Validate Parcel Type Lookup_Code');
    --------------------------------------
    -- Validate Parcel Type Lookup_Code
    --------------------------------------
    IF (loc.LOCATION_TYPE_LOOKUP_CODE IN ('PARCEL','SECTION' )) THEN
      if (loc.SPACE_TYPE_LOOKUP_CODE is NOT NULL and
         NOT PNP_UTIL_FUNC.valid_lookup_code(
           'PN_PARCEL_TYPE', loc.SPACE_TYPE_LOOKUP_CODE)) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_TYPE');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    END IF;

    put_log('Validate Function Type Lookup_Code');
    --------------------------------------
    -- Validate  Function Type Lookup_Code
    --------------------------------------
    IF (loc.LOCATION_TYPE_LOOKUP_CODE IN ('PARCEL','SECTION','FLOOR','OFFICE' )) THEN
      if (loc.FUNCTION_TYPE_LOOKUP_CODE is NOT NULL and
         NOT PNP_UTIL_FUNC.valid_lookup_code(
         'PN_FUNCTION_TYPE', loc.FUNCTION_TYPE_LOOKUP_CODE)) then
        fnd_message.set_name('PN', 'PN_CAFM_FUNCTION_TYPE');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    END IF;

    put_log('Validate Standard Type Lookup_Code');
    --------------------------------------
    -- Validate  Standard Type Lookup_Code
    --------------------------------------
    IF (loc.LOCATION_TYPE_LOOKUP_CODE IN ('PARCEL','SECTION','FLOOR','OFFICE' )) THEN
      if (loc.STANDARD_TYPE_LOOKUP_CODE is NOT NULL and
         NOT PNP_UTIL_FUNC.valid_lookup_code(
         'PN_STANDARD_TYPE', loc.STANDARD_TYPE_LOOKUP_CODE)) then
        fnd_message.set_name('PN', 'PN_CAFM_STANDARD_TYPE');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    END IF;

    put_log('Validate Parent_Location_Id');
    --------------------------------------
    -- Validate Parent_Location_Id
    --------------------------------------
    IF (loc.LOCATION_TYPE_LOOKUP_CODE IN ( 'BUILDING' , 'LAND' )) AND
      (loc.PARENT_LOCATION_ID is NOT NULL) THEN

      fnd_message.set_name('PN', 'PN_CAFM_BUILDING_PARENT_LOC_ID');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      RAISE INVALID_RECORD;

    ELSIF ((loc.LOCATION_TYPE_LOOKUP_CODE = 'FLOOR'AND
          get_location_type(loc.PARENT_LOCATION_ID) <> 'BUILDING' ) OR
         (loc.LOCATION_TYPE_LOOKUP_CODE = 'PARCEL'AND
          get_location_type(loc.PARENT_LOCATION_ID) <> 'LAND' )) THEN

      fnd_message.set_name('PN', 'PN_CAFM_FLOOR_PARENT_LOC_ID');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      IF loc.LOCATION_TYPE_LOOKUP_CODE = 'FLOOR' THEN
        fnd_message.set_token('FLR_OR_PARCEL', 'floor');
        fnd_message.set_token('BLD_OR_LAND', 'building');
      ELSIF loc.LOCATION_TYPE_LOOKUP_CODE = 'PARCEL' THEN
        fnd_message.set_token('FLR_OR_PARCEL', 'parcel');
        fnd_message.set_token('BLD_OR_LAND', 'land');
      END IF;
      l_error_message := fnd_message.get;
      RAISE INVALID_RECORD;

    ELSIF ((loc.LOCATION_TYPE_LOOKUP_CODE = 'OFFICE'AND
          get_location_type(loc.PARENT_LOCATION_ID) <> 'FLOOR' ) OR
         (loc.LOCATION_TYPE_LOOKUP_CODE = 'SECTION'AND
          get_location_type(loc.PARENT_LOCATION_ID) <> 'PARCEL' )) THEN

      fnd_message.set_name('PN', 'PN_CAFM_OFFICE_PARENT_LOC_ID');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      IF loc.LOCATION_TYPE_LOOKUP_CODE = 'OFFICE' THEN
        fnd_message.set_token('FLR_OR_PARCEL', 'floor');
        fnd_message.set_token('OFF_OR_SECT', 'office');
      ELSIF loc.LOCATION_TYPE_LOOKUP_CODE = 'SECTION' THEN
        fnd_message.set_token('FLR_OR_PARCEL', 'parcel');
        fnd_message.set_token('OFF_OR_SECT', 'section');
      END IF;
      l_error_message := fnd_message.get;
      RAISE INVALID_RECORD;

    END IF;

    put_log('Validate Active_Start_Date');
    -------------------------------------------------
    -- Validate Active_Start_Date
    -------------------------------------------------
    if loc.ACTIVE_START_DATE is NULL then
      fnd_message.set_name('PN', 'PN_CAFM_ACT_ST_DT');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;
    if TRUNC(loc.ACTIVE_START_DATE) >
       TRUNC(NVL(loc.active_end_date,PNT_LOCATIONS_PKG.G_END_OF_TIME)) then
      fnd_message.set_name('PN', 'PN_LOCN_STDT_VALID_MSG');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Active_Start_Date and Active_End_Date wrt the parent Location');
    -------------------------------------------------------------------------
    -- Validate Active_Start_Date and Active_End_Date wrt the parent Location
    -------------------------------------------------------------------------
    if loc.LOCATION_TYPE_LOOKUP_CODE in ('FLOOR', 'OFFICE', 'PARCEL', 'SECTION') then
      select min(active_start_date), nvl(max(active_end_date),PNT_LOCATIONS_PKG.G_END_OF_TIME)
      into l_active_start_date, l_active_end_date
      from pn_locations_all where location_id = loc.PARENT_LOCATION_ID
      group by location_id;

      if trunc(loc.active_start_date) < trunc(l_active_start_date) then
        fnd_message.set_name('PN', 'PN_CAFM_LOC_CHILD_ST_DT');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        fnd_message.set_token('P_LOCATION_ID', loc.parent_location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      elsif trunc(nvl(loc.active_end_date,PNT_LOCATIONS_PKG.G_END_OF_TIME))
          > trunc(l_active_end_date) then
        fnd_message.set_name('PN', 'PN_CAFM_LOC_CHILD_END_DT');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        fnd_message.set_token('P_LOCATION_ID', loc.parent_location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    end if;

    put_log('Validate the combination of id and code');
    ------------------------------------------
    -- Validate the combination of id and code
    ------------------------------------------
    if not (Is_Id_Code_Valid(loc.LOCATION_ID, loc.LOCATION_CODE, l_org_id)) then
      fnd_message.set_name('PN', 'PN_CAFM_LOC_ID_CODE_COMB');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate for Duplicate Building/Land Code');
    --------------------------------------------
    -- Validate for Duplicate Building/Land Code
    --------------------------------------------
    if loc.LOCATION_TYPE_LOOKUP_CODE in ('BUILDING', 'LAND') then
      if not(PNT_LOCATIONS_PKG.check_unique_building_alias(loc.LOCATION_ID,
                                                           loc.LOCATION_CODE,
                                                           loc.LOCATION_TYPE_LOOKUP_CODE,
                                                           l_org_id))
      then
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    end if;

    put_log('Validate Lease_Or_Owned');
    --------------------------------------
    -- Validate Lease_Or_Owned
    --------------------------------------
    if (loc.LEASE_OR_OWNED is NULL) then
      if (loc.ENTRY_TYPE IN ('A', 'U')) then
        loc.LEASE_OR_OWNED  :=  'L';
      end if;
    else
      if (NOT PNP_UTIL_FUNC.valid_lookup_code(
         'PN_LEASED_OR_OWNED', loc.LEASE_OR_OWNED)) then
        fnd_message.set_name('PN', 'PN_CAFM_LEASE_OR_OWNED');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    end if;

    put_log('Validate Country');
    --------------------------------------
    -- Validate Country (Territory)
    --------------------------------------
    if (loc.COUNTRY is NULL) then
      if (loc.ENTRY_TYPE IN ('A', 'U')) then
        loc.COUNTRY  :=  fnd_profile.value('DEFAULT_COUNTRY');
      end if;
    else
      if (NOT PNP_UTIL_FUNC.valid_country_code(loc.COUNTRY)) then
        fnd_message.set_name('PN', 'PN_CAFM_COUNTRY');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;
    end if;

    put_log('Validate Optimum_Capacity');
    --------------------------------------
    -- Validate Optimum_Capacity
    --------------------------------------
    if (loc.optimum_capacity > loc.max_capacity) then
      fnd_message.set_name('PN', 'PN_CAFM_OPTIMUM_CAPACITY');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Setting appropriate areas to null based on lookup type');
    ---------------------------------------------------------
    -- Setting appropriate areas to null based on lookup type
    ---------------------------------------------------------
    if (loc.LOCATION_TYPE_LOOKUP_CODE in ('BUILDING', 'LAND', 'FLOOR', 'PARCEL')) then
      loc.Rentable_Area := null;
      loc.Usable_Area := null;
      loc.Assignable_Area := null;
      loc.Common_Area := null;
    elsif (loc.LOCATION_TYPE_LOOKUP_CODE in ('OFFICE', 'SECTION')) then
      loc.GROSS_AREA := null;
    end if;

    put_log('Validate Usable_Area');
    --------------------------------------
    -- Validate Usable_Area
    --------------------------------------
    if (loc.Usable_Area > loc.Rentable_Area) then
      fnd_message.set_name('PN', 'PN_CAFM_USABLE_AREA');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Assignable_Area');
    --------------------------------------
    -- Validate Assignable_Area
    --------------------------------------
    if (loc.Assignable_Area > loc.Rentable_Area) then
      fnd_message.set_name('PN', 'PN_CAFM_ASSIGNABLE_AREA');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Assignable_Area/Common Area is not null for Offices/Section');

    -------------------------------------------------------------------
    -- Validate Assignable_Area / Common Area is not null for location types 'OFFICE','SECTION'
    -------------------------------------------------------------------
    if (loc.assignable_area is null and
       loc.location_type_lookup_code in ('OFFICE','SECTION') and
       nvl(loc.common_area_flag,'N') = 'N') then
      fnd_message.set_name('PN','PN_CAFM_ASSIGNABLE_REQ');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    if (loc.common_area is null and
       loc.location_type_lookup_code in ('OFFICE','SECTION') and
       loc.common_area_flag = 'Y') then
      fnd_message.set_name('PN','PN_CAFM_COMMON_AREA_REQ');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Common_Area and Assignable_Area');
    -------------------------------------------------------------------
    -- Validate Common_Area and Assignable_Area are mutually exclusive
    -------------------------------------------------------------------
    if (loc.Common_Area is not null and loc.Assignable_Area is not null) then
      fnd_message.set_name('PN', 'PN_CAFM_COMMON_ASSIGNABLE');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate Common_Area');
    --------------------------------------
    -- Validate Common_Area
    --------------------------------------
    if (loc.Common_Area > loc.Rentable_Area) then
      fnd_message.set_name('PN', 'PN_CAFM_COMMON_AREA');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate SOURCE');
    --------------------------------------
    -- Validate SOURCE
    --------------------------------------
    if (NOT PNP_UTIL_FUNC.valid_lookup_code(
         'PN_SOURCE', loc.SOURCE)) then
      fnd_message.set_name('PN', 'PN_CAFM_LOCATION_SOURCE');
      fnd_message.set_token('LOCATION_ID', loc.location_id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    put_log('Validate PROPERTY_ID');
    --------------------------------------
    -- Validate PROPERTY_ID
    --------------------------------------
    if ( NOT EXISTS_PROPERTY_ID( loc.Property_Id ) ) then
      fnd_message.set_name('PN', 'PN_CAFM_INVALID_PROPERTY_ID');
      fnd_message.set_token('PROPERTY_ID', loc.Property_Id);
      l_error_message := fnd_message.get;
      raise INVALID_RECORD;
    end if;

    ---------------------------------------------------------------------------
    -- General validatons all done. Now, we move to the specific validations --
    -- and then to insert/correct/update                                     --
    ---------------------------------------------------------------------------

    put_log('ENTRY_TYPE: --' || loc.ENTRY_TYPE || '--');

    IF (loc.ENTRY_TYPE = 'A') THEN

      put_log('Validate for Rentable area v/s Gross Area');
      --------------------------------------------
      -- Validate for Rentable area v/s Gross Area
      --------------------------------------------
      if loc.LOCATION_TYPE_LOOKUP_CODE in ('OFFICE', 'SECTION') then
        if NOT pnt_locations_pkg.validate_gross_area
               (p_loc_id     => loc.PARENT_LOCATION_ID,
                p_area       => nvl(loc.RENTABLE_AREA,0),
                p_lkp_code   => loc.LOCATION_TYPE_LOOKUP_CODE,
                p_act_str_dt => trunc(loc.ACTIVE_START_DATE),
                p_act_end_dt => trunc(nvl(loc.ACTIVE_END_DATE,
                                    PNT_LOCATIONS_PKG.G_END_OF_TIME))) --Used trunc() :Bug 6009957
        then
          fnd_message.set_name('PN', 'PN_GROSS_RENTABLE');
          fnd_message.set_token('LOCATION_ID', loc.location_id);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
        end if;
      end if;

      --------------------------------------
      -- Insert Data into PN_LOCATIONS
      --------------------------------------
      put_log( 'Just before Insert');

      BEGIN

        l_address_id := NULL;
        PNT_LOCATIONS_PKG.INSERT_ROW (
           x_rowid                           => l_rowid
           ,x_org_id                         => l_org_id
           ,x_LOCATION_ID                    => loc.location_id
           ,x_LAST_UPDATE_DATE               => sysdate
           ,x_LAST_UPDATED_BY                => fnd_global.user_id
           ,x_CREATION_DATE                  => sysdate
           ,x_CREATED_BY                     => fnd_global.user_id
           ,x_LAST_UPDATE_LOGIN              => fnd_global.user_id
           ,x_LOCATION_PARK_ID               => NULL
           ,x_LOCATION_TYPE_LOOKUP_CODE      => loc.location_type_lookup_code
           ,x_SPACE_TYPE_LOOKUP_CODE         => loc.space_type_lookup_code
           ,x_FUNCTION_TYPE_LOOKUP_CODE      => loc.function_type_lookup_code
           ,x_STANDARD_TYPE_LOOKUP_CODE      => loc.standard_type_lookup_code
           ,x_LOCATION_ALIAS                 => loc.location_alias
           ,x_LOCATION_CODE                  => loc.location_code
           ,x_BUILDING                       => loc.building
           ,x_LEASE_OR_OWNED                 => loc.lease_or_owned
           ,x_CLASS                          => loc.class
           ,x_STATUS_TYPE                    => loc.status_type
           ,x_FLOOR                          => loc.floor
           ,x_OFFICE                         => loc.office
           ,x_MAX_CAPACITY                   => loc.max_capacity
           ,x_OPTIMUM_CAPACITY               => loc.optimum_capacity
           ,x_GROSS_AREA                     => loc.gross_area
           ,x_RENTABLE_AREA                  => loc.rentable_area
           ,x_USABLE_AREA                    => loc.usable_area
           ,x_ASSIGNABLE_AREA                => loc.assignable_area
           ,x_COMMON_AREA                    => loc.common_area
           ,x_SUITE                          => loc.suite
           ,x_ALLOCATE_COST_CENTER_CODE      => loc.allocate_cost_center_code
           ,x_UOM_CODE                       => loc.uom_code
           ,x_DESCRIPTION                    => NULL
           ,x_PARENT_LOCATION_ID             => loc.parent_location_id
           ,x_INTERFACE_FLAG                 => NULL
           ,x_request_id                     => nvl(fnd_profile.value('CONC_REQUEST_ID'), 0)
           ,x_PROGRAM_ID                     => nvl(fnd_profile.value('CONC_PROGRAM_APPLICATION_ID'), 0)
           ,x_PROGRAM_APPLICATION_ID         => nvl(fnd_profile.value('CONC_PROGRAM_ID'), 0)
           ,x_PROGRAM_UPDATE_DATE            => SYSDATE
           ,x_STATUS                         => 'A'
           ,x_PROPERTY_ID                    => loc.property_id
           ,x_ATTRIBUTE_CATEGORY             => loc.attribute_category
           ,x_ATTRIBUTE1                     => loc.attribute1
           ,x_ATTRIBUTE2                     => loc.attribute2
           ,x_ATTRIBUTE3                     => loc.attribute3
           ,x_ATTRIBUTE4                     => loc.attribute4
           ,x_ATTRIBUTE5                     => loc.attribute5
           ,x_ATTRIBUTE6                     => loc.attribute6
           ,x_ATTRIBUTE7                     => loc.attribute7
           ,x_ATTRIBUTE8                     => loc.attribute8
           ,x_ATTRIBUTE9                     => loc.attribute9
           ,x_ATTRIBUTE10                    => loc.attribute10
           ,x_ATTRIBUTE11                    => loc.attribute11
           ,x_ATTRIBUTE12                    => loc.attribute12
           ,x_ATTRIBUTE13                    => loc.attribute13
           ,x_ATTRIBUTE14                    => loc.attribute14
           ,x_ATTRIBUTE15                    => loc.attribute15
           ,x_address_id                     => l_address_id
           ,x_address_line1                  => loc.address_line1
           ,x_address_line2                  => loc.address_line2
           ,x_address_line3                  => loc.address_line3
           ,x_address_line4                  => loc.address_line4
           ,x_county                         => loc.county
           ,x_city                           => loc.city
           ,x_state                          => loc.state
           ,x_province                       => loc.province
           ,x_zip_code                       => loc.zip_code
           ,x_country                        => loc.country
           ,x_territory_id                   => NULL
           ,x_addr_last_update_date          => SYSDATE
           ,x_addr_last_updated_by           => FND_GLOBAl.USER_ID
           ,x_addr_creation_date             => SYSDATE
           ,x_addr_created_by                => FND_GLOBAL.USER_ID
           ,x_addr_last_update_login         => FND_GLOBAL.USER_ID
           ,x_addr_attribute_category        => loc.addr_attribute_category
           ,x_addr_attribute1                => loc.addr_attribute1
           ,x_addr_attribute2                => loc.addr_attribute2
           ,x_addr_attribute3                => loc.addr_attribute3
           ,x_addr_attribute4                => loc.addr_attribute4
           ,x_addr_attribute5                => loc.addr_attribute5
           ,x_addr_attribute6                => loc.addr_attribute6
           ,x_addr_attribute7                => loc.addr_attribute7
           ,x_addr_attribute8                => loc.addr_attribute8
           ,x_addr_attribute9                => loc.addr_attribute9
           ,x_addr_attribute10               => loc.addr_attribute10
           ,x_addr_attribute11               => loc.addr_attribute11
           ,x_addr_attribute12               => loc.addr_attribute12
           ,x_addr_attribute13               => loc.addr_attribute13
           ,x_addr_attribute14               => loc.addr_attribute14
           ,x_addr_attribute15               => loc.addr_attribute15
           ,x_COMMON_AREA_FLAG               => loc.common_area_flag
           ,x_ACTIVE_START_DATE              => trunc(nvl(loc.active_start_date,PNT_LOCATIONS_PKG.G_START_OF_TIME))--Used trunc() :Bug 6009957
           ,x_ACTIVE_END_DATE                => trunc(nvl(loc.active_end_date ,PNT_LOCATIONS_PKG.G_END_OF_TIME))--Used trunc() :Bug 6009957
           ,x_occupancy_status_code          => l_occ_status  /* Bug 6861678 */
           ,x_change_mode                    => nvl(loc.change_mode,'INSERT')
           ,x_return_status                  => l_returnstatus
           ,x_return_message                 => l_return_message
           ,x_bookable_flag                  => null
           ,x_source                         => loc.source);

        IF NOT( l_returnstatus = FND_API.G_RET_STS_SUCCESS) THEN
          l_error_message := fnd_message.get;
          pnp_debug_pkg.log(l_error_message);
          raise INVALID_RECORD;
        END IF;

      EXCEPTION

        WHEN OTHERS THEN
          l_error_message := fnd_message.get;
          pnp_debug_pkg.log(l_error_message);
          pnp_debug_pkg.log(sqlerrm);
          raise INVALID_RECORD;

      END;

      put_log('Just after Insert');

    ELSIF (loc.ENTRY_TYPE IN ('U', 'R')) THEN

      pnp_debug_pkg.log('change date: ' || loc.change_date);
      pnp_debug_pkg.log('location: ' || loc.location_id);

      --------------------------------------
      -- Get the record to correct/update --
      --------------------------------------
      BEGIN
        select *
        into   v_loc_rec
        from   PN_LOCATIONS_ALL
        where  LOCATION_ID = loc.location_id
        and    location_code = loc.location_code
        and    active_Start_date = trunc(loc.active_start_date)
        and    active_End_date = trunc(nvl(loc.active_end_date, PNT_LOCATIONS_PKG.G_END_OF_TIME));
   --Used trunc() :Bug 6009957

      EXCEPTION
        WHEN no_data_found THEN
          fnd_message.set_name('PN', 'PN_CAFM_LOC_REC_NOT_FOUND_UPD');
          fnd_message.set_token('LOCATION_ID', loc.location_id);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
      END;

      --------------------------------------
      -- If building/land, get address    --
      --------------------------------------
      pnp_debug_pkg.log('Address id = '|| v_loc_rec.address_id);
      if (loc.location_type_lookup_code IN ( 'BUILDING' , 'LAND' ))
         and v_loc_rec.address_id IS NOT NULL then

         BEGIN
           select *
           into   v_addr_rec
           from   pn_addresses_all
           where  address_id = v_loc_rec.address_id;
           l_address_id := v_addr_rec.address_id;
         EXCEPTION
           WHEN no_data_found THEN
             fnd_message.set_name('PN', 'PN_CAFM_LOC_REC_NOT_FOUND_UPD');
             fnd_message.set_token('LOCATION_ID', loc.location_id);
             l_error_message := fnd_message.get;
             raise INVALID_RECORD;
         END;

      end if;

      put_log('Validate New_Active_Start/End_Date');
      -------------------------------------------------
      -- Validate New_Active_Start/End_Date
      -------------------------------------------------
      IF NVL(loc.new_active_start_date, loc.active_start_date)
         > NVL(loc.new_active_end_date, loc.active_end_date) THEN
         fnd_message.set_name('PN', 'PN_LOCN_ENDT_VALID_MSG');
         fnd_message.set_token('LOCATION_ID', loc.location_id);
         l_error_message := fnd_message.get;
         RAISE INVALID_RECORD;
      END IF;

      put_log('Validate if the start - end dates need to be changed');
      -------------------------------------------------------------------
      -- Check if the new start - end dates are null                   --
      -- If not null, then we need to repeat the form leve validations --
      -------------------------------------------------------------------

      IF loc.new_active_start_date IS NOT NULL OR
         loc.new_active_end_date IS NOT NULL THEN
        -------------------------
        -- set the ROWID first --
        -------------------------
        PNT_LOCATIONS_PKG.SET_ROWID(
          p_location_id       => v_loc_rec.location_id,
          p_active_start_date => trunc(v_loc_rec.active_start_date), --Used trunc() :Bug 6009957
          p_active_end_date   => trunc(v_loc_rec.active_end_date), --Used trunc() :Bug 6009957
          x_return_status     => l_returnstatus,
          x_return_message    => l_return_message);

        put_log('Check for location overlaps');
        ---------------------------------
        -- check for location overlaps --
        ---------------------------------
        PNT_LOCATIONS_PKG.check_location_overlap (
          p_org_id                    => v_loc_rec.org_id,
          p_location_id               => v_loc_rec.location_id,
          p_location_code             => v_loc_rec.location_code,
          p_location_type_lookup_code => v_loc_rec.location_type_lookup_code,
        --Used trunc() :Bug 6009957
          p_active_start_date         => trunc(NVL(loc.new_active_start_date,
                                             v_loc_rec.active_start_date)),
          p_active_end_date           => trunc(NVL(loc.new_active_end_date,
                                             v_loc_rec.active_end_date)),
          p_active_start_date_old     => trunc(v_loc_rec.active_start_date),
          p_active_end_date_old       => trunc(v_loc_rec.active_end_date),
          x_return_status             => l_returnstatus,
          x_return_message            => l_return_message);

        if NOT ( l_returnStatus = FND_API.G_RET_STS_SUCCESS) then
          l_error_message := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_return_message);
          raise INVALID_RECORD;
        end if;

        put_log('Check for location gaps');
        -----------------------------
        -- check for location gaps --
        -----------------------------
        IF v_loc_rec.location_type_lookup_code NOT IN ('OFFICE', 'SECTION') THEN
          PNT_LOCATIONS_PKG.check_location_gaps  (
          p_org_id                    => v_loc_rec.org_id,
          p_location_id               => v_loc_rec.location_id,
          p_location_code             => v_loc_rec.location_code,
          p_location_type_lookup_code => v_loc_rec.location_type_lookup_code,
        --Used trunc() :Bug 6009957
          p_active_start_date         => trunc(NVL(loc.new_active_start_date,
                                             v_loc_rec.active_start_date)),
          p_active_end_date           => trunc(NVL(loc.new_active_end_date,
                                             v_loc_rec.active_end_date)),
          p_active_start_date_old     => trunc(v_loc_rec.active_start_date),
          p_active_end_date_old       => trunc(v_loc_rec.active_end_date),
          x_return_status             => l_returnstatus,
          x_return_message            => l_return_message);
        END IF;

        if NOT ( l_returnStatus = FND_API.G_RET_STS_SUCCESS) then
          l_error_message := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_return_message);
          raise INVALID_RECORD;
        end if;

        put_log('Check for active tenancies while bringing in the dates');
        ------------------------------------------------------------
        -- check if there exist tenancies while bringing in dates --
        ------------------------------------------------------------
        IF loc.new_active_start_date IS NOT NULL THEN
        --Used trunc() :Bug 6009957
          IF (trunc(loc.new_active_start_date) > trunc(v_loc_rec.active_start_date)) AND
             PNP_UTIL_FUNC.exist_tenancy_for_start_date
                         (loc.location_id,
                          trunc(loc.new_active_start_date)) THEN
            -- set msg based on loc type
            IF loc.location_type_lookup_code IN ('OFFICE', 'SECTION') THEN
              fnd_message.set_name('PN', 'PN_OFF_TEN_START_DATE');
            ELSE
              fnd_message.set_name('PN', 'PN_LOC_TEN_START_DATE');
            END IF;
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;
          END IF;
        END IF;

        IF loc.new_active_end_date IS NOT NULL THEN
        --Used trunc() :Bug 6009957
          IF (trunc(loc.new_active_end_date) < trunc(v_loc_rec.active_end_date)) AND
             PNP_UTIL_FUNC.exist_tenancy_for_end_date
                         (loc.location_id,
                          trunc(loc.new_active_end_date)) THEN
            -- set msg based on loc type
            IF loc.location_type_lookup_code IN ('OFFICE', 'SECTION') THEN
              fnd_message.set_name('PN', 'PN_OFF_TEN_END_DATE');
            ELSE
              fnd_message.set_name('PN', 'PN_LOC_TEN_END_DATE');
            END IF;
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;
          END IF;
        END IF;

      END IF; -- new date validations

      put_log('Validate change_date');
      -----------------------------
      -- Validate p_as_of_date
      -----------------------------
      IF ( (nvl(loc.change_mode,'CORRECT') = 'UPDATE') and
              loc.change_date is NULL )  THEN
        fnd_message.set_name('PN', 'PN_CAFM_INVALID_CHANGE_DATE');
        fnd_message.set_token('FIELD_NAME', 'Change Date');
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      END IF;

    --Used trunc() :Bug 6009957
      IF (nvl(loc.change_mode,'CORRECT') = 'UPDATE') AND
         ((loc.CHANGE_DATE < trunc(NVL(loc.new_active_start_date,
                                 v_loc_rec.active_start_date))) OR
         (loc.CHANGE_DATE >  trunc(NVL(loc.new_active_end_date,
                                 v_loc_rec.active_end_date)))) THEN
        fnd_message.set_name('PN', 'PN_LOC_SPILT_DATE_MSG');
        fnd_message.set_token('LOCATION_ID', loc.LOCATION_ID);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      END IF;

      put_log('Validate for Rentable area v/s Gross Area');
      --------------------------------------------
      -- Validate for Rentable area v/s Gross Area
      --------------------------------------------
      -- init the active start - end dates for Area Validations

      --Used trunc() :Bug 6009957
      IF NVL(loc.change_mode, 'CORRECT') = 'UPDATE' THEN
        l_active_start_date := trunc(loc.change_date);
      ELSE
        l_active_start_date := trunc(NVL(loc.new_active_start_date,
                                   v_loc_rec.active_start_date));
      END IF;
      l_active_end_date := trunc(NVL(loc.new_active_end_date,
                              v_loc_rec.active_end_date));

      IF loc.LOCATION_TYPE_LOOKUP_CODE IN ('OFFICE', 'SECTION') AND
         loc.RENTABLE_AREA IS NOT NULL THEN

         IF NOT pnt_locations_pkg.validate_gross_area
                (p_loc_id     => loc.PARENT_LOCATION_ID,
                 p_area       => (NVL(v_loc_rec.RENTABLE_AREA,0)
                                  - NVL(loc.RENTABLE_AREA,0)),
                 p_lkp_code   => loc.LOCATION_TYPE_LOOKUP_CODE,
                 p_act_str_dt => l_active_start_date,
                 p_act_end_dt => l_active_end_date)
         THEN
            fnd_message.set_name('PN', 'PN_GROSS_RENTABLE');
            fnd_message.set_token('LOCATION_ID', loc.location_id);
            l_error_message := fnd_message.get;
            raise INVALID_RECORD;
         END IF;

      ELSIF loc.LOCATION_TYPE_LOOKUP_CODE in ('BUILDING', 'LAND') AND
         loc.GROSS_AREA IS NOT NULL THEN

         IF NOT pnt_locations_pkg.validate_gross_area
                (p_loc_id     => loc.LOCATION_ID,
                 p_area       => nvl(loc.GROSS_AREA,0),
                 p_lkp_code   => loc.LOCATION_TYPE_LOOKUP_CODE,
                 p_act_str_dt => l_active_start_date,
                 p_act_end_dt => l_active_end_date)
         THEN
           fnd_message.set_name('PN', 'PN_GROSS_VALIDATE');
           fnd_message.set_token('LOCATION_ID', loc.location_id);
           l_error_message := fnd_message.get;
           raise INVALID_RECORD;
         END IF;

      END IF;

      put_log('Validating if Assignments exist for making Assignable area Common');
      --------------------------------------------------------------------
      -- Validating if Assignments exist for making Assignable area Common
      --------------------------------------------------------------------
      IF ( NVL(loc.common_area_flag,'N') = 'Y' AND
           NVL(v_loc_rec.common_area_flag,'N') = 'N' AND
           PNP_UTIL_FUNC.get_space_assigned_status(
                         v_loc_rec.location_id,
                         l_active_start_date))
      THEN
        fnd_message.set_name('PN', 'PN_ASSIGNMENTS_EXIST');
        fnd_message.set_token('LOCATION_ID', loc.location_id);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      END IF;

      ---------------------------------------
      -- init assignable area changed flag --
      ---------------------------------------
      IF NVL(loc.assignable_area,0)
         <> NVL(v_loc_rec.assignable_area,0) THEN
         l_asgn_area_chng_flag := 'Y';
      ELSE
         l_asgn_area_chng_flag := 'N';
      END IF;

      IF (loc.ENTRY_TYPE = 'U') THEN

        BEGIN
          l_active_end_date := trunc(v_loc_rec.active_end_date); --Used trunc() :Bug 6009957

          l_pn_locations_rec.location_id                   := loc.location_id;
          l_pn_locations_rec.ORG_ID                        := l_org_id;
          l_pn_locations_rec.LOCATION_TYPE_LOOKUP_CODE     := loc.location_type_lookup_code;
          l_pn_locations_rec.SPACE_TYPE_LOOKUP_CODE        := loc.space_type_lookup_code;
          l_pn_locations_rec.LAST_UPDATE_DATE              := sysdate;
          l_pn_locations_rec.PARENT_LOCATION_ID            := loc.parent_location_id;
          l_pn_locations_rec.LEASE_OR_OWNED                := loc.lease_or_owned;
          l_pn_locations_rec.BUILDING                      := loc.building;
          l_pn_locations_rec.FLOOR                         := loc.floor;
          l_pn_locations_rec.OFFICE                        := loc.office;
          l_pn_locations_rec.MAX_CAPACITY                  := loc.max_capacity;
          l_pn_locations_rec.OPTIMUM_CAPACITY              := loc.optimum_capacity;
          l_pn_locations_rec.RENTABLE_AREA                 := loc.rentable_area;
          l_pn_locations_rec.USABLE_AREA                   := loc.usable_area;
          l_pn_locations_rec.GROSS_AREA                    := loc.gross_area;
          l_pn_locations_rec.ASSIGNABLE_AREA               := loc.assignable_area;
          l_pn_locations_rec.COMMON_AREA                   := loc.common_area;
          l_pn_locations_rec.COMMON_AREA_FLAG              := loc.common_area_flag;
          l_pn_locations_rec.CLASS                         := loc.class;
          l_pn_locations_rec.STATUS_TYPE                   := loc.status_type;
          l_pn_locations_rec.STATUS                        := 'A';
          l_pn_locations_rec.SUITE                         := loc.suite;
          l_pn_locations_rec.ALLOCATE_COST_CENTER_CODE     := loc.allocate_cost_center_code;
          l_pn_locations_rec.UOM_CODE                      := loc.uom_code;
          l_pn_locations_rec.LAST_UPDATE_LOGIN             := nvl(fnd_profile.value('CONC_LOGIN_ID'), 0);
          l_pn_locations_rec.LAST_UPDATED_BY               := nvl(fnd_profile.value('CONC_USER_ID'), 0);
          l_pn_locations_rec.ATTRIBUTE_CATEGORY            := loc.attribute_category;
          l_pn_locations_rec.ATTRIBUTE1                    := loc.attribute1;
          l_pn_locations_rec.ATTRIBUTE2                    := loc.attribute2;
          l_pn_locations_rec.ATTRIBUTE3                    := loc.attribute3;
          l_pn_locations_rec.ATTRIBUTE4                    := loc.attribute4;
          l_pn_locations_rec.ATTRIBUTE5                    := loc.attribute5;
          l_pn_locations_rec.ATTRIBUTE6                    := loc.attribute6;
          l_pn_locations_rec.ATTRIBUTE7                    := loc.attribute7;
          l_pn_locations_rec.ATTRIBUTE8                    := loc.attribute8;
          l_pn_locations_rec.ATTRIBUTE9                    := loc.attribute9;
          l_pn_locations_rec.ATTRIBUTE10                   := loc.attribute10;
          l_pn_locations_rec.ATTRIBUTE11                   := loc.attribute11;
          l_pn_locations_rec.ATTRIBUTE12                   := loc.attribute12;
          l_pn_locations_rec.ATTRIBUTE13                   := loc.attribute13;
          l_pn_locations_rec.ATTRIBUTE14                   := loc.attribute14;
          l_pn_locations_rec.ATTRIBUTE15                   := loc.attribute15;
          l_pn_locations_rec.REQUEST_ID                    := nvl(fnd_profile.value('CONC_REQUEST_ID'), 0);
          l_pn_locations_rec.PROGRAM_APPLICATION_ID        := nvl(fnd_profile.value('CONC_PROGRAM_APPLICATION_ID'), 0);
          l_pn_locations_rec.PROGRAM_ID                    := nvl(fnd_profile.value('CONC_PROGRAM_ID'), 0);
          l_pn_locations_rec.PROGRAM_UPDATE_DATE           := sysdate ;
          l_pn_locations_rec.FUNCTION_TYPE_LOOKUP_CODE     := loc.FUNCTION_TYPE_LOOKUP_CODE;
          l_pn_locations_rec.LOCATION_ALIAS                := loc.Location_Alias;
          l_pn_locations_rec.PROPERTY_ID                   := loc.Property_Id;
          l_pn_locations_rec.STANDARD_TYPE_LOOKUP_CODE     := loc.STANDARD_TYPE_LOOKUP_CODE;
          l_pn_locations_rec.ACTIVE_START_DATE             := trunc(NVL(loc.new_active_start_date,
                                                                  loc.active_start_date));
          l_pn_locations_rec.ACTIVE_END_DATE               := trunc(NVL(loc.new_active_end_date,
                                                                  loc.active_end_date));
        --Used trunc() :Bug 6009957
          l_pn_locations_rec.address_id                    := v_loc_rec.address_id;
          l_pn_locations_rec.source                        := loc.source;

          /* populate the address_rec */

          l_pn_addresses_rec.ADDRESS_LINE1            := loc.address_line1;
          l_pn_addresses_rec.ADDRESS_LINE2            := loc.address_line2;
          l_pn_addresses_rec.ADDRESS_LINE3            := loc.address_line3;
          l_pn_addresses_rec.ADDRESS_LINE4            := loc.address_line4;
          l_pn_addresses_rec.COUNTY                   := loc.county;
          l_pn_addresses_rec.CITY                     := loc.city;
          l_pn_addresses_rec.STATE                    := loc.state;
          l_pn_addresses_rec.PROVINCE                 := loc.province;
          l_pn_addresses_rec.ZIP_CODE                 := loc.zip_code;
          l_pn_addresses_rec.COUNTRY                  := loc.country;
          l_pn_addresses_rec.ADDRESS_STYLE            := loc.address_style;
          l_pn_addresses_rec.LAST_UPDATE_DATE         := sysdate;
          l_pn_addresses_rec.LAST_UPDATED_BY          := nvl(fnd_profile.value('USER_ID'), 0);
          l_pn_addresses_rec.LAST_UPDATE_LOGIN        := nvl(fnd_profile.value('CONC_LOGIN_ID'), 0);
          l_pn_addresses_rec.ADDR_ATTRIBUTE_CATEGORY  := loc.addr_attribute_category;
          l_pn_addresses_rec.ADDR_ATTRIBUTE1          := loc.addr_attribute1;
          l_pn_addresses_rec.ADDR_ATTRIBUTE2          := loc.addr_attribute2;
          l_pn_addresses_rec.ADDR_ATTRIBUTE3          := loc.addr_attribute3;
          l_pn_addresses_rec.ADDR_ATTRIBUTE4          := loc.addr_attribute4;
          l_pn_addresses_rec.ADDR_ATTRIBUTE5          := loc.addr_attribute5;
          l_pn_addresses_rec.ADDR_ATTRIBUTE6          := loc.addr_attribute6;
          l_pn_addresses_rec.ADDR_ATTRIBUTE7          := loc.addr_attribute7;
          l_pn_addresses_rec.ADDR_ATTRIBUTE8          := loc.addr_attribute8;
          l_pn_addresses_rec.ADDR_ATTRIBUTE9          := loc.addr_attribute9;
          l_pn_addresses_rec.ADDR_ATTRIBUTE10         := loc.addr_attribute10;
          l_pn_addresses_rec.ADDR_ATTRIBUTE11         := loc.addr_attribute11;
          l_pn_addresses_rec.ADDR_ATTRIBUTE12         := loc.addr_attribute12;
          l_pn_addresses_rec.ADDR_ATTRIBUTE13         := loc.addr_attribute13;
          l_pn_addresses_rec.ADDR_ATTRIBUTE14         := loc.addr_attribute14;
          l_pn_addresses_rec.ADDR_ATTRIBUTE15         := loc.addr_attribute15;

          put_log( 'U: Just before Correct/Update');

        --Used trunc() :Bug 6009957
          PNT_LOCATIONS_PKG.correct_update_row
             ( p_pn_locations_rec      => l_pn_locations_rec,
               p_pn_addresses_rec      => l_pn_addresses_rec,
               p_change_mode           => nvl(loc.change_mode, 'CORRECT'),
               p_as_of_date            => loc.change_date,
               p_active_start_date_old => trunc(loc.active_start_date),
               p_active_end_date_old   => trunc(v_loc_rec.active_end_date),
               p_assgn_area_chgd_flag  => l_asgn_area_chng_flag,
               x_return_status         => l_returnstatus,
               x_return_message        => l_return_message
             );
          put_log( 'U: Just after Correct/Update');

          IF NOT ( l_returnStatus = FND_API.G_RET_STS_SUCCESS) THEN
           l_error_message := fnd_message.get;
           pnp_debug_pkg.put_log_msg(l_return_message);
           RAISE INVALID_RECORD;
          END IF;

        EXCEPTION
          WHEN No_Data_Found THEN
            fnd_message.set_name('PN', 'PN_CAFM_LOC_REC_NOT_FOUND_UPD');
            fnd_message.set_token('LOCATION_ID', loc.location_id);
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;

        END;

      ELSIF (loc.ENTRY_TYPE = 'R') THEN

        BEGIN
        --------------------------------------
        -- Update Data in PN_LOCATIONS
        --------------------------------------
          l_active_end_date := trunc(v_loc_rec.active_end_date); --Used trunc() :Bug 6009957

          put_log('R: Building the locations record');
          l_pn_locations_rec.location_id    := loc.location_id;
          l_pn_locations_rec.ORG_ID         := l_org_id;
          l_pn_locations_rec.LOCATION_CODE  := nvl( loc.location_code, v_loc_rec.location_code);
          l_pn_locations_rec.LOCATION_TYPE_LOOKUP_CODE :=
             nvl(loc.location_type_lookup_code, v_loc_rec.location_type_lookup_code);
          l_pn_locations_rec.SPACE_TYPE_LOOKUP_CODE :=
             nvl( loc.space_type_lookup_code, v_loc_rec.space_type_lookup_code);
          l_pn_locations_rec.LAST_UPDATE_DATE   := sysdate;
          l_pn_locations_rec.PARENT_LOCATION_ID :=
             nvl( loc.parent_location_id, v_loc_rec.parent_location_id);
          l_pn_locations_rec.LEASE_OR_OWNED     := nvl( loc.lease_or_owned, v_loc_rec.lease_or_owned);
          l_pn_locations_rec.BUILDING           := nvl( loc.building, v_loc_rec.building);
          l_pn_locations_rec.FLOOR              := nvl( loc.floor, v_loc_rec.floor);
          l_pn_locations_rec.OFFICE             := nvl( loc.office, v_loc_rec.office);
          l_pn_locations_rec.MAX_CAPACITY       := nvl( loc.max_capacity, v_loc_rec.max_capacity);
          l_pn_locations_rec.OPTIMUM_CAPACITY   := nvl( loc.optimum_capacity, v_loc_rec.optimum_capacity);
          l_pn_locations_rec.RENTABLE_AREA      := nvl( loc.rentable_area, v_loc_rec.rentable_area);
          l_pn_locations_rec.USABLE_AREA        := nvl( loc.usable_area, v_loc_rec.usable_area);
          l_pn_locations_rec.GROSS_AREA         := nvl( loc.gross_area, v_loc_rec.gross_area);
          l_pn_locations_rec.ASSIGNABLE_AREA    :=
            nvl( loc.assignable_area, v_loc_rec.assignable_area);
          l_pn_locations_rec.COMMON_AREA        := nvl( loc.common_area, v_loc_rec.common_area);
          l_pn_locations_rec.COMMON_AREA_FLAG   :=
            nvl( loc.common_area_flag, v_loc_rec.common_area_flag);
          l_pn_locations_rec.CLASS              := nvl( loc.class, v_loc_rec.class);
          l_pn_locations_rec.STATUS_TYPE        := nvl( loc.status_type, v_loc_rec.status_type);
          l_pn_locations_rec.STATUS             := v_loc_rec.status;
          l_pn_locations_rec.SUITE              := nvl( loc.suite, v_loc_rec.suite);
          l_pn_locations_rec.ALLOCATE_COST_CENTER_CODE  :=
            nvl( loc.allocate_cost_center_code, v_loc_rec.allocate_cost_center_code);
          l_pn_locations_rec.UOM_CODE           := nvl( loc.uom_code, v_loc_rec.uom_code);
          l_pn_locations_rec.LAST_UPDATE_LOGIN  := nvl( fnd_profile.value('CONC_LOGIN_ID'), 0);
          l_pn_locations_rec.LAST_UPDATED_BY    := nvl( fnd_profile.value('CONC_USER_ID'), 0);
          l_pn_locations_rec.ATTRIBUTE_CATEGORY :=
            nvl( loc.attribute_category, v_loc_rec.attribute_category);
          l_pn_locations_rec.ATTRIBUTE1         := nvl( loc.attribute1, v_loc_rec.attribute1);
          l_pn_locations_rec.ATTRIBUTE2         := nvl( loc.attribute2, v_loc_rec.attribute2);
          l_pn_locations_rec.ATTRIBUTE3         := nvl( loc.attribute3, v_loc_rec.attribute3);
          l_pn_locations_rec.ATTRIBUTE4         := nvl( loc.attribute4, v_loc_rec.attribute4);
          l_pn_locations_rec.ATTRIBUTE5         := nvl( loc.attribute5, v_loc_rec.attribute5);
          l_pn_locations_rec.ATTRIBUTE6         := nvl( loc.attribute6, v_loc_rec.attribute6);
          l_pn_locations_rec.ATTRIBUTE7         := nvl( loc.attribute7, v_loc_rec.attribute7);
          l_pn_locations_rec.ATTRIBUTE8         := nvl( loc.attribute8, v_loc_rec.attribute8);
          l_pn_locations_rec.ATTRIBUTE9         := nvl( loc.attribute9, v_loc_rec.attribute9);
          l_pn_locations_rec.ATTRIBUTE10        := nvl( loc.attribute10, v_loc_rec.attribute10);
          l_pn_locations_rec.ATTRIBUTE11        := nvl( loc.attribute11, v_loc_rec.attribute11);
          l_pn_locations_rec.ATTRIBUTE12        := nvl( loc.attribute12, v_loc_rec.attribute12);
          l_pn_locations_rec.ATTRIBUTE13        := nvl( loc.attribute13, v_loc_rec.attribute13);
          l_pn_locations_rec.ATTRIBUTE14        := nvl( loc.attribute14, v_loc_rec.attribute14);
          l_pn_locations_rec.ATTRIBUTE15        := nvl( loc.attribute15, v_loc_rec.attribute15);
          l_pn_locations_rec.REQUEST_ID         := nvl( fnd_profile.value('CONC_REQUEST_ID'), 0);
          l_pn_locations_rec.PROGRAM_APPLICATION_ID :=
             nvl( fnd_profile.value('CONC_PROGRAM_APPLICATION_ID'), 0);
          l_pn_locations_rec.PROGRAM_ID         := nvl( fnd_profile.value('CONC_PROGRAM_ID'), 0);
          l_pn_locations_rec.PROGRAM_UPDATE_DATE:= sysdate;
          l_pn_locations_rec.LOCATION_ALIAS     :=
             nvl( loc.location_alias, v_loc_rec.location_alias);
          l_pn_locations_rec.PROPERTY_ID        := nvl( loc.property_id, v_loc_rec.property_id);

          l_pn_locations_rec.FUNCTION_TYPE_LOOKUP_CODE :=
             nvl( loc.function_type_lookup_code, v_loc_rec.function_type_lookup_code);
          l_pn_locations_rec.STANDARD_TYPE_LOOKUP_CODE :=
             nvl( loc.standard_type_lookup_code, v_loc_rec.standard_type_lookup_code);
          l_pn_locations_rec.active_start_date  :=
             trunc(nvl(loc.new_active_start_date, v_loc_rec.active_start_date)); --Used trunc() :Bug 6009957
          l_pn_locations_rec.active_end_date    :=
             trunc(nvl(loc.new_active_end_date,v_loc_rec.active_end_date)); --Used trunc() :Bug 6009957
          l_pn_locations_rec .address_id        := nvl(v_loc_rec.address_id,l_Address_id);
          l_pn_locations_rec.source             := nvl(loc.source,v_loc_rec.source);

          l_pn_addresses_rec.ADDRESS_LINE1         := nvl( loc.address_line1, v_addr_rec.address_line1);
          l_pn_addresses_rec.ADDRESS_LINE2         := nvl( loc.address_line2, v_addr_rec.address_line2);
          l_pn_addresses_rec.ADDRESS_LINE3         := nvl( loc.address_line3, v_addr_rec.address_line3);
          l_pn_addresses_rec.ADDRESS_LINE4         := nvl( loc.address_line4, v_addr_rec.address_line4);
          l_pn_addresses_rec.COUNTY                := nvl( loc.county, v_addr_rec.county);
          l_pn_addresses_rec.CITY                  := nvl( loc.city, v_addr_rec.city);
          l_pn_addresses_rec.STATE                 := nvl( loc.state, v_addr_rec.state);
          l_pn_addresses_rec.PROVINCE              := nvl( loc.province, v_addr_rec.province);
          l_pn_addresses_rec.ZIP_CODE              := nvl( loc.zip_code, v_addr_rec.zip_code);
          l_pn_addresses_rec.COUNTRY               := nvl( loc.country, v_addr_rec.country);
          l_pn_addresses_rec.ADDRESS_STYLE         := nvl( loc.address_style, v_addr_rec.address_style);
          l_pn_addresses_rec.LAST_UPDATE_DATE      := sysdate;
          l_pn_addresses_rec.LAST_UPDATED_BY       := nvl(fnd_profile.value('USER_ID'), 0);
          l_pn_addresses_rec.LAST_UPDATE_LOGIN     := nvl(fnd_profile.value('CONC_LOGIN_ID'), 0);
          l_pn_addresses_rec.ADDR_ATTRIBUTE_CATEGORY
                                                   := nvl(loc.addr_attribute_category,
                                                          v_addr_rec.addr_attribute_category);
          l_pn_addresses_rec.ADDR_ATTRIBUTE1       := nvl(loc.addr_attribute1,v_addr_rec.addr_attribute1);
          l_pn_addresses_rec.ADDR_ATTRIBUTE2       := nvl(loc.addr_attribute2,v_addr_rec.addr_attribute2);
          l_pn_addresses_rec.ADDR_ATTRIBUTE3       := nvl(loc.addr_attribute3,v_addr_rec.addr_attribute3);
          l_pn_addresses_rec.ADDR_ATTRIBUTE4       := nvl(loc.addr_attribute4,v_addr_rec.addr_attribute4);
          l_pn_addresses_rec.ADDR_ATTRIBUTE5       := nvl(loc.addr_attribute5,v_addr_rec.addr_attribute5);
          l_pn_addresses_rec.ADDR_ATTRIBUTE6       := nvl(loc.addr_attribute6,v_addr_rec.addr_attribute6);
          l_pn_addresses_rec.ADDR_ATTRIBUTE7       := nvl(loc.addr_attribute7,v_addr_rec.addr_attribute7);
          l_pn_addresses_rec.ADDR_ATTRIBUTE8       := nvl(loc.addr_attribute8,v_addr_rec.addr_attribute8);
          l_pn_addresses_rec.ADDR_ATTRIBUTE9       := nvl(loc.addr_attribute9,v_addr_rec.addr_attribute9);
          l_pn_addresses_rec.ADDR_ATTRIBUTE10      := nvl(loc.addr_attribute10,v_addr_rec.addr_attribute10);
          l_pn_addresses_rec.ADDR_ATTRIBUTE11      := nvl(loc.addr_attribute11,v_addr_rec.addr_attribute11);
          l_pn_addresses_rec.ADDR_ATTRIBUTE12      := nvl(loc.addr_attribute12,v_addr_rec.addr_attribute12);
          l_pn_addresses_rec.ADDR_ATTRIBUTE13      := nvl(loc.addr_attribute13,v_addr_rec.addr_attribute13);
          l_pn_addresses_rec.ADDR_ATTRIBUTE14      := nvl(loc.addr_attribute14,v_addr_rec.addr_attribute14);
          l_pn_addresses_rec.ADDR_ATTRIBUTE15      := nvl(loc.addr_attribute15,v_addr_rec.addr_attribute15);

          -------------------------------------------------------------------
          -- Validate Assignable_Area / Common Area is not null for location types 'OFFICE','SECTION'
          -------------------------------------------------------------------

          put_log('Validate Common_Area and Assignable_Area');

          if (l_pn_locations_rec.assignable_area is null and
             l_pn_locations_rec.location_type_lookup_code in ('OFFICE','SECTION') and
             nvl(l_pn_locations_rec.common_area_flag,'N') = 'N') then
             fnd_message.set_name('PN','PN_CAFM_ASSIGNABLE_REQ');
             fnd_message.set_token('LOCATION_ID', l_pn_locations_rec.location_id);
             l_error_message := fnd_message.get;
             raise INVALID_RECORD;
          end if;

          if (l_pn_locations_rec.common_area is null and
             l_pn_locations_rec.location_type_lookup_code in ('OFFICE','SECTION') and
             l_pn_locations_rec.common_area_flag = 'Y') then
             fnd_message.set_name('PN','PN_CAFM_COMMON_AREA_REQ');
             fnd_message.set_token('LOCATION_ID', l_pn_locations_rec.location_id);
             l_error_message := fnd_message.get;
             raise INVALID_RECORD;
          end if;

          if (l_pn_locations_rec.Common_Area is not null and
              l_pn_locations_rec.Assignable_Area is not null and
              l_pn_locations_rec.location_type_lookup_code in ('OFFICE','SECTION'))
          then
             if l_pn_locations_rec.common_area_flag = 'Y' then
                l_pn_locations_rec.Assignable_Area := null;
             elsif nvl(l_pn_locations_rec.common_area_flag,'N') = 'N' then
                l_pn_locations_rec.Common_Area := null;
             end if;
          end if;

          put_log( 'R: Just before Correct/Update');
          PNT_LOCATIONS_PKG.correct_update_row
             ( p_pn_locations_rec      => l_pn_locations_rec,
               p_pn_addresses_rec      => l_pn_addresses_rec,
               p_change_mode           => nvl(loc.change_mode, 'CORRECT'),
               p_as_of_date            => loc.change_date,
               p_active_start_date_old => trunc(loc.active_start_date), --Used trunc() :Bug 6009957
               p_active_end_date_old   => trunc(v_loc_rec.active_end_date), --Used trunc() :Bug 6009957
               p_assgn_area_chgd_flag  => l_asgn_area_chng_flag,
               x_return_status         => l_returnstatus,
               x_return_message        => l_return_message
             );
          put_log( 'R: Just before Correct/Update');

          IF NOT ( l_returnStatus = FND_API.G_RET_STS_SUCCESS) THEN
            put_log('R:Error in correctupdate_row ' || l_return_message);
            put_log(l_return_message);
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;
          END IF;

        EXCEPTION
          WHEN No_Data_Found THEN
            fnd_message.set_name('PN', 'PN_CAFM_LOC_REC_NOT_FOUND_UPD');
            fnd_message.set_token('LOCATION_ID', loc.location_id);
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;

        END;

      END IF; -- 'U', 'R'

    END IF; -- loc.ENTRY_TYPE

    ------------------------------------------------
    -- Set PN_LOCATIONS_ITF.transferred_to_pn = 'Y'
    ------------------------------------------------
    put_log('Update ITF set transfer = Y');
    UPDATE  pn_locations_itf
    SET     transferred_to_pn = 'Y',
            error_message = NULL
    WHERE   rowid = loc.rowid;

    -------------------------------------------
    -- batch commit after every 1000 records --
    -------------------------------------------
    IF (NVL(l_total,0) > 0) AND
       (MOD(l_total, 1000) = 0) THEN
      COMMIT;
      l_total_for_commit := 0;   -- Bug 6670882
    END IF;

  EXCEPTION
    WHEN INVALID_RECORD THEN
      ROLLBACK TO S1;
      l_fail := l_fail + 1;
      -- Update ERROR_MESSAGE
      UPDATE pn_locations_itf
      SET    error_message = substr(l_error_message, 1, 240)
      WHERE  rowid = loc.rowid;
      -- Spool to Conc Log
      put_line(l_error_message);

      errbuf  := l_error_message;
      retcode := '2';

    WHEN DELETE_RECORD THEN
      NULL;

    WHEN OTHERS THEN
      ROLLBACK TO S1;
      l_fail := l_fail + 1;
      l_error_message := substr(sqlerrm,1,250);
      UPDATE pn_locations_itf
      SET    error_message = substr(l_error_message, 1, 240)
      WHERE  rowid = loc.rowid;
      errbuf  := l_error_message;
      retcode := '2';
      APP_EXCEPTION.raise_exception;

  END; -- end of begin that started in the FOR loop

END LOOP; -- End loop for loccursor

IF l_total_for_commit >  0 THEN -- Bug 6670882
  COMMIT;
END IF;

IF (l_total = 0) THEN
  fnd_message.set_name ('PN', 'PN_CAFM_NO_LOC_REC_FOUND');
  errbuf  := fnd_message.get;
  retcode := '2';
  put_line(errbuf);

ELSE
  l_succ := l_total - l_fail;

  Put_Log('
=============== Summary ===============');

  fnd_message.set_name('PN', 'PN_CAFM_LOCATION_SUCCESS');
  fnd_message.set_token('SUCCESS', l_succ);
  put_line(fnd_message.get);

  fnd_message.set_name('PN', 'PN_CAFM_LOCATION_FAILURE');
  fnd_message.set_token('FAILURE', l_fail);
  put_line(fnd_message.get);

  fnd_message.set_name('PN', 'PN_CAFM_LOCATION_TOTAL');
  fnd_message.set_token('TOTAL', l_total);
  put_line(fnd_message.get);

END IF;

PNP_DEBUG_PKG.disable_file_debug;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    put_line('EXCEPTION: NO_DATA_FOUND');
    fnd_message.set_name ('PN', 'PN_NO_LOC_DATA_FOUND');
    errbuf  := l_error_message;
    retcode := '2';
    put_line(errbuf);
    APP_EXCEPTION.raise_exception;
    PNP_DEBUG_PKG.disable_file_debug;

  WHEN OTHERS THEN
    put_line('EXCEPTION: OTHERS');
    If l_error_message is null then
       l_error_message := fnd_message.get;
    end if;
    pnp_debug_pkg.put_log_msg(l_error_message);
    errbuf  := l_error_message;
    retcode := '2';
    put_line(errbuf);
    APP_EXCEPTION.raise_exception;
    PNP_DEBUG_PKG.disable_file_debug;

END LOCATIONS_ITF;

-------------------------------------------------------------------------------
--  NAME         : Is_Id_Code_Valid
--  DESCRIPTION  : Checks if the Location Id/Code combination is Valid.
--  NOTES        : Called by Locations_Itf Procedure
--  ARGUMENTS    : IN: p_loc_id
--                      p_loc_code
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--  24-JAN-03  Kiran       o Created
--  01-APR-05  piagrawa    o Modified the select statements to retrieve values
--                           from _ALL tables
--  14-JUL-05  piagrawa    o  Bug 4284035 - also changed the signature
-------------------------------------------------------------------------------

Function  Is_Id_Code_Valid  (
  p_Loc_Id          NUMBER,
  p_Loc_Code        VARCHAR2,
  p_org_id          NUMBER
)

Return Boolean IS

  CURSOR locCodeCur IS

     SELECT     loc.LOCATION_CODE
     FROM       PN_LOCATIONS_ALL loc
     WHERE      loc.LOCATION_ID = p_Loc_Id;

  CURSOR locIdCur is
     SELECT     loc.LOCATION_ID
     FROM       PN_LOCATIONS_ALL loc
     WHERE      loc.LOCATION_CODE = p_Loc_Code
     AND        org_id = p_org_id;

BEGIN

  FOR code IN locCodeCur LOOP
     if code.LOCATION_CODE <> p_Loc_Code then
        RETURN FALSE;
     end if;
  END LOOP;

  FOR id IN locIdCur LOOP
     if id.LOCATION_ID <> p_Loc_Id then
        RETURN FALSE;
     end if;
  END LOOP;

  RETURN TRUE;

END Is_Id_Code_Valid ;


/*============================================================================+
 | FUNCTION
 |   Get_Location_Type
 |
 | DESCRIPTION
 |   Given a Location_Id, Returns the Location_Type (BUILDING/FLOOR/OFFICE)
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS: Listed Very Clearly Below
 |
 | NOTES:
 |   Called by Locations_Itf Procedure
 |
 | MODIFICATION HISTORY
 | 1999       Naga Vijayapuram  o Created
 | 17-MAY-02  Kiran Hegde       o Location_Type_lookup_Code is now validated
 |                                only from pn_locations
 | 01-APR-05  piagrawa          o Modified the select statements to retrieve values
 |                                from _ALL tables
 +===========================================================================*/

Function Get_Location_Type ( p_location_id  Number ) Return VarChar2 is

  l_lookup_type  varchar2(30);

BEGIN

  Select distinct location_type_lookup_code
  into   l_lookup_type
  from   PN_LOCATIONS_ALL
  where  location_id = p_location_id ;

  Return l_lookup_type ;

EXCEPTION

  When No_Data_Found Then

    Return 'UNKNOWN' ;

  When Others Then
    Raise;

END Get_Location_Type;


/*===========================================================================+
 | FUNCTION
 |   Exists_Property_Id
 |
 | DESCRIPTION
 |   Checks whether the property_id is valid - from pn_properties
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN: p_property_id NUMBER
 |
 | NOTES:
 |   Called by Locations_Itf Procedure
 |
 | MODIFICATION HISTORY
 | 23-APR-02   Kiran Hegde  o Created -
 |                            Bug#2324687 - Validates if the Property_Id in the
 |                            table Pn_Locations_Itf exists in Pn_Properties
 | 01-APR-05   piagrawa     o Modified the select statements to retrieve values
 |                            from _ALL tables
 +===========================================================================*/

Function  Exists_Property_Id (
                                p_property_id   NUMBER
                             )
Return Boolean IS

  l_number       Number;

BEGIN

  if ( p_property_id  IS NOT NULL ) then

    Select 1
    Into   l_number
    From   Pn_Properties_all
    Where  Property_Id = p_property_id ;
  end if;

  Return True;

EXCEPTION

  When No_Data_Found Then
    Return False;

  When Others Then
    Raise;

END Exists_Property_Id ;




/*===========================================================================+
 | PROCEDURE
 |   SPACE_ALLOCATIONS_ITF
 |
 | DESCRIPTION
 |   Handles Import of Space Allocations Data
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS:
 |   IN:  p_Batch_Name
 |   OUT: Errbuf
 |        RetCode
 |
 | NOTES:
 |   Called by IMPORT_CAD Procedure Above
 |
 | MODIFICATION HISTORY
 | ??-???-98  Naga     o Created
 | ??-???-99  Naga     o Included Validations
 | 15-MAY-02  Kiran    o ??
 | 20-Nov-03  Daniel   o Modified SELECT to go after
 |                       _ALL tables for PN_SPACE_ASSIGN_EMP
 |                       Fix for bug # 3272712
 | 26-MAY-04  abanerje o Added condition to check for p_assignable_area
 |                       is -99. In this case error out indicating that
 |                       the location is a common space.
 |                       Bug #3598315
 | 16-JUN-04  ftanudja o Created variable tlempinfo.
 |                     o Removed all references to pn_space_assign_emp_pkg.
 |                       tlempinfo.
 |                     o Added validation for allocated_area for manual
 |                       spc assignments.
 |                     o Fixed id validation for entry type 'U','R'.
 |                     o #3649373
 | 01-APR-05  piagrawa o Modified the signature to include org_id,
 |                       also in INSERT_ROW call passed
 |                       the value of p_org_id in place of
 |                       fnd_profile.value('ORG_ID')
 | 19-JUL-05  sdm      o Passed SOURCE from PN_EMP_ASSIGN_SPACE_ITF to
 |                       Procedure  PN_SPACE_ASSIGN_EMP.INSERT_ROW and
 |                       Procedure  PN_SPACE_ASSIGN_EMP.UPDATE_ROW
 | 23-NOV-05  Hareesha o Modified get_profile_value to include org_id as
 |                       parameter.
 | 01-DEC-05  pikhar   o passed org_id in pnp_util_func.get_cc_code and
 |                     o pnp_util_func.valid_cost_center
 | 31-Aug-06  Prabhakaro Bug #5449595 Validated project_id and task_id
 |                       and if valid,Added project_id and task_id
 |                       in insert_row and upate_row
 | 11-OCT-06  acprakas o Bug#5587012. Passed location_id to procedure
 |                       PNP_UTIL_FUNC.Validate_date_for_assignments instead
 |                       of EMP_SPACE_ASSIGN_ID.
 | 08-NOV-06   lbala   o Bug#5636783.Added Commit prior to END LOOP and
 |                       SAVEPOINT S2.Added code in exception block for WHEN
 |                       OTHERS to update errored record count.
 | 24-AUG-08  RKARTHA  o Bug#6826510 - Round off the allocated_area_pct to
 |                       two decimal places.
 +===========================================================================*/

PROCEDURE space_allocations_itf (

  p_batch_name                  VARCHAR2,
  p_org_id                      NUMBER,
  errbuf           out NOCOPY          VarChar2,
  retcode          out NOCOPY          VarChar2

) IS

  l_succ         Number  Default 0;
  l_fail         Number  Default 0;
  l_total        Number  Default 0;

  CURSOR spacecur IS
    SELECT   spc.*, spc.rowid
    FROM     pn_emp_space_assign_itf spc
    WHERE    spc.batch_name = p_batch_name
    AND      spc.transferred_to_pn is null;

  tlempinfo                     pn_space_assign_emp_all%ROWTYPE;

  l_error_message               VarChar2(512);

  l_assignable_area             Number;
  l_old_allocated_area          Number;
  l_new_allocated_area          Number;
  l_available_vacant_area       Boolean;
  l_future                      Varchar2(1) := 'N';
  l_allocated_area_pct          Number;
  l_rowid_dummy                 Varchar2(30);
  l_changed_start_date          Date;
  l_emp_assign_start_date       Date;
  l_emp_exists                  Number := 0;

  INVALID_RECORD                EXCEPTION;
  l_return_status               VARCHAR2(50);
  l_return_message              VARCHAR2(2000);
  l_org_id                      NUMBER;
  l_task_valid                  BOOLEAN;
  l_project_valid               BOOLEAN;

  CURSOR check_project_valid( p_project_id NUMBER) IS
    SELECT project_id
    FROM pa_projects_all proj
    WHERE proj.project_id = p_project_id
    AND proj.org_id = l_org_id
    AND NVL(proj.template_flag,'N') <>'Y';

  CURSOR check_task_valid( p_task_id NUMBER,p_project_id NUMBER) IS
    SELECT task_id
    FROM pa_tasks task
    WHERE task.project_id = p_project_id
    AND task.task_id = p_task_id;

BEGIN

  IF pn_mo_cache_utils.is_MOAC_enabled AND p_org_id IS NULL THEN
    l_org_id := pn_mo_cache_utils.get_current_org_id;
  ELSE
    l_org_id := p_org_id;
  END IF;

  retcode := '0';

  FOR space in spacecur LOOP

    l_total := l_total + 1;

    BEGIN

      Put_Log('
=============== Record #: ' || l_total || ' ===============');

    --------------------
    -- Set save point --
    --------------------
    put_log('Setting the save point');
    SAVEPOINT S2;


      put_log('Validate Entry Types');
      --------------------------------------------------------------------
      -- Validate Entry Types
      -- Note that 'D' is no more a valid entry for space_allocations_itf.
      --------------------------------------------------------------------
      if (space.ENTRY_TYPE not in ('A', 'U', 'R')) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_ENTRY_TYPE');
        fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;

      /*--------------------------------------------------------------
      -- NOTE: If we are here, it means we are handling INSERT/UPDATE
      -- get the old record if this is an update/replace --
      -- Using variables and Row Handlers from PN_SPACE_ASSIGN_EMP_PKG
      -- for insert and update into pn_space_assign_emp.
      --------------------------------------------------------------*/

      put_log( 'Validating emp_space_assign_id and getting the old record for UPDATE/REPLACE' );

      if ( space.entry_type IN ('U', 'R') ) then

         IF space.emp_space_assign_id IS NOT NULL THEN
            SELECT *
            INTO   tlempinfo
            FROM   pn_space_assign_emp_all
            WHERE  EMP_SPACE_ASSIGN_ID = space.EMP_SPACE_ASSIGN_ID;
         END IF;

         IF tlempinfo.emp_space_assign_id IS NULL THEN
            put_log(' Provide a valid space_allocation_id');
            raise INVALID_RECORD;
         end if;

      end if;

      put_log('Validate Source');
      --------------------------------------
      -- Validate SOURCE
      --------------------------------------
      if (NOT PNP_UTIL_FUNC.valid_lookup_code( 'PN_SOURCE', space.SOURCE)) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_SOURCE');
        fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;

      put_log('Validate Location_Id');
      --------------------------------------
      -- Validate LOCATION_ID
      --------------------------------------
      if (NOT PNP_UTIL_FUNC.valid_location(space.LOCATION_ID)) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_INVALID_LOCATION');
        fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;

      /*-- For PERSON_ID, COST_CENTER_CODE validations,
           there are 4 possible situations -

      1) Both PERSON_ID and COST_CENTER_CODE are NULL
         -- Inform that one of them is needed.

      2) Both PERSON_ID and COST_CENTER_CODE are NOT NULL
         -- Validate combination

      3) Only PERSON_ID is present
         -- Validate PERSON_ID and generate COST_CENTER_CODE

      4) Only COST_CENTER_CODE is present
         -- Validate it.                        --*/

      put_log('Validate Employee - Cost_Center - Situation 1');
      --------------------------------------
      -- Situation (1) above.
      --------------------------------------
      if (space.employee_id is NULL) and
          (space.COST_CENTER_CODE is NULL) then
        fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE_1');
        fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
        l_error_message := fnd_message.get;
        raise INVALID_RECORD;
      end if;


      put_log('Validate Employee - Cost_Center - Situation 2');
      --------------------------------------
      -- Situation (2) above.
      --------------------------------------
      if (space.employee_id is NOT NULL) and
          (space.COST_CENTER_CODE is NOT NULL) then

        if (NOT PNP_UTIL_FUNC.valid_employee(space.employee_id)) then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE3B');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          fnd_message.set_token('PERSON_ID', space.employee_id);
          l_error_message := fnd_message.get;
        end if;

        if (NOT PNP_UTIL_FUNC.valid_cost_center(space.COST_CENTER_CODE,l_org_id)) then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE_4');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          fnd_message.set_token('COST_CENTER_CODE', space.cost_center_code);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
        end if;


      end if;

      put_log('Validate Employee - Cost_Center - Situation 3');
      --------------------------------------
      -- Situation (3) above.
      --------------------------------------
      if (space.employee_id is NOT NULL) and
         (space.COST_CENTER_CODE is NULL) then
        if (PNP_UTIL_FUNC.valid_employee(space.employee_id)) then
          space.COST_CENTER_CODE := PNP_UTIL_FUNC.get_cc_code(space.employee_id,l_org_id);
          Put_Log('Cost_Center_Code of Employee: ' || space.COST_CENTER_CODE);
          if (space.COST_CENTER_CODE is NULL) then
            fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE3A');
            fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
            fnd_message.set_token('PERSON_ID', space.employee_id);
            l_error_message := fnd_message.get;
            raise INVALID_RECORD;
          end if;
        else  -- Invalid Employee --
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE3B');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          fnd_message.set_token('PERSON_ID', space.employee_id);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
        end if;
      end if;

      put_log('Validate Employee - Cost_Center - Situation 4');
      --------------------------------------
      -- Situation (4) above.
      --------------------------------------
      if (space.employee_id is NULL) and
         ( space.COST_CENTER_CODE is NOT NULL) then
        if (NOT PNP_UTIL_FUNC.valid_cost_center(space.COST_CENTER_CODE,l_org_id)) then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_EMP_ID_CC_CODE_4');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          fnd_message.set_token('COST_CENTER_CODE', space.cost_center_code);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
        end if;
      end if;

      --------------------------------------------------------
      -- Check if Start Date is NULL
      --------------------------------------------------------
      If ( space.EMP_ASSIGN_START_DATE IS NULL AND space.entry_type IN ('A', 'U')) Then
          fnd_message.set_name('PN', 'PN_SPACE_EMP_START_DATE_NULL');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
      End If;

      --------------------------------------------------------
      -- Check if Start Date > End Date
      --------------------------------------------------------
      If ( space.EMP_ASSIGN_START_DATE IS NOT NULL ) Then
         if ( space.EMP_ASSIGN_START_DATE >
              NVL( space.emp_assign_end_date,
              NVL(tlempinfo.emp_assign_end_date, to_date('12/31/4712','mm/dd/yyyy'))) ) then
             fnd_message.set_name('PN', 'PN_SPACE_ASSIGN_EMP_END_DT');
             fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
             l_error_message := fnd_message.get;
             raise INVALID_RECORD;
         end if;
      End If;

      If (pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id) = 'Y') Then

        put_log('Check if Allocated_Area is NOT NULL - AUTO SPACE DISTRIBUTION');
        -----------------------------------------------------------------------
        -- Check if Allocated_Area is NOT NULL in case of AUTO SPACE ASSIGNMENT
        -----------------------------------------------------------------------
        If (space.allocated_area IS NOT NULL) Then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_NOT_NULL_AREA');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;
        End If;

      Else  -- PN_AUTOMATIC_SPACE_DISTRIBUTION='N' -- Manual Space Distribution

        put_log('Check if Allocated_Area is NULL - MANUAL SPACE DISTRIBUTION');
        ----------------------------------------------------------------
        -- Check if Allocated_Area is NULL for manual space distribution
        ----------------------------------------------------------------
        If (space.allocated_area is NULL) AND
           (space.entry_type IN ('A','U')) AND
            pnp_util_func.get_location_type_lookup_code(
              p_location_id => space.location_id,
              p_as_of_date  => space.emp_assign_start_date) IN ('OFFICE','SECTION')
        Then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_NULL_AREA');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;

        Elsif (space.allocated_area IS NOT NULL) AND
              (space.entry_type IN ('A','U')) AND
              pnp_util_func.get_location_type_lookup_code(
                p_location_id => space.location_id,
                p_as_of_date  => space.emp_assign_start_date) NOT IN ('OFFICE','SECTION')
        Then
          fnd_message.set_name('PN', 'PN_CAFM_SPACE_NOT_NULL_AREA');
          fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
          l_error_message := fnd_message.get;
          raise INVALID_RECORD;

        End If;

        put_log('Validate Allocated_Area and End_Date');
        --------------------------------------
        -- Validate Allocated Area
        --------------------------------------
        if ( space.entry_type = 'A' ) then
           l_old_allocated_area := 0;
           l_new_allocated_area := space.allocated_area;
           l_emp_assign_start_date := space.emp_assign_start_date;
        elsif ( space.entry_type IN ('U', 'R')) then
           l_old_allocated_area := tlempinfo.allocated_area;
           l_new_allocated_area := nvl( space.allocated_area, tlempinfo.allocated_area );
           l_emp_assign_start_date := NVL(space.emp_assign_start_date, NVL( space.change_date, SYSDATE ));
        end if;


        put_log('*** Calling PNP_UTIL_FUNC.validate_vacant_area ***');
        PNP_UTIL_FUNC.validate_vacant_area( p_location_id               => space.Location_Id,
                                            p_st_date                   => l_emp_assign_start_date,
                                            p_end_dt                    => space.emp_assign_end_date,
                                            p_assignable_area           => l_assignable_area,
                                            p_old_allocated_area        => l_old_allocated_area,
                                            p_new_allocated_area        => l_new_allocated_area,
                                            p_old_allocated_area_pct    => NULL,
                                            p_new_allocated_area_pct    => NULL,
                                            p_display_message           => 'Y',
                                            p_future                    => l_future,
                                            p_available_vacant_area     => l_available_vacant_area );
         put_log('*** DONE PNP_UTIL_FUNC.validate_vacant_area ***');

         IF (l_assignable_area = -99) THEN
           l_error_message := fnd_message.get;
           raise INVALID_RECORD;
         END IF;


         If ( l_available_vacant_area ) Then

            put_log('Computing Allocated_Area_Pct');
            --------------------------------------
            -- Computing Allocated_Area_Pct
            --------------------------------------
            put_log('****************************');
            l_allocated_area_pct := round((space.allocated_area / NVL( l_assignable_area, space.allocated_area ) * 100), 2);
            put_log(l_allocated_area_pct);

            if( NVL(l_future, 'N') = 'Y' ) then
               put_log ( 'This location has future assignments. The end date of current assignment will default to one day prior to the earliest
                          date of all future dated assignments for this location.' );
            end if;

         Else
           fnd_message.set_name('PN', 'PN_CAFM_SPACE_INVALID_AREA');
           fnd_message.set_token('LOCATION_ID', space.LOCATION_ID);
           fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
           l_error_message := fnd_message.get;
           raise INVALID_RECORD;

         End If;

      End If;

      put_log('***Check if project_id and task_id are valid*****');

      IF (space.project_id IS NULL) THEN
         IF(space.task_id IS NOT NULL) THEN
            fnd_message.set_name('PN', 'PN_CAFM_TASK_PROJECT');
            fnd_message.set_token('TASK_ID', space.TASK_ID);
            l_error_message := fnd_message.get;
            RAISE INVALID_RECORD;
         END IF;
      ELSE
         l_project_valid := FALSE;
         FOR rec IN check_project_valid(space.project_id) LOOP
            IF rec.project_id IS NOT NULL THEN
               l_project_valid := TRUE;

               IF space.task_id IS NOT NULL THEN
                  l_task_valid := FALSE;
                  FOR rec1 IN check_task_valid(space.task_id,space.project_id) LOOP
                     IF rec1.task_id IS NOT NULL THEN
                        l_task_valid := TRUE;
                     END IF;
                  END LOOP;

                  IF l_task_valid = FALSE THEN
                     fnd_message.set_name('PN', 'PN_CAFM_TASK');
                     fnd_message.set_token('PROJECT_ID', space.PROJECT_ID);
                     fnd_message.set_token('TASK_ID', space.TASK_ID);
                     l_error_message := fnd_message.get;
                     raise INVALID_RECORD;
                  END IF;
               END IF;
            END IF;
         END LOOP;

        IF l_project_valid = FALSE THEN
            fnd_message.set_name('PN', 'PN_CAFM_PROJECT');
            fnd_message.set_token('PROJECT_ID', space.PROJECT_ID);
            l_error_message := fnd_message.get;
            raise INVALID_RECORD;
        END IF;
      END IF;

      ---------------------------------------
      -- Additional Entry
      ---------------------------------------
      if (space.ENTRY_TYPE = 'A') then

      put_log('Additional entry type');

      space.EMP_SPACE_ASSIGN_ID := NULL;

          PNP_UTIL_FUNC.Validate_date_for_assignments (
             p_location_id => space.LOCATION_ID,     --Bug#5587012
             p_start_date  => space.emp_assign_start_date,
             p_end_date    => space.emp_assign_end_date,
             x_return_status   => l_return_status,
             x_return_message  => l_return_message
          );

          IF NOT( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
             l_error_message := fnd_message.get;
             raise INVALID_RECORD; --Bug5515198
         END IF;


      PN_SPACE_ASSIGN_EMP_PKG.insert_row
      (
        X_ROWID                                 => l_rowid_dummy,
        X_org_id                                => l_org_id,
        X_EMP_SPACE_ASSIGN_ID                   => space.EMP_SPACE_ASSIGN_ID,
        X_ATTRIBUTE1                            => space.ATTRIBUTE1,
        X_ATTRIBUTE2                            => space.ATTRIBUTE2,
        X_ATTRIBUTE3                            => space.ATTRIBUTE3,
        X_ATTRIBUTE4                            => space.ATTRIBUTE4,
        X_ATTRIBUTE5                            => space.ATTRIBUTE5,
        X_ATTRIBUTE6                            => space.ATTRIBUTE6,
        X_ATTRIBUTE7                            => space.ATTRIBUTE7,
        X_ATTRIBUTE8                            => space.ATTRIBUTE8,
        X_ATTRIBUTE9                            => space.ATTRIBUTE9,
        X_ATTRIBUTE10                           => space.ATTRIBUTE10,
        X_ATTRIBUTE11                           => space.ATTRIBUTE11,
        X_ATTRIBUTE12                           => space.ATTRIBUTE12,
        X_ATTRIBUTE13                           => space.ATTRIBUTE13,
        X_ATTRIBUTE14                           => space.ATTRIBUTE14,
        X_ATTRIBUTE15                           => space.ATTRIBUTE15,
        X_LOCATION_ID                           => space.LOCATION_ID,
        X_PERSON_ID                             => space.EMPLOYEE_ID,
        X_PROJECT_ID                            => space.PROJECT_ID,
        X_TASK_ID                               => space.TASK_ID,
        X_EMP_ASSIGN_START_DATE                 => space.EMP_ASSIGN_START_DATE,
        X_EMP_ASSIGN_END_DATE                   => space.EMP_ASSIGN_END_DATE,
        X_COST_CENTER_CODE                      => space.COST_CENTER_CODE,
        X_ALLOCATED_AREA_PCT                    => l_allocated_area_pct,
        X_ALLOCATED_AREA                        => space.ALLOCATED_AREA,
        X_UTILIZED_AREA                         => space.UTILIZED_AREA,
        X_EMP_SPACE_COMMENTS                    => NULL,
        X_ATTRIBUTE_CATEGORY                    => space.ATTRIBUTE_CATEGORY,
        X_CREATION_DATE                         => SYSDATE,
        X_CREATED_BY                            => NVL( fnd_profile.value('USER_ID'), 0),
        X_LAST_UPDATE_DATE                      => SYSDATE,
        X_LAST_UPDATED_BY                       => NVL( fnd_profile.value('USER_ID'), 0),
        X_LAST_UPDATE_LOGIN                     => NVL( fnd_profile.value('CONC_LOGIN_ID'), 0),
        X_SOURCE                                => space.source
        );


      end if;

      ---------------------------------------------------------------------------
      -- If we are here then it is UPDATE or REPLACE,
      ---------------------------------------------------------------------------

      If (space.ENTRY_TYPE IN ('U', 'R')) Then

         -- We do not allow UPDATE if current_space_allocation is not active

         if ( NVL( space.change_mode, 'CORRECT' ) = 'UPDATE' ) then
             if ( nvl(space.change_date, trunc(SYSDATE)) < tlempinfo.emp_assign_start_date OR
                  nvl(space.change_date, trunc(SYSDATE)) > NVL(tlempinfo.emp_assign_end_date,
                                                               to_date('12/31/4712','mm/dd/yyyy')) ) then
                 fnd_message.set_name('PN', 'PN_CAFM_SPACE_UNABLE_TO_UPD');
                 fnd_message.set_token('SPACE_ALLOCATION_ID', space.EMP_SPACE_ASSIGN_ID);
                 l_error_message := fnd_message.get;
                 Raise INVALID_RECORD;
             end if;

             space.emp_assign_start_date :=  NVL( space.change_date, SYSDATE );

         end if;

       End if;

       If (space.ENTRY_TYPE = 'U' ) Then

          PNP_UTIL_FUNC.Validate_date_for_assignments (
             p_location_id => space.LOCATION_ID,     --Bug#5587012
             p_start_date  => space.emp_assign_start_date,
             p_end_date    => space.emp_assign_end_date,
             x_return_status   => l_return_status,
             x_return_message  => l_return_message
          );

          IF NOT( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
             l_error_message := fnd_message.get;
             raise INVALID_RECORD; --Bug5515198
         END IF;


         PN_SPACE_ASSIGN_EMP_PKG.update_row
         (
         X_EMP_SPACE_ASSIGN_ID          =>   space.EMP_SPACE_ASSIGN_ID,
         X_ATTRIBUTE1                   =>   space.ATTRIBUTE1,
         X_ATTRIBUTE2                   =>   space.ATTRIBUTE2,
         X_ATTRIBUTE3                   =>   space.ATTRIBUTE3,
         X_ATTRIBUTE4                   =>   space.ATTRIBUTE4,
         X_ATTRIBUTE5                   =>   space.ATTRIBUTE5,
         X_ATTRIBUTE6                   =>   space.ATTRIBUTE6,
         X_ATTRIBUTE7                   =>   space.ATTRIBUTE7,
         X_ATTRIBUTE8                   =>   space.ATTRIBUTE8,
         X_ATTRIBUTE9                   =>   space.ATTRIBUTE9,
         X_ATTRIBUTE10                  =>   space.ATTRIBUTE10,
         X_ATTRIBUTE11                  =>   space.ATTRIBUTE11,
         X_ATTRIBUTE12                  =>   space.ATTRIBUTE12,
         X_ATTRIBUTE13                  =>   space.ATTRIBUTE13,
         X_ATTRIBUTE14                  =>   space.ATTRIBUTE14,
         X_ATTRIBUTE15                  =>   space.ATTRIBUTE15,
         X_LOCATION_ID                  =>   space.LOCATION_ID,
         X_PERSON_ID                    =>   space.EMPLOYEE_ID,
         X_PROJECT_ID                   =>   space.PROJECT_ID,
         X_TASK_ID                      =>   space.TASK_ID,
         X_EMP_ASSIGN_START_DATE        =>   space.EMP_ASSIGN_START_DATE,
         X_EMP_ASSIGN_END_DATE          =>   space.EMP_ASSIGN_END_DATE,
         X_COST_CENTER_CODE             =>   space.COST_CENTER_CODE,
         X_ALLOCATED_AREA_PCT           =>   l_allocated_area_pct,
         X_ALLOCATED_AREA               =>   space.ALLOCATED_AREA,
         X_UTILIZED_AREA                =>   space.UTILIZED_AREA,
         X_EMP_SPACE_COMMENTS           =>   NULL,
         X_ATTRIBUTE_CATEGORY           =>   space.ATTRIBUTE_CATEGORY,
         X_LAST_UPDATE_DATE             =>   sysdate,
         X_LAST_UPDATED_BY              =>   nvl(fnd_profile.value('USER_ID'), 0),
         X_LAST_UPDATE_LOGIN            =>   nvl(fnd_profile.value('CONC_LOGIN_ID'), 0),
         X_UPDATE_CORRECT_OPTION        =>   space.change_mode,
         X_CHANGED_START_DATE           =>   l_changed_start_date,
         X_SOURCE                       =>   space.source
         );

      End if; -- 'A/U'


--- for BUG#2127286 added the IF condtion for ENTRY TYPE as 'R'

       --------------------------------------
      -- Replace Data in PN_SPACE_ALLOCATIONS
      --------------------------------------
      if (space.ENTRY_TYPE = 'R') then

          PNP_UTIL_FUNC.Validate_date_for_assignments (
             p_location_id =>NVL(space.LOCATION_ID,tlempinfo.LOCATION_ID),  --Bug#5587012
             p_start_date  =>NVL(space.EMP_ASSIGN_START_DATE,tlempinfo.EMP_ASSIGN_START_DATE),
             p_end_date    =>NVL(space.EMP_ASSIGN_START_DATE,tlempinfo.EMP_ASSIGN_START_DATE),
             x_return_status   => l_return_status,
             x_return_message  => l_return_message
          );

          IF NOT( l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             fnd_message.set_name('PN', 'PN_INVALID_SPACE_ASSGN_DATE');
             l_error_message := fnd_message.get;
             raise INVALID_RECORD; --Bug5515198
         END IF;


         PN_SPACE_ASSIGN_EMP_PKG.update_row
         (
         X_EMP_SPACE_ASSIGN_ID          =>   NVL(space.EMP_SPACE_ASSIGN_ID,tlempinfo.EMP_SPACE_ASSIGN_ID),
         X_ATTRIBUTE1                   =>   NVL(space.ATTRIBUTE1,tlempinfo.ATTRIBUTE1),
         X_ATTRIBUTE2                   =>   NVL(space.ATTRIBUTE2,tlempinfo.ATTRIBUTE2),
         X_ATTRIBUTE3                   =>   NVL(space.ATTRIBUTE3,tlempinfo.ATTRIBUTE3),
         X_ATTRIBUTE4                   =>   NVL(space.ATTRIBUTE4,tlempinfo.ATTRIBUTE4),
         X_ATTRIBUTE5                   =>   NVL(space.ATTRIBUTE5,tlempinfo.ATTRIBUTE5),
         X_ATTRIBUTE6                   =>   NVL(space.ATTRIBUTE6,tlempinfo.ATTRIBUTE6),
         X_ATTRIBUTE7                   =>   NVL(space.ATTRIBUTE7,tlempinfo.ATTRIBUTE7),
         X_ATTRIBUTE8                   =>   NVL(space.ATTRIBUTE8,tlempinfo.ATTRIBUTE8),
         X_ATTRIBUTE9                   =>   NVL(space.ATTRIBUTE9,tlempinfo.ATTRIBUTE9),
         X_ATTRIBUTE10                  =>   NVL(space.ATTRIBUTE10,tlempinfo.ATTRIBUTE10),
         X_ATTRIBUTE11                  =>   NVL(space.ATTRIBUTE11,tlempinfo.ATTRIBUTE11),
         X_ATTRIBUTE12                  =>   NVL(space.ATTRIBUTE12,tlempinfo.ATTRIBUTE12),
         X_ATTRIBUTE13                  =>   NVL(space.ATTRIBUTE13,tlempinfo.ATTRIBUTE13),
         X_ATTRIBUTE14                  =>   NVL(space.ATTRIBUTE14,tlempinfo.ATTRIBUTE14),
         X_ATTRIBUTE15                  =>   NVL(space.ATTRIBUTE15,tlempinfo.ATTRIBUTE15),
         X_LOCATION_ID                  =>   NVL(space.LOCATION_ID,tlempinfo.LOCATION_ID),
         X_PERSON_ID                    =>   NVL(space.EMPLOYEE_ID,tlempinfo.PERSON_ID),
         X_PROJECT_ID                   =>   space.PROJECT_ID,
         X_TASK_ID                      =>   space.TASK_ID,
         X_EMP_ASSIGN_START_DATE        =>   NVL(space.EMP_ASSIGN_START_DATE,tlempinfo.EMP_ASSIGN_START_DATE),
         X_EMP_ASSIGN_END_DATE          =>   NVL(space.EMP_ASSIGN_END_DATE,tlempinfo.EMP_ASSIGN_END_DATE),
         X_COST_CENTER_CODE             =>   NVL(space.COST_CENTER_CODE,tlempinfo.COST_CENTER_CODE),
         X_ALLOCATED_AREA_PCT           =>   NVL(l_allocated_area_pct,tlempinfo.ALLOCATED_AREA_PCT),
         X_ALLOCATED_AREA               =>   NVL(space.ALLOCATED_AREA,tlempinfo.ALLOCATED_AREA),
         X_UTILIZED_AREA                =>   NVL(space.UTILIZED_AREA,tlempinfo.UTILIZED_AREA),
         X_EMP_SPACE_COMMENTS           =>   NULL,
         X_ATTRIBUTE_CATEGORY           =>   NVL(space.ATTRIBUTE_CATEGORY,tlempinfo.ATTRIBUTE_CATEGORY),
         X_LAST_UPDATE_DATE             =>   sysdate,
         X_LAST_UPDATED_BY              =>   nvl(fnd_profile.value('USER_ID'), 0),
         X_LAST_UPDATE_LOGIN            =>   nvl(fnd_profile.value('CONC_LOGIN_ID'), 0),
         X_UPDATE_CORRECT_OPTION        =>   space.change_mode,
         X_CHANGED_START_DATE           =>   l_changed_start_date,
         X_SOURCE                       =>   NVL(space.source,tlempinfo.source)
         );


      end if; -- 'R'

      ---For BUG#2127286 End of IF condition for ENTRY TYPE='R'

--auto distri

      If (pn_mo_cache_utils.get_profile_value('PN_AUTOMATIC_SPACE_DISTRIBUTION',l_org_id) = 'Y') Then

          PN_SPACE_ALLOCATIONS_PKG.area_pct_and_area(l_Assignable_area, Space.Location_Id);

      End If;

      ------------------------------------------------
      -- Set pn_emp_space_assign_itf.transferred_to_pn = 'Y'
      ------------------------------------------------

      put_log('Updating transferred to pn flag in itf table');

      update    pn_emp_space_assign_itf
      set       transferred_to_pn     = 'Y',
                error_message = NULL
      where     ROWID   =  space.ROWID;

       put_log('Updated transferred to pn flag in itf table');

      EXCEPTION
        WHEN INVALID_RECORD THEN
          ROLLBACK TO S2;
          l_fail := l_fail + 1;

          -- Update ERROR_MESSAGE
          update pn_emp_space_assign_itf
          set    error_message = substr(l_error_message, 1, 240)
          where  ROWID   =  space.ROWID;

          -- Spool to Conc Log
          put_line(l_error_message);

          errbuf  := l_error_message;
          retcode := '2';

        WHEN OTHERS THEN

          ROLLBACK TO S2;
          l_fail := l_fail + 1;

          l_error_message := fnd_message.get;

          update pn_emp_space_assign_itf
          set    error_message = substr(l_error_message, 1, 240)
          where  ROWID   =  space.ROWID;

          put_line(l_error_message);


          errbuf  := l_error_message;
          retcode := '2';

--Bug5609648  return;

      END;
    COMMIT;
    END LOOP;


    if (l_total = 0) then
      fnd_message.set_name ('PN', 'PN_CAFM_NO_SPC_REC_FOUND');
      errbuf  := fnd_message.get;
      retcode := '2';
      put_line(errbuf);

    else

      l_succ := l_total - l_fail;

      Put_Log('
=============== Summary ===============');

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_SUCCESS');
      fnd_message.set_token('SUCCESS', l_succ);
      put_line(fnd_message.get);

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_FAILURE');
      fnd_message.set_token('FAILURE', l_fail);
      put_line(fnd_message.get);

      fnd_message.set_name('PN', 'PN_CAFM_SPACE_TOTAL');
      fnd_message.set_token('TOTAL', l_total);
      put_line(fnd_message.get);

    end if;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    put_line('EXCEPTION: NO_DATA_FOUND');
    fnd_message.set_name ('PN', 'PN_NO_SPACE_DATA_FOUND');
    errbuf  := l_error_message;
    retcode := '2';
    put_line(errbuf);
    APP_EXCEPTION.raise_exception;


    WHEN OTHERS THEN
      put_line('EXCEPTION: OTHERS');
      fnd_message.set_name ('PN', 'PN_NO_SPACE_DATA_FOUND');
      errbuf  := l_error_message;
      retcode := '2';
      put_line(errbuf);
      APP_EXCEPTION.raise_exception;


END SPACE_ALLOCATIONS_ITF;

/*===========================================================================+
 | PROCEDURE
 |   Put_Log
 |
 | DESCRIPTION
 |   Writes the String passed as argument to Concurrent Log
 |
 | ARGUMENTS: p_String
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | MODIFICATION HISTORY
 |   Created   Naga Vijayapuram  1999
 |
 +===========================================================================*/

Procedure Put_Log(p_String VarChar2) IS

BEGIN

  Fnd_File.Put_Line(Fnd_File.Log,    p_String);

EXCEPTION

  When Others Then Raise;

END Put_Log;


/*===========================================================================+
 | PROCEDURE
 |   Put_Line
 |
 | DESCRIPTION
 |   Writes the String passed as argument to Concurrent Log/Output
 |
 | ARGUMENTS: p_String
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | MODIFICATION HISTORY
 |   Created   Naga Vijayapuram  1999
 |
 +===========================================================================*/

Procedure Put_Line(p_String VarChar2) IS

BEGIN

    Fnd_File.Put_Line(Fnd_File.Log,    p_String);
    Fnd_File.Put_Line(Fnd_File.Output, p_String);

EXCEPTION

  When Others Then Raise;

END Put_Line;


-------------------------------
-- End of Package
-------------------------------
END PN_CAD_IMPORT;

/
