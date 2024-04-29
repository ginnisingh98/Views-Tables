--------------------------------------------------------
--  DDL for Package Body PO_SETUP_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SETUP_S1" as
/* $Header: POXSES2B.pls 115.8 2004/01/09 22:34:30 anhuang ship $*/

/*=============================  PO_SETUP_S1  ===============================*/

g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_SETUP_S1.';

/*===========================================================================

  PROCEDURE NAME:	get_install_status()

===========================================================================*/
PROCEDURE get_install_status(x_inv_status            OUT NOCOPY VARCHAR2,
                             x_po_status             OUT NOCOPY VARCHAR2,
                             x_qa_status             OUT NOCOPY VARCHAR2,
			     x_wip_status	     OUT NOCOPY VARCHAR2,
			     x_oe_status	     OUT NOCOPY VARCHAR2,
			     x_pa_status	     OUT NOCOPY VARCHAR2) is

x_progress VARCHAR2(3) := NULL;

BEGIN
  x_progress := '010';
  x_inv_status := po_core_s.get_product_install_status('INV');

  x_progress := '020';
  x_po_status := po_core_s.get_product_install_status('PO');

  x_progress := '030';
  x_qa_status := po_core_s.get_product_install_status('QA');

  x_progress := '040';
  x_wip_status := po_core_s.get_product_install_status('WIP');

  x_progress := '050';
  x_oe_status := po_core_s.get_product_install_status('OE');

  x_progress := '060';
  x_pa_status := po_core_s.get_product_install_status('PA');


  EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('po_setup_s1.get_install_status', x_progress, sqlcode);
  RAISE;

END get_install_status;

PROCEDURE test_get_install_status IS

 x_inv_status VARCHAR2 (20);
 x_po_status VARCHAR2 (20);
 x_qa_status VARCHAR2 (20);
 x_wip_status VARCHAR2 (20);
 x_oe_status VARCHAR2 (20);
 x_pa_status VARCHAR2 (20);

BEGIN
  po_setup_s1.get_install_status(x_inv_status,
		 		x_po_status,
				x_qa_status,
				x_wip_status,
				x_oe_status,
				x_pa_status);

  --togeorge 08/11/2001 Commented out due to source control issues.
  --dbms_output.put_line('x_po_status = ' || x_po_status);
  --dbms_output.put_line('x_po_status = ' || x_inv_status);
  --dbms_output.put_line('x_po_status = ' || x_qa_status);

END test_get_install_status;

/*===========================================================================
  PROCEDURE NAME:	get_eam_startup()

  DESCRIPTION:
	                o x_eam_install_status stores the installation stuts of EAM

	                o x_eam_profile stores the value of the profile
					PO: Enable Direct Delivery To Shop floor

  REFERENCED BY:	init_po_control_block, POXCOSEU.pld

===========================================================================*/

PROCEDURE get_eam_startup    (x_eam_install_status    OUT NOCOPY VARCHAR2,
                             x_eam_profile           OUT NOCOPY VARCHAR2) is

x_progress VARCHAR2(3) := NULL;
BEGIN
  x_progress := '010';
  x_eam_install_status := po_core_s.get_product_install_status('EAM');

  x_progress := '020';
  fnd_profile.get('PO_DIRECT_DELIVERY_TO_SHOPFLOOR',x_eam_profile);

  EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('po_setup_s1.get_eam_status', x_progress, sqlcode);
  RAISE;

END get_eam_startup;

/*===========================================================================
  PROCEDURE NAME:	get_oke_startup()

  DESCRIPTION:
	                1.x_oke_install_status stores the installation stuts
			  of OKE

  REFERENCED BY:	init_po_control_block, POXCOSEU.pld

===========================================================================*/

PROCEDURE get_oke_startup    (x_oke_install_status    OUT NOCOPY VARCHAR2) is

x_progress VARCHAR2(3) := NULL;
BEGIN
  x_progress := '010';
  x_oke_install_status := po_core_s.get_product_install_status('OKE');

  EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('po_setup_s1.get_oke_status', x_progress, sqlcode);
  RAISE;

END get_oke_startup;

