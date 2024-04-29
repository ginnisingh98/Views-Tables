--------------------------------------------------------
--  DDL for Package Body JAI_DRILLDOWN_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_DRILLDOWN_UTILS_PKG" AS
/* $Header: jai_drilldown_utils_pkg.plb 120.0.12010000.2 2010/04/15 16:08:06 huhuliu noship $ */


/********************************************************************************************************
 FILENAME      :  jai_drilldown_utils_pkg.plb

 Created By    : Walton

 Created Date  : 15-Apr-2010

 Bug           : 9311844

 Purpose       :  This is the drilldown utility package which contain some common used subprograms.

 Called from   : OFI code

 --------------------------------------------------------------------------------------------------------
 CHANGE HISTORY:
 --------------------------------------------------------------------------------------------------------
 S.No      Date          Author and Details
 --------------------------------------------------------------------------------------------------------
 1.        2010/04/07   Walton Liu
                        Bug No : 9311844
                        Description : The file is changed for ER GL drilldown
                        Fix Details : http://files.oraclecorp.com/content/MySharedFolders/R12.1.3/TDD/TDD_1213_FIN_JAI_GL_Drilldown.doc
                        Doc Impact  : YES
                        Dependencies: YES, refer to Technical Design

 2.        2010/04/15   Xiao Lv
                        Bug No : 9311844
                        Description : The file is changed for ER GL drilldown
                        Fix Details : http://files.oraclecorp.com/content/MySharedFolders/R12.1.3/TDD/TDD_1213_FIN_JAI_GL_Drilldown.doc
                        Doc Impact  : YES
                        Dependencies: YES, refer to Technical Design


***************************************************************************************************************/

--==========================================================================
--  FUNCTION NAME:
--
--    if_accounted                      Public
--
--  DESCRIPTION:
--
--    This function is used to check if accounting entries for OFI transactions
--    was imported into GL journal or not.
--
--  PARAMETERS:
--      In:  pv_view_name            Name of base view
--           pn_transaction_id       Identifier of transaction header
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Walton   created
--==========================================================================
FUNCTION if_accounted (pv_view_name VARCHAR2, pn_transaction_id NUMBER) RETURN BOOLEAN is
  v_view_name varchar2(80);
  v_trx_header_id number;
  v_sql varchar2 (1000);
  v_result number;
BEGIN
  v_view_name:=pv_view_name;
  v_trx_header_id:=pn_transaction_id;
  v_sql:='select count(1) from '||v_view_name||' where TRX_HDR_ID= '||to_char(v_trx_header_id);
  execute immediate v_sql into v_result;

  if v_result>0 then
    return true;
  else
    return false;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END if_accounted;

--==========================================================================
--  FUNCTION NAME:
--
--    get_transfer_number                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination transfer number.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================

FUNCTION get_transfer_number(pn_transfer_id IN NUMBER
                                             , pn_org_id IN NUMBER
                                             , pn_balance IN NUMBER) RETURN NUMBER IS
  ln_transfer_number NUMBER;
  ln_source_org_id NUMBER;

  CURSOR get_source_org_id_cur IS
  SELECT party_id
    FROM jai_rgm_dis_src_hdrs
   WHERE transfer_id = pn_transfer_id;

BEGIN

  OPEN get_source_org_id_cur;
  FETCH get_source_org_id_cur INTO ln_source_org_id;
  CLOSE get_source_org_id_cur;

  IF ( pn_org_id = ln_source_org_id) THEN -- 'Distribution Out'
  -- fetch transfer_number by pn_balance, if get multi records, return NULL
    SELECT DISTINCT transfer_number
      INTO ln_transfer_number
      FROM jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE round(jrddt.transfer_amount,2) = pn_balance
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(ln_transfer_number);

  ELSE   -- 'Distribution In'
  -- fetch transfer_number by pn_balance, pn_org_id(des org id),
  -- if get multi records, return NULL
    SELECT DISTINCT transfer_number
      INTO ln_transfer_number
      FROM jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE round(jrddt.transfer_amount,2) = pn_balance

       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id

       AND jrddh.destination_party_id = pn_org_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(ln_transfer_number);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  -- exception when accountings are 'Distribution In' and distribtion taxes amount
  -- are same.
    RETURN to_number(NULL);
END get_transfer_number;


--==========================================================================
--  FUNCTION NAME:
--
--    get_des_org_name                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization name.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================
FUNCTION get_des_org_name(pn_transfer_id IN NUMBER
                                          , pn_org_id IN NUMBER
                                          , pn_balance IN NUMBER) RETURN VARCHAR2 IS
  ln_source_org_id NUMBER;
  ln_des_org_name VARCHAR2(80);

  CURSOR get_source_org_id_cur IS
  SELECT party_id
    FROM jai_rgm_dis_src_hdrs
   WHERE transfer_id = pn_transfer_id;

   CURSOR get_des_org_name_cur(pn_id IN NUMBER) IS
   SELECT organization_name
     FROM org_organization_definitions
    WHERE organization_id = pn_id;

