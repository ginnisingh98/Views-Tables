--------------------------------------------------------
--  DDL for Package Body POS_REQUEST_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_REQUEST_UTILS_PKG" AS
/*$Header: POSRQUTB.pls 120.6 2005/11/21 12:29:12 bitang noship $ */

FUNCTION get_prospect_suppler_reg_url
  (p_org_id IN NUMBER) RETURN VARCHAR2
  IS
BEGIN
   RETURN pos_url_pkg.get_external_url || '/OA_HTML/jsp/pos/suppreg/SupplierRegister.jsp?ouid='
     ||  pos_org_hash_pkg.get_hashkey(p_org_id);

END get_prospect_suppler_reg_url;

-- This procedure is called by Sourcing to invite a supplier to
-- register
PROCEDURE pos_src_register_supplier
  ( p_supplier_reg_id	IN  NUMBER,
    p_org_id            IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    )
  IS
BEGIN
   pos_spm_wf_pkg1.send_supplier_invite_reg_ntf
     (p_supplier_reg_id => p_supplier_reg_id);

   x_return_status := fnd_api.g_ret_sts_success;

END pos_src_register_supplier;

PROCEDURE pos_src_approve_rfq_supplier
  ( p_supplier_reg_id	IN  NUMBER,
    x_party_id          OUT NOCOPY NUMBER,
    x_vendor_id         OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    )
  IS
     CURSOR l_cur IS
	SELECT po_vendor_id, vendor_party_id
	  FROM pos_supplier_registrations
	 WHERE supplier_reg_id = p_supplier_reg_id;
BEGIN
   SAVEPOINT approve_rfqa_supplier_sp;
   pos_vendor_reg_pkg.approve_supplier_reg
     (p_supplier_reg_id => p_supplier_reg_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
      );
   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_rfqa_supplier_sp;
      RETURN;
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO x_vendor_id, x_party_id;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      ROLLBACK TO approve_rfqa_supplier_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'failed to find vendor or vendor site row after approve_rfq_supplier';
      RETURN;
   END IF;
   CLOSE l_cur;

END pos_src_approve_rfq_supplier;

PROCEDURE pos_src_get_supplier_det
  (p_supplier_party_id	IN  NUMBER,
   p_org_id             IN  NUMBER,
   x_vendor_id          OUT NOCOPY NUMBER,
   x_party_site_id      OUT NOCOPY NUMBER,
   x_vendor_site_id     OUT NOCOPY NUMBER,
   x_contact_party_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   )
  IS
     CURSOR l_cur1 IS
	SELECT pv.vendor_id, pvsa.party_site_id, pvsa.vendor_site_id
	  FROM po_vendors pv, po_vendor_sites_all pvsa
	 WHERE pv.vendor_id = pvsa.vendor_id
	   AND pv.party_id = p_supplier_party_id
	   AND pvsa.org_id = p_org_id;

     CURSOR l_cur2 IS
	SELECT fu.person_party_id
	  FROM fnd_user fu, pos_supplier_users_v psuv
	 WHERE fu.user_id = psuv.user_id
	   AND psuv.vendor_id = x_vendor_id
	  ORDER BY fu.creation_date;
BEGIN
   OPEN l_cur1;
   FETCH l_cur1 INTO x_vendor_id, x_party_site_id, x_vendor_site_id;
   IF l_cur1%notfound THEN
      CLOSE l_cur1;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'no site found for p_supplier_party_id ' || p_supplier_party_id
	|| ' p_org_id ' || p_org_id;
      RETURN;
   END IF;
   CLOSE l_cur1;

   OPEN l_cur2;
   FETCH l_cur2 INTO x_contact_party_id;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'no contact party found for vendor_id ' || x_vendor_id;
      RETURN;
   END IF;
   CLOSE l_cur2;

   x_return_status := fnd_api.g_ret_sts_success;

END pos_src_get_supplier_det;

PROCEDURE pos_get_contact_approved_det
  (p_contact_req_id	IN  NUMBER,
   x_contact_party_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2
   )
  IS
     CURSOR l_cur IS
	SELECT contact_party_id
	  FROM pos_contact_requests pcr
	 WHERE contact_request_id = p_contact_req_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_contact_party_id;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'no contact party found for p_contact_req_id ' || p_contact_req_id;
      RETURN;
   END IF;
   CLOSE l_cur;

   x_return_status := fnd_api.g_ret_sts_success;

END pos_get_contact_approved_det;

END POS_REQUEST_UTILS_PKG;

/
