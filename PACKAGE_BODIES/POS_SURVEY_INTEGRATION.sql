--------------------------------------------------------
--  DDL for Package Body POS_SURVEY_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SURVEY_INTEGRATION" AS
/* $Header: POSSURIB.pls 120.2 2005/12/07 18:25:48 abtrived noship $ */



PROCEDURE save_transaction
 (p_flow_key IN VARCHAR2,
  p_supplier_reg_id IN NUMBER,
  p_vendor_id IN NUMBER,
  p_survey_transaction_id IN NUMBER,
  p_respondent_table_name IN VARCHAR2,
  p_respondent_id IN NUMBER,
  x_status OUT NOCOPY VARCHAR2,
  x_msg  OUT NOCOPY VARCHAR2,
  p_map_id IN NUMBER default null
  ) IS

 CURSOR l_mapping_cur1 IS
 SELECT mapping_id
 FROM pos_supplier_mappings
 WHERE supplier_reg_id = p_supplier_reg_id;

 CURSOR l_mapping_cur2 IS
 SELECT mapping_id
 FROM pos_supplier_mappings
 WHERE vendor_id = p_vendor_id;

 l_mapping_id NUMBER;

 CURSOR l_transaction_cur IS
 SELECT transaction_id, supplier_update_flag
 FROM pos_survey_transactions
 WHERE supplier_mapping_id = l_mapping_id
 AND survey_transaction_id = p_survey_transaction_id;

 l_transaction_id NUMBER;
 l_supplier_update_flag VARCHAR2(1);

BEGIN

 x_msg := ' :txn_id = ' || p_survey_transaction_id;
 x_status := '10';

 IF p_respondent_table_name NOT IN ('FND_USER', 'HZ_PARTIES') THEN
   x_status := 'E';
   x_msg := 'POS_SURVEY_BAD_RESP_TABLE_NAME' || fnd_message.get('POS_SURVEY_BAD_RESP_TABLE_NAME');
   RETURN;
 END IF;

 x_status := '20';


 IF (p_flow_key = 'SUPPREG')  THEN

  /* abhi - for SUPPREG, data is not committed to DB, need to pass the mapping_id as param instead of getting from DB */

  l_mapping_id := p_map_id;
  x_status := '25';

 ELSIF (p_flow_key = 'BUYERSUPPREG') THEN

  OPEN l_mapping_cur1;
  FETCH l_mapping_cur1 INTO l_mapping_id;
  IF l_mapping_cur1%notfound THEN
   CLOSE l_mapping_cur1;
   x_status := 'E';
   x_msg := 'POS_SURVEY_BAD_REG_ID' || fnd_message.get('POS_SURVEY_BAD_REG_ID');
   RETURN;
  END IF;
  CLOSE l_mapping_cur1;
  x_status := '30';

 ELSIF p_flow_key IN ('SPMSUPPLIER', 'SPMBUYER') THEN

  OPEN l_mapping_cur2;
  FETCH l_mapping_cur2 INTO l_mapping_id;
  IF l_mapping_cur2%notfound THEN
   CLOSE l_mapping_cur2;
   x_status := 'E';
   x_msg := 'POS_SURVEY_BAD_VENDOR_ID' || fnd_message.get('POS_SURVEY_BAD_VENDOR_ID');
   RETURN;
  END IF;
  CLOSE l_mapping_cur2;

  x_status := '40';

 ELSE

  x_status := 'E';
  x_msg := 'POS_SURVEY_BAD_FLOW_KEY' || fnd_message.get('POS_SURVEY_BAD_FLOW_KEY');
  RETURN;

 END IF;

 x_status := '50';

 OPEN l_transaction_cur;
 FETCH l_transaction_cur INTO l_transaction_id, l_supplier_update_flag;
 IF l_transaction_cur%notfound THEN
  CLOSE l_transaction_cur;

  -- need to insert
  IF p_respondent_table_name = 'POS_CONTACT_REQUESTS' THEN
    l_supplier_update_flag := 'Y';
  ELSE
    l_supplier_update_flag := 'N';
  END IF;

  x_status := '60';

  INSERT INTO pos_survey_transactions
   (transaction_id, supplier_mapping_id, survey_transaction_id, created_by,
    creation_date, last_updated_by, last_update_date, last_update_login,
    respondent_table_name, respondent_id, supplier_update_flag)
  VALUES
   (pos_survey_transactions_s.NEXTVAL, l_mapping_id, p_survey_transaction_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_respondent_table_name, p_respondent_id, l_supplier_update_flag);

 ELSE

  CLOSE l_transaction_cur;

  --need to update
  IF ((l_supplier_update_flag IS NULL OR l_supplier_update_FLAG <> 'Y')
     AND (p_respondent_table_name <> 'POS_CONTACT_REQUESTS')) THEN
    l_supplier_update_flag := 'N';
  ELSE
    l_supplier_update_flag := 'Y';
  END IF;

  x_status := '70';

  UPDATE pos_survey_transactions
  SET last_updated_by = fnd_global.user_id,
      last_update_date = sysdate,
      last_update_login = fnd_global.login_id,
      respondent_table_name = p_respondent_table_name,
      respondent_id = p_respondent_id,
      supplier_update_flag = l_supplier_update_flag
  WHERE transaction_id = l_transaction_id;

 END IF;

 commit;
 x_msg := 'Reached the very End' || x_msg;

END save_transaction;





END pos_survey_integration;

/
