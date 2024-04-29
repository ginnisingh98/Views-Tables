--------------------------------------------------------
--  DDL for Package Body PO_DOC_STYLE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOC_STYLE_GRP" AS
/* $Header: PO_DOC_STYLE_GRP.plb 120.5 2006/03/01 01:02:09 scolvenk noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOC_STYLE_GRP';

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_style_alias_conflict
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure check if the display name has conflict with styles.
--Parameters:
--IN:
--p_name
--  One of the display names of the style.
--  The style id of the style which we want to exclude the this check.
--OUT:
--  Y if there is a conflict with the display name.
--  N if there is no conflict.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_style_alias_conflict (
  p_name IN VARCHAR2
  , p_style_id IN NUMBER default NULL)
  RETURN VARCHAR2
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'is_style_alias_conflict';
  l_progress          VARCHAR2(3);
  l_return_value VARCHAR2(1);
  l_count NUMBER;
BEGIN

  l_progress := '010';

  l_return_value := 'N';

  SELECT count(1)
    INTO l_count
    FROM dual
   WHERE exists (
         SELECT NULL
	     FROM po_doc_style_headers pdsh,
                po_doc_style_lines_vl pdsl
	    WHERE pdsl.display_name = p_name
           AND pdsh.style_id = pdsl.style_id
           AND pdsh.status = 'ACTIVE'
           AND pdsl.style_id <> nvl(p_style_id, -9999));

  l_progress := '020';

  IF l_count > 0 THEN
    l_return_value := 'Y';
  END IF;

  l_progress := '030';


  RETURN l_return_value;

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_style_name_conflict
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure check if the style name has conflict with styles.
--Parameters:
--IN:
--p_name
--  One of the display names of the style.
--  The style id of the style which we want to exclude the this check.
--OUT:
--  Y if there is a conflict with the display name.
--  N if there is no conflict.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_style_name_conflict (
  p_name IN VARCHAR2
  , p_style_id IN NUMBER default NULL)
  RETURN VARCHAR2
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'is_style_name_conflict';
  l_progress          VARCHAR2(3);
  l_return_value VARCHAR2(1);
  l_count NUMBER;
BEGIN

  l_progress := '010';

  l_return_value := 'N';

  SELECT count(1)
    INTO l_count
    FROM dual
   WHERE exists (
         SELECT NULL
          FROM po_doc_style_headers pdsh
	   WHERE pdsh.style_name = p_name
           AND pdsh.style_id <> nvl(p_style_id, -9999));

  l_progress := '020';

  IF l_count > 0 THEN
    l_return_value := 'Y';
  END IF;

  l_progress := '030';

  RETURN l_return_value;

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;




--------------------------------------------------------------------------------
--Start of Comments
--Name: is_standard_doc_style
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure check if the document styles with the supplied style id
--  is of STANDARD type.
--Parameters:
--IN:
--p_style_id
--  The style id.
--OUT:
--  Y if the style is of type STANDARD.
--  N if the style is not of type STANDARD.
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_standard_doc_style (p_style_id IN NUMBER)
  RETURN VARCHAR2
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'is_standard_doc_style';
  l_progress          VARCHAR2(3);
  l_return_value VARCHAR2(1);
  l_count NUMBER;
BEGIN

  l_progress := '010';

  l_return_value := 'N';

  SELECT count(1)
    INTO l_count
    FROM dual
   WHERE exists (
         SELECT NULL
	     FROM po_doc_style_headers pdhs
	    WHERE style_type = 'STANDARD'
            and style_id = p_style_id);

  l_progress := '020';

  IF l_count > 0 THEN
    l_return_value := 'Y';
  END IF;

  l_progress := '030';

  RETURN l_return_value;

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;


--------------------------------------------------------------------------------
--Start of Comments
--Name: get_standard_doc_style
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure return the style if of the SYSTEM style.
--Parameters:
--IN:
--None.
--OUT:
--  The style id of the STANDARD style.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_standard_doc_style
  RETURN NUMBER
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'get_standard_doc_style';
  l_progress          VARCHAR2(3);
  l_style_id NUMBER;
BEGIN

  l_progress := '010';

  SELECT style_id
    INTO l_style_id
    FROM po_doc_style_headers pdhs
   WHERE style_type = 'STANDARD';

  l_progress := '020';

  return l_style_id;

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;



--------------------------------------------------------------------------------
--Start of Comments
--Name: get_document_style_settings
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure return the style settings.
--Parameters:
--IN:
--p_api_version:
--  Version number of API that caller expects. It should match the constant
--  'l_api_version' defined in the procedure.
--p_style_id
--  style id
--None.
--OUT:
--x_style_name
--  style name
--x_style_description
--  style description
--x_style_type
--  style tyle
--x_status
--  style status
--x_advances_flag
-- advances flag
--x_retainage_flag
-- retainage flag
--x_price_breaks_flag
--  price breaks flag
--x_price_differentials_flag
--  price differentials flag
--x_progress_payment_flag
--  progress payment flag
--x_contract_financing_flag
--  contract financing flag
--x_line_type_allowed
--  line type allowed
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_document_style_settings(
  p_api_version                 IN NUMBER
  , p_style_id                    IN NUMBER
  , x_style_name               OUT NOCOPY VARCHAR2
  , x_style_description        OUT NOCOPY VARCHAR2
  , x_style_type               OUT NOCOPY VARCHAR2
  , x_status                   OUT NOCOPY VARCHAR2
  , x_advances_flag            OUT NOCOPY VARCHAR2
  , x_retainage_flag           OUT NOCOPY VARCHAR2
  , x_price_breaks_flag        OUT NOCOPY VARCHAR2
  , x_price_differentials_flag OUT NOCOPY VARCHAR2
  , x_progress_payment_flag    OUT NOCOPY VARCHAR2
  , x_contract_financing_flag  OUT NOCOPY VARCHAR2
  , x_line_type_allowed        OUT NOCOPY VARCHAR2)
IS
  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'get_document_style_settings';
  l_progress          VARCHAR2(3);

BEGIN

  l_progress := '010';

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';

  SELECT
    pdsh.style_name
    , pdsh.style_description
    , pdsh.style_type
    , pdsh.status
    , pdsh.advances_flag
    , pdsh.retainage_flag
    , pdsh.price_breaks_flag
    , pdsh.price_differentials_flag
    , pdsh.progress_payment_flag
    , pdsh.contract_financing_flag
    , pdsh.line_type_allowed
  INTO
    x_style_name
    , x_style_description
    , x_style_type
    , x_status
    , x_advances_flag
    , x_retainage_flag
    , x_price_breaks_flag
    , x_price_differentials_flag
    , x_progress_payment_flag
    , x_contract_financing_flag
    , x_line_type_allowed
  FROM po_doc_style_headers pdsh
 WHERE pdsh.style_id = p_style_id;

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;

-- GRP call for the PVT procedure

PROCEDURE style_validate_req_attrs(p_api_version      IN NUMBER DEFAULT 1.0,
                                     p_init_msg_list    IN VARCHAR2 default FND_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_doc_style_id     IN NUMBER,
                                     p_document_id      IN NUMBER,
                                     p_line_type_id     IN VARCHAR2,
                                     p_purchase_basis   IN VARCHAR2,
                                     p_destination_type IN VARCHAR2,
                                     p_source           IN VARCHAR2) IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'style_validate_req_attrs';
  l_progress          VARCHAR2(3);

  BEGIN

  l_progress := '010';

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';

    PO_DOC_STYLE_PVT.STYLE_VALIDATE_REQ_ATTRS(p_api_version      => p_api_version,
                                 p_init_msg_list    => p_init_msg_list,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_doc_style_id     => p_doc_style_id,
                                 p_document_id      => p_document_id,
                                 p_line_type_id     => p_line_type_id,
                                 p_purchase_basis   => p_purchase_basis,
                                 p_destination_type => p_destination_type,
                                 p_source           => p_source);


EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
  RAISE;
END;



END PO_DOC_STYLE_GRP;

/
