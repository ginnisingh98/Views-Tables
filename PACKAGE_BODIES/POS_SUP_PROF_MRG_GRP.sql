--------------------------------------------------------
--  DDL for Package Body POS_SUP_PROF_MRG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUP_PROF_MRG_GRP" as
/* $Header: POSSPMGB.pls 120.12.12010000.7 2014/01/21 21:28:33 dalu ship $ */

pos_merge_exception EXCEPTION;

g_module_prefix VARCHAR2(35) := 'POS.plsql.POS_SUP_PROF_MRG_GRP.';


FUNCTION GET_ACTIVE_SITE_COUNT (p_dup_vendor_id 	IN NUMBER,
				p_dup_vendor_site_id  	IN NUMBER)
  RETURN NUMBER;

-- Function check_sdh_profile_option
-- Added for Bug 17068732
FUNCTION check_sdh_profile_option RETURN VARCHAR2
 IS
 l_sdh_profile_option	fnd_profile_option_values.profile_option_value%type;
 BEGIN
   select opv.profile_option_value
   into   l_sdh_profile_option
   from fnd_profile_option_values opv, fnd_profile_options op
   where op.profile_option_id = opv.profile_option_id
   and op.profile_option_name = 'POS_SM_SDH_CONFIG';

 return l_sdh_profile_option;
 EXCEPTION
    WHEN OTHERS THEN
    	RETURN 'ERROR';
END;

-- Procedure raise_business_event
-- Added for Bug 17068732: Raise Business event for both new and old suppliers
PROCEDURE raise_business_event(
  p_new_vendor_id         IN NUMBER,
  p_new_vendor_site_id    IN NUMBER,
  p_old_vendor_id         IN NUMBER,
  p_old_vendor_site_id    IN NUMBER,
  x_return_status         IN OUT nocopy VARCHAR2
  )
IS
    l_event_status VARCHAR2(40);
    l_event_err_msg VARCHAR2(2000);
    l_new_party_id HZ_PARTIES.PARTY_ID%TYPE;
    l_old_party_id HZ_PARTIES.PARTY_ID%TYPE;
    l_sdh_profile fnd_profile_option_values.profile_option_value%type;

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;
  l_sdh_profile := check_sdh_profile_option;
  IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
    SELECT PARTY_ID INTO l_new_party_id
    FROM AP_SUPPLIERS
    WHERE VENDOR_ID = p_new_vendor_id;

    SELECT PARTY_ID INTO l_old_party_id
    FROM AP_SUPPLIERS
    WHERE VENDOR_ID = p_old_vendor_id;

    POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => p_new_vendor_id,
                                             p_party_id  => l_new_party_id,
                                             p_transaction_type => 'UPDATE',
                                             p_entity_name => 'MERGE_SITE',
                                             p_entity_key => p_new_vendor_site_id,
                                             x_return_status => l_event_status,
                                             x_msg_data => l_event_err_msg);
    fnd_file.put_line(fnd_file.log, 'Event Raised for Master Supplier ' || p_new_vendor_id ||
                                    ' Status: ' || l_event_status ||
                                    ' Message: ' || l_event_err_msg);
    x_return_status := l_event_status;

    POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => p_old_vendor_id,
                                             p_party_id  => l_old_party_id,
                                             p_transaction_type => 'UPDATE',
                                             p_entity_name => 'MERGE_SITE',
                                             p_entity_key => p_old_vendor_site_id,
                                             x_return_status => l_event_status,
                                             x_msg_data => l_event_err_msg);
    fnd_file.put_line(fnd_file.log, 'Event Raised for Supplier ' || p_old_vendor_id ||
                                     ' Status: ' || l_event_status ||
                                     ' Message: ' || l_event_err_msg);
    IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_event_status;
    END IF;
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, 'Unexpected error when raising business event for vendor site merge');
     x_return_status := FND_API.G_RET_STS_ERROR;

END raise_business_event;

PROCEDURE log_fnd_message_stack
  (p_module        IN VARCHAR2,
   p_return_status IN VARCHAR2,
   p_msg_count     IN NUMBER,
   p_msg_data      IN VARCHAR2)
  IS
     l_msg fnd_log_messages.message_text%TYPE;
BEGIN
   IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_error, p_module, 'return status is ' || p_return_status);
   END IF;
   IF p_msg_count = 1 THEN
      IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_error, p_module, p_msg_data);
      END IF;
    ELSE
      FOR i IN 1..p_msg_count LOOP
         l_msg := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(fnd_log.level_error, p_module, l_msg);
         END IF;
      END LOOP;
   END IF;