/*===========================================================================
  PROCEDURE NAME:	get_gms_startup()

  DESCRIPTION:
	                1.x_gms_install_status stores the installation stuts
			  of GMS

  REFERENCED BY:	init_po_control_block, POXCOSEU.pld

===========================================================================*/

PROCEDURE get_gms_startup    (x_gms_install_status    OUT NOCOPY VARCHAR2) is

x_progress VARCHAR2(3) := NULL;
BEGIN
  x_progress := '010';
  x_gms_install_status := po_core_s.get_product_install_status('GMS');

  EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('po_setup_s1.get_gms_status', x_progress, sqlcode);
  RAISE;
END get_gms_startup;


/*===========================================================================
  PROCEDURE NAME:       get_sourcing_startup()

  DESCRIPTION:        x_pon_install_status stores the installation status
		      of sourcing product
                      Requisition To Sourcing FPH
  REFERENCED BY:        init_po_control_block, POXCOSEU.pld
===========================================================================*/

PROCEDURE get_sourcing_startup    (x_pon_install_status    OUT NOCOPY VARCHAR2) is

x_progress VARCHAR2(3) := NULL;
x_pon_use_profile varchar2(1) := 'N';

BEGIN
  x_progress := '010';
  x_pon_use_profile := fnd_profile.value('PO_ALLOW_AUTOCREATE_SOURCING_DOCS');

 /* return the sourcing install status only if the Use Sourcing profile is set to yes
    Otherwise return the install status as N irrespective of the fnd install status */

  IF nvl(x_pon_use_profile,'N') = 'Y' THEN
   x_pon_install_status := po_core_s.get_product_install_status('PON');
  ELSE
   x_pon_install_status := 'N';
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  po_message_s.sql_error('po_setup_s1.get_pon_status', x_progress, sqlcode);
  RAISE;
END get_sourcing_startup;

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_services_enabled_flag
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function determines whether Services Procurement is enabled for the
--  current system. In order for Services Procurement to be enabled...
--  (a) Profile Option "PO: Enable Services Procurement" must be turned on, and
--  (b) AP must be Family Pack M or higher (11i.AP.M) or not installed at all
--Parameters:
--  None.
--Returns:
--  VARCHAR2(1): 'Y' if Services Procurement is enabled for the current setup.
--  'N' otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_services_enabled_flag
RETURN VARCHAR2
IS
-- <BUG 3248161 START>

    l_api_name              VARCHAR2(30) := 'get_services_enabled_flag';
    l_log_head              VARCHAR2(100) := g_log_head || l_api_name;
    l_progress              VARCHAR2(3);

    l_profile_value         VARCHAR2(1);
    l_ap_compatibility_flag VARCHAR2(1);
    l_result                VARCHAR2(1);

BEGIN

l_progress := '000'; PO_DEBUG.debug_begin(l_log_head);

    -- Profile Option ---------------------------------------------------------

    l_profile_value := FND_PROFILE.value('PO_SERVICES_ENABLED');

l_progress := '010'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'PO: Enable Services Procurement'
                                        , p_value    => l_profile_value
                                        );

    -- AP Family Pack ---------------------------------------------------------

    l_ap_compatibility_flag := PO_SERVICES_PVT.get_ap_compatibility_flag;

l_progress := '020'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'l_is_ap_compatible'
                                        , p_value    => l_ap_compatibility_flag
                                        );

    ---------------------------------------------------------------------------

    IF (   ( l_profile_value = 'Y' )
       AND ( l_ap_compatibility_flag = 'Y' ) )
    THEN
       l_result := 'Y';
    ELSE
       l_result := 'N';
    END IF;

l_progress := '020'; PO_DEBUG.debug_var ( p_log_head => l_log_head
                                        , p_progress => l_progress
                                        , p_name     => 'l_result'
                                        , p_value    => l_result
                                        );
l_progress := '030'; PO_DEBUG.debug_end(l_log_head);

    return (l_result);

EXCEPTION

    WHEN OTHERS THEN
        PO_DEBUG.debug_exc ( p_log_head => l_log_head
                           , p_progress => l_progress);
        RAISE;

-- <BUG 3248161 END>

END get_services_enabled_flag;


END PO_SETUP_S1;

/
