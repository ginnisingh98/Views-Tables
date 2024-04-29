--------------------------------------------------------
--  DDL for Package Body QA_ERES_DEFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_ERES_DEFER" AS
/* $Header: qaedrdfb.pls 120.1 2006/09/14 23:33:57 shkalyan noship $ */


 -- Global Variables for the 'Approval Status' values.

 g_approved CONSTANT VARCHAR2(30) := 'APPROVED';
 g_rejected CONSTANT VARCHAR2(30) := 'REJECTED';

 -- Global Variable for the 'Approval Required' collection element
 -- char_id.

 g_esig_status_char_id CONSTANT NUMBER := 2147483572;


---------------------------------------------------------------------
 PROCEDURE update_res_col
             (p_status_code   IN VARCHAR2,
              p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_sql_string  VARCHAR2(1000);
   l_res_col     VARCHAR2(60);

 BEGIN

   l_res_col := QA_FLEX_UTIL.qpc_result_column_name(p_plan_id, g_esig_status_char_id);

   l_sql_string := 'UPDATE qa_results SET ' || l_res_col ||' = :1'
                   ||' WHERE plan_id = :2'
                   ||' and collection_id = :3'
                   ||' and occurrence = :4';

   BEGIN
     EXECUTE IMMEDIATE l_sql_string USING p_status_code, p_plan_id,
                                          p_collection_id, p_occurrence;

   EXCEPTION
     WHEN OTHERS THEN raise;

   END;

 END update_res_col;


  -- R12 ERES Support in Service Family. Bug 4345768
  -- START
  -- New procedure for stamping approval status for a collection

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- New modularized function to check if per row event exists
  -- for a collection.
  FUNCTION per_row_event_exists
           (p_plan_id        IN NUMBER,
            p_collection_id  IN NUMBER,
            p_occurrence     IN NUMBER)  RETURN VARCHAR2 IS
    l_event_key    VARCHAR2(1000);
    l_event_exists VARCHAR2(1) := 'N';

    CURSOR  event_exists( c_event_name VARCHAR2, c_event_key VARCHAR2 ) IS
    SELECT  'Y'
    FROM    EDR_PSIG_DOCUMENTS
    WHERE   event_name = c_event_name
    AND     event_key = c_event_key;

  BEGIN
    l_event_key := p_plan_id || '-' || p_collection_id || '-' || p_occurrence;

    OPEN  event_exists( 'oracle.apps.qa.result.create', l_event_key );
    FETCH event_exists INTO l_event_exists;
    CLOSE event_exists;

    RETURN l_event_exists;

  END per_row_event_exists;

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- Added new input parameter p_txn_header_id
  PROCEDURE update_collection_col
            (p_status_code   IN VARCHAR2,
             p_plan_id       IN NUMBER,
             p_collection_id IN NUMBER,
             p_txn_header_id IN NUMBER
            ) IS

    -- Bug 5508639. SHKALYAN 13-Sep-2006.
    -- New cursor to get result occurrences based on txn_header_id
    -- Modified the name of the old cursor to get_results_col
    CURSOR  get_results_txn( c_txn_header_id NUMBER, c_collection_id NUMBER , c_plan_id NUMBER ) IS
    SELECT  occurrence
    FROM    QA_RESULTS
    WHERE   collection_id = c_collection_id
    AND     txn_header_id = c_txn_header_id
    AND     plan_id = c_plan_id;

    CURSOR  get_results_col( c_collection_id NUMBER , c_plan_id NUMBER ) IS
    SELECT  occurrence
    FROM    QA_RESULTS
    WHERE   collection_id = c_collection_id
    AND     plan_id = c_plan_id;

    l_occurrence   NUMBER;

  BEGIN

  IF ( p_txn_header_id IS NOT NULL ) THEN
    FOR res_cur IN get_results_txn( p_txn_header_id, p_collection_id , p_plan_id ) LOOP
      l_occurrence := res_cur.occurrence;

      -- Check if 'per row' event has been raised for any of the
      -- occurrences belonging to this collection. If so, do not
      -- update these rows.
      IF ( per_row_event_exists( p_plan_id, p_collection_id, l_occurrence ) = 'N' ) THEN
        update_res_col(p_status_code,
                       p_plan_id,
                       p_collection_id,
                       l_occurrence);

      END IF;
    END LOOP;

  ELSE

    FOR res_cur IN get_results_col( p_collection_id , p_plan_id ) LOOP
      l_occurrence := res_cur.occurrence;

      -- Check if 'per row' event has been raised for any of the
      -- occurrences belonging to this collection. If so, do not
      -- update these rows.
      IF ( per_row_event_exists( p_plan_id, p_collection_id, l_occurrence ) = 'N' ) THEN
        update_res_col(p_status_code,
                       p_plan_id,
                       p_collection_id,
                       l_occurrence);

      END IF;

    END LOOP;

  END IF;

  END update_collection_col;

  -- END
  -- R12 ERES Support in Service Family. Bug 4345768

---------------------------------------------------------------------
 PROCEDURE spec_status_update
              (p_spec_id  in number
              ) IS
---------------------------------------------------------------------

   l_status_code NUMBER;
   l_sql_string  VARCHAR2(1000);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := 20;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := 30;

   END IF;

   l_sql_string := 'UPDATE qa_specs SET spec_status = :1'
                   ||' WHERE spec_id = :2';

   BEGIN
     EXECUTE IMMEDIATE l_sql_string USING l_status_code, p_spec_id;

   EXCEPTION
     WHEN OTHERS THEN raise;

   END;

 END spec_status_update;


---------------------------------------------------------------------
 PROCEDURE ncm_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);

 END ncm_approve;