END log_fnd_message_stack;

-- v12 Only updating securing attributes, everything else should be
-- handled by AP or TCA

procedure handle_merge
  (p_new_vendor_id         IN NUMBER,
   p_new_vendor_site_id    IN NUMBER,
   p_old_vendor_id         IN NUMBER,
   p_old_vendor_site_id    IN NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2 )
  IS
     l_module        	VARCHAR2(31);
     l_return_status 	VARCHAR2(2) := fnd_api.g_ret_sts_success; -- Initialize return status
     l_num_active_sites	NUMBER;

BEGIN
   SAVEPOINT pos_handle_merge;

   l_module := 'handle_merge';

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_module,
                     '1.Begin handle_merge:'||
                     'new vendorid:'|| p_new_vendor_id||
                     ':new vendor site id:' || p_new_vendor_site_id ||
                     ':old vendor id :'|| p_old_vendor_id ||
                     ':old vendor site id:'|| p_old_vendor_site_id);
   END IF;

   l_num_active_sites := GET_ACTIVE_SITE_COUNT(p_old_vendor_id, p_old_vendor_site_id);

   -- V12, iSP is no longer maintaining TCA, so the only thing to do is
   -- maintaining securing attributes

   fnd_file.put_line(fnd_file.log,
                      '1.Begin handle_merge:' || 'new vendorid:' ||
                      p_new_vendor_id || ':new vendor site id:' ||
                      p_new_vendor_site_id || ':old vendor id :' ||
                      p_old_vendor_id || ':old vendor site id:' ||
                      p_old_vendor_site_id);


   IF (p_new_vendor_site_id <> p_old_vendor_site_id) THEN

        -- Merge site
         -- Bugfix#12817586 check for unique constraint violation before while updating
        UPDATE ak_web_user_sec_attr_values ak1
        SET ak1.number_value             = p_new_vendor_site_id
        WHERE ak1.attribute_code         = 'ICX_SUPPLIER_SITE_ID'
        AND ak1.attribute_application_id = 177
        AND ak1.number_value             = p_old_vendor_site_id
        AND NOT EXISTS
          (SELECT 'DUPLICATE'
          FROM ak_web_user_sec_attr_values ak2
          WHERE ak2.web_user_id            = ak1.web_user_id
          AND ak2.attribute_code           = 'ICX_SUPPLIER_SITE_ID'
          AND ak2.attribute_application_id = 177
          AND ak2.number_value             = p_new_vendor_site_id
          );
        --End bugfix#12817586

        -- If it is the last site then merge vendor
      IF (l_num_active_sites = 0) THEN
	-- Bugfix#16033590 check for unique constraint violation before while updating
        UPDATE ak_web_user_sec_attr_values ak1
        SET ak1.number_value = p_new_vendor_id
        WHERE ak1.attribute_code = 'ICX_SUPPLIER_ORG_ID'
        AND ak1.attribute_application_id = 177
        AND ak1.number_value = p_old_vendor_id
        AND NOT EXISTS
          (SELECT 'DUPLICATE'
          FROM ak_web_user_sec_attr_values ak2
          WHERE ak2.web_user_id            = ak1.web_user_id
          AND ak2.attribute_code           = 'ICX_SUPPLIER_ORG_ID'
          AND ak2.attribute_application_id = 177
          AND ak2.number_value             = p_new_vendor_id
          );
        --End bugfix#160335905


	UPDATE fnd_registration_details
	  SET field_value_string = (SELECT vendor_name FROM po_vendors WHERE vendor_id = p_new_vendor_id)
	  WHERE field_name = 'Supplier Name'
	  AND registration_id IN
	  (SELECT DISTINCT registration_id
	   FROM fnd_registration_details WHERE field_name = 'Supplier Number'
	   AND field_value_number = p_old_vendor_id
	   );

	UPDATE fnd_registration_details
	  SET field_value_number = p_new_vendor_id
	  WHERE field_name = 'Supplier Number'
	  AND registration_id IN
	  (SELECT DISTINCT registration_id
	   FROM fnd_registration_details WHERE field_name = 'Supplier Number'
	   AND field_value_number = p_old_vendor_id
	   );

      END IF;

   END IF;

   -- I'm also going to maintain the following FKs for the moment,
   -- just in case (12.0)

   IF (p_new_vendor_id IS NOT NULL AND p_new_vendor_id <> p_old_vendor_id)
   THEN

     /* Commented out -mji

        UPDATE pos_acct_addr_rel
        SET vendor_id = p_new_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by  = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE vendor_id = p_old_vendor_id;


        UPDATE pos_supplier_mappings
        SET vendor_id = p_new_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE vendor_id = p_old_vendor_id;

        UPDATE pos_supplier_registrations
        SET po_vendor_id = p_new_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE po_vendor_id = p_old_vendor_id;

        UPDATE pos_sup_bank_account_requests
        SET vendor_id = p_new_vendor_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE vendor_id = p_old_vendor_id;
     */

       -- If it is the last site then merge supplier profile info
      IF (l_num_active_sites = 0) THEN
	 -- delete classifications of the merged-from vendor that
	 -- the merged-to vendor also has

          DELETE pos_sup_products_services t1
           WHERE vendor_id = p_old_vendor_id
             AND exists
	     (SELECT 1 FROM pos_sup_products_services t2
	      WHERE (t1.segment1  = t2.segment1  OR t1.segment1  IS NULL AND t2.segment1  IS NULL)
	        AND (t1.segment2  = t2.segment2  OR t1.segment2  IS NULL AND t2.segment2  IS NULL)
	        AND (t1.segment3  = t2.segment3  OR t1.segment3  IS NULL AND t2.segment3  IS NULL)
	        AND (t1.segment4  = t2.segment4  OR t1.segment4  IS NULL AND t2.segment4  IS NULL)
	        AND (t1.segment5  = t2.segment5  OR t1.segment5  IS NULL AND t2.segment5  IS NULL)
	        AND (t1.segment6  = t2.segment6  OR t1.segment6  IS NULL AND t2.segment6  IS NULL)
	        AND (t1.segment7  = t2.segment7  OR t1.segment7  IS NULL AND t2.segment7  IS NULL)
	        AND (t1.segment8  = t2.segment8  OR t1.segment8  IS NULL AND t2.segment8  IS NULL)
	        AND (t1.segment9  = t2.segment9  OR t1.segment9  IS NULL AND t2.segment9  IS NULL)
	        AND (t1.segment10 = t2.segment10 OR t1.segment10 IS NULL AND t2.segment10 IS NULL)
	        AND (t1.segment11 = t2.segment11 OR t1.segment11 IS NULL AND t2.segment11 IS NULL)
	        AND (t1.segment12 = t2.segment12 OR t1.segment12 IS NULL AND t2.segment12 IS NULL)
	        AND (t1.segment13 = t2.segment13 OR t1.segment13 IS NULL AND t2.segment13 IS NULL)
	        AND (t1.segment14 = t2.segment14 OR t1.segment14 IS NULL AND t2.segment14 IS NULL)
	        AND (t1.segment15 = t2.segment15 OR t1.segment15 IS NULL AND t2.segment15 IS NULL)
	        AND (t1.segment16 = t2.segment16 OR t1.segment16 IS NULL AND t2.segment16 IS NULL)
	        AND (t1.segment17 = t2.segment17 OR t1.segment17 IS NULL AND t2.segment17 IS NULL)
	        AND (t1.segment18 = t2.segment18 OR t1.segment18 IS NULL AND t2.segment18 IS NULL)
	        AND (t1.segment19 = t2.segment19 OR t1.segment19 IS NULL AND t2.segment19 IS NULL)
	        AND (t1.segment20 = t2.segment20 OR t1.segment20 IS NULL AND t2.segment20 IS NULL)
                AND t2.vendor_id = p_new_vendor_id);

    --Bug 16658554
    --update pending-approval classifications of the merged-to vendor that
    --are already approved in the merged-from vendor
          UPDATE POS_PRODUCT_SERVICE_REQUESTS t1
             SET request_status = 'APPROVED'
            WHERE mapping_id = (select mapping_id from POS_SUPPLIER_MAPPINGS where vendor_id = p_new_vendor_id)
              AND exists
      (SELECT 1 FROM pos_sup_products_services t2
       WHERE  (t1.segment1  = t2.segment1  OR t1.segment1  IS NULL AND t2.segment1  IS NULL)
             AND (t1.segment2  = t2.segment2  OR t1.segment2  IS NULL AND t2.segment2  IS NULL)
             AND (t1.segment3  = t2.segment3  OR t1.segment3  IS NULL AND t2.segment3  IS NULL)
             AND (t1.segment4  = t2.segment4  OR t1.segment4  IS NULL AND t2.segment4  IS NULL)
             AND (t1.segment5  = t2.segment5  OR t1.segment5  IS NULL AND t2.segment5  IS NULL)
             AND (t1.segment6  = t2.segment6  OR t1.segment6  IS NULL AND t2.segment6  IS NULL)
             AND (t1.segment7  = t2.segment7  OR t1.segment7  IS NULL AND t2.segment7  IS NULL)
             AND (t1.segment8  = t2.segment8  OR t1.segment8  IS NULL AND t2.segment8  IS NULL)
             AND (t1.segment9  = t2.segment9  OR t1.segment9  IS NULL AND t2.segment9  IS NULL)
             AND (t1.segment10 = t2.segment10 OR t1.segment10 IS NULL AND t2.segment10 IS NULL)
             AND (t1.segment11 = t2.segment11 OR t1.segment11 IS NULL AND t2.segment11 IS NULL)
             AND (t1.segment12 = t2.segment12 OR t1.segment12 IS NULL AND t2.segment12 IS NULL)
             AND (t1.segment13 = t2.segment13 OR t1.segment13 IS NULL AND t2.segment13 IS NULL)
             AND (t1.segment14 = t2.segment14 OR t1.segment14 IS NULL AND t2.segment14 IS NULL)
             AND (t1.segment15 = t2.segment15 OR t1.segment15 IS NULL AND t2.segment15 IS NULL)
             AND (t1.segment16 = t2.segment16 OR t1.segment16 IS NULL AND t2.segment16 IS NULL)
             AND (t1.segment17 = t2.segment17 OR t1.segment17 IS NULL AND t2.segment17 IS NULL)
             AND (t1.segment18 = t2.segment18 OR t1.segment18 IS NULL AND t2.segment18 IS NULL)
             AND (t1.segment19 = t2.segment19 OR t1.segment19 IS NULL AND t2.segment19 IS NULL)
             AND (t1.segment20 = t2.segment20 OR t1.segment20 IS NULL AND t2.segment20 IS NULL)
              AND t2.status = 'A'
              AND t2.vendor_id = p_old_vendor_id);

          -- transfer classifications of the merged-from vendor to the merged-to vendor
	  UPDATE pos_sup_products_services
	    SET vendor_id = p_new_vendor_id,
	    last_update_date = SYSDATE,
	    last_updated_by = FND_GLOBAL.user_id,
	    last_update_login = FND_GLOBAL.login_id
	    WHERE vendor_id = p_old_vendor_id;
      END IF;

   ELSE
      --     l_return_status := FND_API.g_ret_sts_error;      Bug 5048890
       null;

   END IF;

   IF (p_new_vendor_id IS NOT NULL AND
       p_old_vendor_site_id <> p_new_vendor_site_id) THEN
      pos_merge_supplier_pkg.supplier_site_uda_merge(p_from_id       => p_new_vendor_id,
                                                     p_from_fk_id    => p_old_vendor_site_id,
                                                     p_to_fk_id      => p_new_vendor_site_id,
                                                     x_return_status => l_return_status);
    END IF;

   IF l_return_status = fnd_api.g_ret_sts_success THEN
      x_return_status := fnd_api.g_ret_sts_success;
   ELSE
      IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_error, g_module_prefix || l_module,
                        'return status ' || l_return_status);

      END IF;

      ROLLBACK TO pos_handle_merge;
      RAISE pos_merge_exception;

   END IF;

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_module,'5.End');
   END IF;

   -- Bug 17068732: raise business event for vendor site merge
   raise_business_event(p_new_vendor_id,
                        p_new_vendor_site_id,
                        p_old_vendor_id,
                        p_old_vendor_site_id,
                        l_return_status);

EXCEPTION
   WHEN pos_merge_exception THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --raise_application_error(-20001, g_module_prefix || l_module || ' merge error', true);
      IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(fnd_log.level_error, g_module_prefix||l_module,' merge error');
      END IF;


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  raise_application_error(-20002, g_module_prefix || l_module || Sqlerrm, TRUE);

     IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_error, g_module_prefix||l_module||' SQL error', Sqlerrm);
     END IF;
END handle_merge;



FUNCTION GET_ACTIVE_SITE_COUNT (p_dup_vendor_id 	IN NUMBER,
				p_dup_vendor_site_id  	IN NUMBER)
RETURN NUMBER
IS

  l_num_active_sites NUMBER;

  BEGIN
      -- select count of active sites (besides the site being merged)

      SELECT count(*)
      INTO l_num_active_sites
      FROM po_vendor_sites_all
      WHERE vendor_id = p_dup_vendor_id
	    AND vendor_site_id <> p_dup_vendor_site_id
	    AND nvl(inactive_date, sysdate+1) > sysdate;

      return l_num_active_sites;

EXCEPTION
   WHEN OTHERS THEN
      return 1;

END GET_ACTIVE_SITE_COUNT;


END pos_sup_prof_mrg_grp;

/
