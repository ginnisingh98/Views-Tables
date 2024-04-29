--------------------------------------------------------
--  DDL for Package Body POA_DBI_COM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_COM_C" AS
/* $Header: poadbicomcrb.pls 120.2 2008/02/25 10:07:20 nchava noship $ */

/* ***************************************************************************
* Procedure Name  : proc_commodity_check                                    *
* Description     : Procedure to determine whether the commodity exists     *
*                   or not                                                  *
* File Name       : poadbicomcrb.pls                                        *
* Visibility      : Public                                                  *
* Parameters/Mode : None                                                    *
* History         : 14-Nov-2006 ANKGOYAL Initial Creation                   *
*                                                                           *
*************************************************************************** */


PROCEDURE proc_commodity_check (
  errbuf    OUT NOCOPY VARCHAR2,
  retcode   OUT NOCOPY NUMBER
  )
IS
  l_start_time DATE;
  l_login NUMBER;
  l_user NUMBER;
  v_commodity_code varchar2(3000);
  v_check_flag INTEGER :=0;
  v_nextval NUMBER;

BEGIN
  -- Get the value of new commodity code into the variable v_commodity_code
  v_commodity_code := fnd_message.get_string('POA','POA_DBI_DEFAULT_COMMODITY');
  bis_collection_utilities.log('Retrieved commodity code as "' || v_commodity_code||'"',0);
  ----Extract 40 characters and Trim the spaces
  v_commodity_code := trim(substr(v_commodity_code,1,40));
  bis_collection_utilities.log('Truncated commodity code is  "'|| v_commodity_code||'"',0);
  -- Check if the commodity exists or not
  SELECT COUNT(*) INTO v_check_flag FROM
  po_commodities_b WHERE commodity_code=v_commodity_code;
  IF (v_check_flag=0) THEN

    -- Get the values for the WHO columns
    l_start_time := SYSDATE;
    l_login := fnd_global.login_id;
    l_user := fnd_global.user_id;

    --Get the commodity id in the variable
    SELECT po_commodities_s.NEXTVAL INTO v_nextval FROM dual;
    --Insert into the table po_commodities_b
    INSERT INTO po_commodities_b (
      commodity_id,
      commodity_code,
      active_flag,
      creation_date,
      last_update_date,
      created_by,
      last_updated_by,
      last_update_login )
      VALUES
      (
      v_nextval,
      v_commodity_code,
      'Y',
      l_start_time,
      l_start_time,
      l_user,
      l_user,
      l_login
    );

    -- Insert into the table po_commodities_tl
    INSERT INTO po_commodities_tl (
      commodity_id,
      language,
      source_lang,
      name,
      description,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login)
      (
      SELECT
      v_nextval commodity_id,
      lang.language_code language,
      userenv('LANG') source_lang,
      v_commodity_code name,
      v_commodity_code description,
      l_start_time creation_date,
      l_user created_by,
      l_start_time last_update_date,
      l_user last_updated_by,
      l_login last_update_login
      FROM
      fnd_languages lang
      WHERE
      lang.installed_flag IN ('I','B')
    );

    COMMIT;
    bis_collection_utilities.log('Commodity Created',0);

  END IF;
  -- Calling procedure to assign all unassigned categories of the
  -- Purchasing category set to the default commodity

  proc_category_commodity_update(errbuf,retcode);

EXCEPTION

  WHEN OTHERS THEN
    Errbuf:= Sqlerrm;
    Retcode:=sqlcode;
    ROLLBACK;
    POA_LOG.debug_line('proc_commodity_check' || Sqlerrm || sqlcode || sysdate);
    RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);

END proc_commodity_check;


/****************************************************************************
* End of Procedure : proc_commodity_check
*****************************************************************************/


/****************************************************************************
* Procedure Name  : proc_category_commodity_update                          *
* Description     : Procedureto to update the categories                    *
* File Name       : poadbicomcrb.pls                                        *
* Visibility      : Public                                                  *
* Parameters/Mode : None                                                    *
* History         : 14-Nov-2006 ANKGOYAL Initial Creation                   *
*                                                                           *
****************************************************************************/
/* Procedureto to update the categories */

PROCEDURE proc_category_commodity_update (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER)
  IS
  l_start_time DATE;
  l_login NUMBER;
  l_user NUMBER;
  -- Variable for storing the new commodity code.
  v_commodity_code varchar2(3000);
  -- Variable for storing the new commodity id
  v_commodity_id po_commodities_b.commodity_id%type;

  BEGIN
  -- Get the values in the WHO columns
  l_start_time := sysdate;
  l_login := fnd_global.login_id;
  l_user := fnd_global.user_id;
  --Get the value of new commodity code into the variable v_commodity_code
  v_commodity_code := fnd_message.get_string('POA','POA_DBI_DEFAULT_COMMODITY');
  --Extract 40 characters and Trim the spaces
  v_commodity_code := trim(substr(v_commodity_code,1,40));
  --Store the commodity id into the variable
  SELECT commodity_id INTO v_commodity_id from po_commodities_b
  WHERE commodity_code=v_commodity_code;

  -- Insert Record in the table
  INSERT INTO po_commodity_categories (
    commodity_id,
    category_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login)
    (
    SELECT
    v_commodity_id commodity_id,
    mcat.category_id category_id,
    l_start_time creation_date,
    l_user created_by,
    l_start_time last_update_date,
    l_user last_updated_by,
    l_login last_update_login
    FROM
    mtl_category_set_valid_cats mcat
    WHERE
    mcat.category_set_id = 2 -- Consider only categories of the purchasing category set
    AND NOT EXISTS ( SELECT 1  FROM po_commodity_categories pcc
    WHERE pcc.category_id=mcat.category_id)
  );


  bis_collection_utilities.log(SQL%ROWCOUNT||' Categories associated with '
  ||v_commodity_code,0);
  COMMIT;

EXCEPTION
WHEN OTHERS THEN
  Errbuf:= Sqlerrm;
  Retcode:=sqlcode;
  ROLLBACK;
  POA_LOG.debug_line('commodity_check' || Sqlerrm || sqlcode || sysdate);
  RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);

END proc_category_commodity_update;

/****************************************************************************
* End of Procedure : proc_category_commodity_update
*****************************************************************************/

END POA_DBI_COM_C;

/****************************************************************************
* End of Package : poa_dbi_com_c
*****************************************************************************/


/