BEGIN

  OPEN get_source_org_id_cur;
  FETCH get_source_org_id_cur INTO ln_source_org_id;
  CLOSE get_source_org_id_cur;

  IF ( pn_org_id = ln_source_org_id) THEN -- 'Distribution Out'
    SELECT DISTINCT organization_name
      INTO ln_des_org_name
      FROM jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt,
           org_organization_definitions ood

     WHERE round(jrddt.transfer_amount,2) = pn_balance
       AND jrddh.destination_party_id = ood.organization_id
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrddh.transfer_id = pn_transfer_id;

  ELSE                                    -- 'Distribution In'
    OPEN get_des_org_name_cur(pn_org_id);
    FETCH get_des_org_name_cur INTO ln_des_org_name;
    CLOSE get_des_org_name_cur;
  END IF;

  RETURN(ln_des_org_name);

EXCEPTION
  WHEN OTHERS THEN
  -- exception when accountings are 'Distribution In' and distribtion taxes amount
  -- are same, and transfer to multi-orgs.
    RETURN NULL;
END get_des_org_name;

--==========================================================================
--  FUNCTION NAME:
--
--    get_des_org_type                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization type.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================
FUNCTION get_des_org_type(pn_transfer_id IN NUMBER
                                             , pn_org_id IN NUMBER
                                             , pn_balance IN NUMBER) RETURN VARCHAR IS
  lv_des_org_type VARCHAR2(200);
  ln_source_org_id NUMBER;

  CURSOR get_source_org_id_cur IS
  SELECT party_id
    FROM jai_rgm_dis_src_hdrs
   WHERE transfer_id = pn_transfer_id;

BEGIN

  OPEN get_source_org_id_cur;
  FETCH get_source_org_id_cur INTO ln_source_org_id;
  CLOSE get_source_org_id_cur;

  IF ( pn_org_id = ln_source_org_id) THEN -- 'Distribution Out'
    SELECT DISTINCT ja.meaning
      INTO lv_des_org_type
      FROM ja_lookups           ja,
           jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE ja.lookup_type = 'JAI_ORGANIZATION_TYPES'
       AND ja.lookup_code = jrddh.destination_party_type

       AND round(jrddt.transfer_amount,2) = pn_balance
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(lv_des_org_type);
  ELSE                                    -- 'Distribution In'
        SELECT DISTINCT ja.meaning
      INTO lv_des_org_type
      FROM ja_lookups           ja,
           jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE ja.lookup_type = 'JAI_ORGANIZATION_TYPES'
       AND ja.lookup_code = jrddh.destination_party_type

       AND round(jrddt.transfer_amount,2) = pn_balance
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrddh.destination_party_id = pn_org_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(lv_des_org_type);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  -- exception when accountings are 'Distribution In' and distribtion taxes amount
  -- are same and transfer to multi-orgs with different types.
    RETURN NULL;
END get_des_org_type;


--==========================================================================
--  FUNCTION NAME:
--
--    get_des_loc_name                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization location name.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================
FUNCTION get_des_loc_name(pn_transfer_id IN NUMBER
                                             , pn_org_id IN NUMBER
                                             , pn_balance IN NUMBER) RETURN VARCHAR IS
  lv_des_loc_name VARCHAR2(200);
  ln_source_org_id NUMBER;

  CURSOR get_source_org_id_cur IS
  SELECT party_id
    FROM jai_rgm_dis_src_hdrs
   WHERE transfer_id = pn_transfer_id;

BEGIN

  OPEN get_source_org_id_cur;
  FETCH get_source_org_id_cur INTO ln_source_org_id;
  CLOSE get_source_org_id_cur;

  IF ( pn_org_id = ln_source_org_id) THEN -- 'Distribution Out'
    SELECT DISTINCT hr.description
      INTO lv_des_loc_name
      FROM hr_locations         hr,
           jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE hr.location_id(+) = jrddh.location_id
       AND round(jrddt.transfer_amount,2) = pn_balance
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(lv_des_loc_name);
  ELSE                                    -- 'Distribution In'
     SELECT DISTINCT hr.description
      INTO lv_des_loc_name
      FROM hr_locations         hr,
           jai_rgm_dis_des_hdrs jrddh,
           jai_rgm_dis_src_taxes jrdst,
           jai_rgm_dis_des_taxes jrddt

     WHERE hr.location_id(+) = jrddh.location_id
       AND round(jrddt.transfer_amount,2) = pn_balance
       AND jrdst.transfer_source_id = jrddt.transfer_source_id
       AND jrdst.transfer_id = pn_transfer_id
       AND jrddh.transfer_destination_id = jrddt.transfer_destination_id
       AND jrddh.destination_party_id = pn_org_id
       AND jrddh.transfer_id = pn_transfer_id;

    RETURN(lv_des_loc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  -- exception when accountings are 'Distribution In' and distribtion taxes amount
  -- are same, and transfer to multi-locations within same orgs.
    RETURN NULL;
END get_des_loc_name;


END JAI_DRILLDOWN_UTILS_PKG;

/
