--------------------------------------------------------
--  DDL for Package Body PO_IP_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_IP_INTEGRATION_GRP" AS
/* $Header: PO_IP_INTEGRATION_GRP.plb 120.4 2005/08/03 16:51 mbhargav noship $ */
g_pkg_name CONSTANT varchar2(30) := 'PO_IP_INTEGRATION_GRP';

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------



-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: get_mapped_ip_category
--Pre-reqs: None
--Modifies:
--Locks:
--Function:
--  Returns mapped ip category id, given po category id
--Parameters:
--IN: po_category_id
--IN OUT:
--OUT: ip_category_id
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_mapped_ip_category
( p_po_category_id IN NUMBER,
  x_ip_category_id OUT nocopy NUMBER
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'get_mapped_ip_category';
l_progress VARCHAR2(3) := '000';
l_category_key VARCHAR2(250);
BEGIN

  l_progress := '010';
  SELECT shopping_category_id
  INTO x_ip_category_id
  FROM ICX_CAT_PURCHASING_CAT_MAP_V
  WHERE po_category_id = p_po_category_id;

EXCEPTION
  WHEN OTHERS THEN
     x_ip_category_id := null;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name,
                                p_error_text     => SUBSTRB(SQLERRM, 1, 200)
                                                    ||' at location '||l_progress);
     END IF;
END get_mapped_ip_category;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_mapped_po_category
--Pre-reqs: None
--Modifies:
--Locks:
--Function:
--  Returns the mapped PO Category, given IP Category
--Parameters:
--IN: ip_category_id
--IN OUT:
--OUT: po_category_id
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_mapped_po_category
( p_ip_category_id IN NUMBER,
  x_po_category_id OUT nocopy NUMBER
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'get_mapped_po_category';
l_progress VARCHAR2(3) := '000';
BEGIN

  l_progress := '010';
  SELECT po_category_id
  INTO x_po_category_id
  FROM ICX_CAT_SHOPPING_CAT_MAP_V
  WHERE shopping_category_id = p_ip_category_id;

EXCEPTION
  WHEN OTHERS THEN
     x_po_category_id := null;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name,
                                p_error_text     => SUBSTRB(SQLERRM, 1, 200)
                                                    ||' at location '||l_progress);
     END IF;

END get_mapped_po_category;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_shopping_category_from_id
--Pre-reqs: None
--Modifies:
--Locks:
--Function:
--  Returns Shopping Category name, given ip_category and language
--Parameters:
--IN: ip_category_id
--IN: language
--IN OUT:
--OUT: shopping_category_name
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_shopping_category_from_id
( p_ip_category_id IN NUMBER,
  p_language IN VARCHAR2,
  x_shopping_category_name OUT nocopy VARCHAR2
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'get_shopping_category_from_id';
l_progress VARCHAR2(3) := '000';
BEGIN

  l_progress := '010';
  SELECT category_name
  INTO   x_shopping_category_name
  FROM   ICX_CAT_CATEGORIES_V
  WHERE  rt_category_id = p_ip_category_id
  AND    language = p_language;

EXCEPTION
  WHEN OTHERS THEN
     x_shopping_category_name := null;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => l_api_name,
                                p_error_text     => SUBSTRB(SQLERRM, 1, 200)
                                                    ||' at location '||l_progress);
     END IF;

END get_shopping_category_from_id;

END PO_IP_INTEGRATION_GRP;

/