---------------------------------------------------------------------
 PROCEDURE ncm_detail_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);


 END ncm_detail_approve;


---------------------------------------------------------------------
 PROCEDURE disp_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);

 END disp_approve;


---------------------------------------------------------------------
 PROCEDURE disp_detail_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);

 END disp_detail_approve;



---------------------------------------------------------------------
 PROCEDURE car_review_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);

 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);

 END car_review_approve;



---------------------------------------------------------------------
 PROCEDURE car_impl_approve
             (p_plan_id       IN NUMBER,
              p_collection_id IN NUMBER,
              p_occurrence    IN NUMBER
             ) IS
---------------------------------------------------------------------

   l_status_code VARCHAR2(30);


 BEGIN

   IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      l_status_code := g_approved;

   ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
      l_status_code := g_rejected;

   END IF;

   update_res_col(l_status_code,
                  p_plan_id,
                  p_collection_id,
                  p_occurrence);

 END car_impl_approve;

  -- R12 ERES Support in Service Family. Bug 4345768
  -- START

  -- Post Operation API for updating the Approval
  -- status of the QA Results Occurrence.

  PROCEDURE qa_occurrence_approve
            (p_plan_id       IN NUMBER,
             p_collection_id IN NUMBER,
             p_occurrence    IN NUMBER
            ) IS

     l_status_code VARCHAR2(30);

  BEGIN

     -- Get the Signature status
     IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
        l_status_code := g_approved;

     ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
        l_status_code := g_rejected;

     END IF;

     -- Update the status returned by EDR
     update_res_col(l_status_code,
                    p_plan_id,
                    p_collection_id,
                    p_occurrence);

  END qa_occurrence_approve;

  -- Post Operation API for updating the Approval
  -- status of the QA Results Collection.

  PROCEDURE qa_collection_approve
            (p_plan_id       IN NUMBER,
             p_collection_id IN NUMBER
            ) IS

     l_status_code VARCHAR2(30);

  BEGIN

     -- Get the Signature status
     IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
        l_status_code := g_approved;

     ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
        l_status_code := g_rejected;

     END IF;

     -- Bug 5508639. SHKALYAN 13-Sep-2006.
     -- Pass NULL as txn_header_id since processing is by collection

     -- Update the status returned by EDR
     update_collection_col(l_status_code,
                           p_plan_id,
                           p_collection_id,
                           NULL);

  END qa_collection_approve;


  -- END
  -- R12 ERES Support in Service Family. Bug 4345768

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- Overloaded Post Operation API for updating the Approval
  -- status of the QA Results Collection for a given txn_header_id.
  PROCEDURE qa_collection_approve
              (p_plan_id       IN NUMBER,
               p_collection_id IN NUMBER,
               p_txn_header_id IN NUMBER
              ) IS

     l_status_code VARCHAR2(30);

  BEGIN

     -- Get the Signature status
     IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
        l_status_code := g_approved;

     ELSIF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'REJECTED') THEN
        l_status_code := g_rejected;

     END IF;

     -- Update the status returned by EDR
     update_collection_col(l_status_code,
                           p_plan_id,
                           p_collection_id,
                           p_txn_header_id);

  END qa_collection_approve;


END QA_ERES_DEFER;


/
