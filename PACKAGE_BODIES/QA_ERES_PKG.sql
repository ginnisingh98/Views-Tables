--------------------------------------------------------
--  DDL for Package Body QA_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_ERES_PKG" as
   /* $Header: qaeresb.pls 115.2 2004/05/11 01:32:38 ilawler noship $ */

   /* Cache of the last parsed transactionId */
   x_last_transaction_id        VARCHAR2(2000);
   x_last_plan_id               NUMBER;
   x_last_collection_id         NUMBER;
   x_last_occurrence            NUMBER;

   /*
     Private utility function for Collapse_Msg_Tokens.  Locates the next
     token name so we can expand it.
   */
   FUNCTION find_long_token(p_msg VARCHAR2) RETURN VARCHAR2 IS
      i INTEGER;
      j INTEGER;
   BEGIN
      i := instr(p_msg, SUFFIXSTRING);
      j := instr(p_msg, '&', i-LENGTH(p_msg));
      RETURN substr(p_msg, j, i-j);
   END find_long_token;

   /*
     Private utility function for Collapse_Msg_Tokens.  Expands a token
     name to the long form for simple search-replace matching.
   */
   FUNCTION expanded_token_string (l_token VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      RETURN l_token || SUFFIXSTRING || '1' ||
         l_token || SUFFIXSTRING || '2' ||
         l_token || SUFFIXSTRING || '3' ||
         l_token || SUFFIXSTRING || '4' ||
         l_token || SUFFIXSTRING || '5' ||
         l_token || SUFFIXSTRING || '6' ||
         l_token || SUFFIXSTRING || '7' ||
         l_token || SUFFIXSTRING || '8' ||
         l_token || SUFFIXSTRING || '9' ||
         l_token || SUFFIXSTRING || '10';
   END expanded_token_string;

   FUNCTION Collapse_Msg_Tokens (p_msg VARCHAR2) RETURN VARCHAR2 IS
      l_msg VARCHAR2(4000);
      tok   VARCHAR2(200);
   BEGIN
      l_msg := p_msg;
      LOOP
         tok := find_long_token(l_msg);
         EXIT WHEN tok IS NULL;
         l_msg := replace(l_msg, expanded_token_string(tok), tok);
      END LOOP;
      RETURN l_msg;
   END Collapse_Msg_Tokens;

   FUNCTION get_category_name(p_category_id IN NUMBER, p_category_set_id IN NUMBER)
      RETURN VARCHAR2
   IS
        x_name varchar2(240) := null;
        CURSOR c IS
            SELECT MCK.concatenated_segments
            FROM   mtl_categories_kfv MCK, MTL_CATEGORY_SETS_B CSET
            WHERE  CSET.CATEGORY_SET_ID = p_category_set_id AND
                   MCK.STRUCTURE_ID = CSET.STRUCTURE_ID AND
                   MCK.CATEGORY_ID = p_category_id;
   BEGIN
      OPEN c;
      FETCH c INTO x_name;
      CLOSE c;

      RETURN x_name;
   END;

   FUNCTION get_category_desc(p_category_id IN NUMBER, p_category_set_id IN NUMBER)
      RETURN VARCHAR2
   IS
        l_desc varchar2(240) := null;
        CURSOR c IS
            SELECT MCK.description
            FROM   mtl_categories_vl MCK, MTL_CATEGORY_SETS_B CSET
            WHERE  CSET.CATEGORY_SET_ID = p_category_set_id AND
                   MCK.STRUCTURE_ID = CSET.STRUCTURE_ID AND
                   MCK.CATEGORY_ID = p_category_id;
   BEGIN
      OPEN c;
      FETCH c INTO l_desc;
      CLOSE c;

      RETURN l_desc;
   END;

   /*
     Mon May 10 17:43:58 2004 - ilawler - bug #3599451

     Private utility function for get_result_column_value.  This is similar to
     qa_core_pkg.get_result_column_name except it collapses the 3 cursors into one.

     p_plan_id  NUMBER  => collection plan id
     p_char_id  NUMBER  => collection element id

     RETURNS VARCHAR2 name of the column in qa_results_full_v or NULL if char_id not
                      in the plan_id's definition.
   */
   FUNCTION get_result_column_name(p_plan_id    IN NUMBER,
                                   p_char_id    IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR C1 (c_plan_id NUMBER, c_char_id NUMBER) IS
         SELECT DECODE(qc.hardcoded_column, NULL, qpc.result_column_name, qc.developer_name) rescol
         FROM QA_PLAN_CHARS qpc,
              QA_CHARS qc
         WHERE qc.char_id = qpc.char_id AND
               qpc.plan_id = c_plan_id AND
               qpc.char_id = c_char_id;

      l_rescol VARCHAR2(2400);
   BEGIN
      OPEN C1(p_plan_id, p_char_id);
      FETCH C1 INTO l_rescol;
      IF C1%NOTFOUND THEN
         CLOSE C1;
         RETURN '';
      ELSE
         CLOSE C1;
      END IF;

      return l_rescol;
   END;

   FUNCTION get_result_column_value(p_plan_id           IN NUMBER,
                                    p_collection_id     IN NUMBER,
                                    p_occurrence        IN NUMBER,
                                    p_char_id           IN NUMBER)
      RETURN VARCHAR2
   IS
      l_rescol          VARCHAR2(2400);
      l_rescol_value    VARCHAR2(4000);
      l_stmt            VARCHAR2(4000);
   BEGIN
      l_rescol := get_result_column_name(p_plan_id, p_char_id);

      --now perform an execute immediate using this column
      l_stmt := 'SELECT '||l_rescol||' FROM QA_RESULTS_FULL_V WHERE plan_id = :2 and collection_id = :3 and occurrence = :4';
      EXECUTE IMMEDIATE l_stmt INTO l_rescol_value USING p_plan_id, p_collection_id, p_occurrence;
      RETURN l_rescol_value;
   END;


   FUNCTION decode_wsh_released_status(p_source_code            IN VARCHAR2,
                                       p_released_status        IN VARCHAR2,
                                       p_released_status_name   IN VARCHAR2,
                                       p_inv_interfaced_flag    IN VARCHAR2,
                                       p_oe_interfaced_flag     IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_return_str WSH_DLVY_DELIVERABLES_V.RELEASED_STATUS_NAME%TYPE;
   BEGIN
      l_return_str := p_released_status_name;

      IF (p_source_code = 'OE'
          AND p_released_status = 'C'
          AND p_oe_interfaced_flag = 'Y'
          AND p_inv_interfaced_flag IN ('X','Y'))
         OR
         (p_source_code <> 'OE'
          AND p_released_status = 'C'
          AND p_inv_interfaced_flag = 'Y') THEN
         BEGIN
            SELECT meaning
               INTO   l_return_str
               FROM   wsh_lookups
               WHERE  lookup_type = 'PICK_STATUS'
               AND    lookup_code = 'I';
         EXCEPTION
            WHEN OTHERS THEN
               l_return_str := NULL;
         END;
      END IF;

      return l_return_str;
   END;

   FUNCTION decode_po_hazard_class(p_interface_transaction_id   IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR C1 IS
         SELECT DECODE(rt.source_document_code, 'RMA', MSI.HAZARD_CLASS_ID, NVL(POL.HAZARD_CLASS_ID, MSI.HAZARD_CLASS_ID)) HAZARD_CLASS_ID
         FROM RCV_TRANSACTIONS_INTERFACE RT, MTL_SYSTEM_ITEMS MSI, PO_LINES_ALL POL
         WHERE rt.interface_transaction_id = p_interface_transaction_id AND
               rt.to_organization_id = MSI.ORGANIZATION_ID(+) AND
               rt.item_id = MSI.INVENTORY_ITEM_ID(+) AND
               rt.po_line_id = POL.PO_LINE_ID(+);

      CURSOR C2 (p_hazard_class_id NUMBER) IS
         SELECT HAZARD_CLASS
         FROM PO_HAZARD_CLASSES_VL
         WHERE HAZARD_CLASS_ID = p_hazard_class_id;

      l_hazard_class_id NUMBER;
      l_hazard_class PO_HAZARD_CLASSES_VL.HAZARD_CLASS%TYPE;
   BEGIN
      OPEN C1;
      FETCH C1 INTO l_hazard_class_id;
      IF C1%NOTFOUND OR l_hazard_class_id IS NULL THEN
         CLOSE C1;
         RETURN NULL;
      ELSE
         CLOSE C1;
      END IF;

      OPEN C2(l_hazard_class_id);
      FETCH C2 INTO l_hazard_class;
      IF C2%NOTFOUND THEN
         CLOSE C2;
         RETURN NULL;
      ELSE
         CLOSE C2;
      END IF;

      return l_hazard_class;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
   END;

   FUNCTION decode_po_un_number(p_interface_transaction_id      IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR C1 IS
         SELECT DECODE(rt.source_document_code, 'RMA', MSI.UN_NUMBER_ID, NVL(POL.UN_NUMBER_ID, MSI.UN_NUMBER_ID)) UN_NUMBER_ID
         FROM RCV_TRANSACTIONS_INTERFACE RT, MTL_SYSTEM_ITEMS MSI, PO_LINES_ALL POL
         WHERE rt.interface_transaction_id = p_interface_transaction_id AND
               rt.to_organization_id = MSI.ORGANIZATION_ID(+) AND
               rt.item_id = MSI.INVENTORY_ITEM_ID(+) AND
               rt.po_line_id = POL.PO_LINE_ID(+);

      CURSOR C2 (p_un_number_id NUMBER) IS
         SELECT UN_NUMBER
         FROM PO_UN_NUMBERS_VL
         WHERE UN_NUMBER_ID = p_un_number_id;

      l_un_number_id NUMBER;
      l_un_number PO_UN_NUMBERS_VL.UN_NUMBER%TYPE;
   BEGIN
      OPEN C1;
      FETCH C1 INTO l_un_number_id;
      IF C1%NOTFOUND OR l_un_number_id IS NULL THEN
         CLOSE C1;
         RETURN NULL;
      ELSE
         CLOSE C1;
      END IF;

      OPEN C2(l_un_number_id);
      FETCH C2 INTO l_un_number;
      IF C2%NOTFOUND THEN
         CLOSE C2;
         RETURN NULL;
      ELSE
         CLOSE C2;
      END IF;

      return l_un_number;

      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
   END;

   FUNCTION get_result_column_value(p_transaction_id    IN VARCHAR2,
                                    p_char_id           IN NUMBER)
      RETURN VARCHAR2
   IS
      l_d_pos1          NUMBER;
      l_d_pos2          NUMBER;
      l_plan_id         NUMBER;
      l_collection_id   NUMBER;
      l_occurrence      NUMBER;
      l_rescol          VARCHAR2(2400);
      l_rescol_value    VARCHAR2(4000);
      l_stmt            VARCHAR2(4000);
      l_char_prompt     VARCHAR2(200);
   BEGIN
      --see if the transaction_id's the same as the last one we parsed
      IF p_transaction_id = x_last_transaction_id THEN
         l_plan_id := x_last_plan_id;
         l_collection_id := x_last_collection_id;
         l_occurrence := x_last_occurrence;
      ELSE
         --parse the new transaction id
         l_d_pos1 := instr(p_transaction_id, '-');
         l_d_pos2 := instr(p_transaction_id, '-', l_d_pos1+1);
         IF (l_d_pos1 > 0 AND l_d_pos2 > 0) THEN
            l_plan_id := to_number(substr(p_transaction_id, 1, l_d_pos1-1));
            l_collection_id := to_number(substr(p_transaction_id, l_d_pos1+1, l_d_pos2-l_d_pos1-1));
            l_occurrence := to_number(substr(p_transaction_id, l_d_pos2+1));

            --cache it for future calls - useful for multiple AME conditions
            x_last_plan_id := l_plan_id;
            x_last_collection_id := l_collection_id;
            x_last_occurrence := l_occurrence;
            x_last_transaction_id := p_transaction_id;
         END IF;
      END IF;

      --obtain the name of the qa_results_full_v column
      l_rescol := get_result_column_name(l_plan_id, p_char_id);

      --now perform an execute immediate using this column if a column was found
      IF l_rescol IS NOT NULL THEN
         l_stmt := 'SELECT DISTINCT '||l_rescol||' FROM QA_RESULTS_FULL_V WHERE plan_id = :1 and collection_id = :2 and occurrence = NVL(:3, occurrence)';
         EXECUTE IMMEDIATE l_stmt INTO l_rescol_value USING l_plan_id, l_collection_id, l_occurrence;
      ELSE
         l_rescol_value := '';
      END IF;

      RETURN l_rescol_value;

   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         --lookup the char's prompt for the error message
        l_char_prompt := qa_plan_element_api.get_prompt(l_plan_id, p_char_id);

        fnd_message.set_name('QA', 'QA_ERES_AME_TOO_MANY_ROWS');
        fnd_message.set_token('CHAR_PROMPT', l_char_prompt);
        raise_application_error(-20001, fnd_message.get());
      WHEN OTHERS THEN
        RAISE;
        --DEBUG:raise_application_error(-20001, 'GRCV, when others, char('||p_char_id||'), plan('||l_plan_id||'), col('||l_collection_id||'), occ('||l_occurrence||'), stmt:"'||l_stmt||'", sqlcode('||SQLCODE||'), sqlerrm:"'||SQLERRM||'"');
   END;


END QA_ERES_PKG;

/
