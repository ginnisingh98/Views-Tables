--------------------------------------------------------
--  DDL for Package Body PO_TAX_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TAX_INTERFACE_GRP" AS
/* $Header: PO_TAX_INTERFACE_GRP.plb 120.0 2005/11/20 23:55:35 nipagarw noship $ */

G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'PO_TAX_INTERFACE_GRP';

-- Logging global constants
D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PACKAGE_NAME);


-----------------------------------------------------------------------------
--Start of Comments
--Name: get_document_tax_constants
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Returns constants for PO EBTAX stored in PO_CONSTANTS_SV
--Parameters:
--IN:
--p_api_version
--  Standard API specification parameter
--p_init_msg_list
--  Standard API specification parameter. Not used
--p_commit
--  Standard API specification parameter. Not used
--p_validation_level
--  Standard API specification parameter. Not used
--p_document_type
--  Document Type. Can have values 'PO', 'RELEASE', 'REQUISITION'
--OUT:
--x_return_status
--  Standard API specification parameter
--  Can hold one of the following values:
--    FND_API.G_RET_STS_SUCCESS (='S')
--    FND_API.G_RET_STS_ERROR (='E')
--    FND_API.G_RET_STS_UNEXP_ERROR (='U')
--x_msg_count
--  Standard API specification parameter. Not used
--x_msg_data
--  Standard API specification parameter
--x_application_id
--  PO Application Id
--x_entity_code
--  Entity Code associated with the document
--x_event_class_code
--  Event Class Code associated with the document
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE get_document_tax_constants(p_api_version      IN  NUMBER,
                                     p_init_msg_list    IN  VARCHAR2,
                                     p_commit           IN  VARCHAR2,
                                     p_validation_level IN  NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_doc_type         IN  VARCHAR2,
                                     x_application_id   OUT NOCOPY NUMBER,
                                     x_entity_code      OUT NOCOPY VARCHAR2,
                                     x_event_class_code OUT NOCOPY VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'GET_DOCUMENT_TAX_CONSTANTS';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            D_PACKAGE_BASE, l_module_name);
  l_api_version CONSTANT NUMBER := 1.0;
  d_progress NUMBER;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module_base, 'p_init_msg_list', p_init_msg_list);
    PO_LOG.proc_begin(d_module_base, 'p_commit', p_commit);
    PO_LOG.proc_begin(d_module_base, 'p_validation_level', p_validation_level);
    PO_LOG.proc_begin(d_module_base, 'p_doc_type', p_doc_type);
  END IF;

  d_progress := 0;
  -- By default return status is SUCCESS if no exception occurs
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_module_name,
                                      g_package_name)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_doc_type = 'PO' THEN
    d_progress := 10;
    x_application_id := PO_CONSTANTS_SV.APPLICATION_ID;
    x_entity_code := PO_CONSTANTS_SV.PO_ENTITY_CODE;
    x_event_class_code :=PO_CONSTANTS_SV.PO_EVENT_CLASS_CODE;
  ELSIF p_doc_type = 'RELEASE' THEN
    d_progress := 20;
    x_application_id := PO_CONSTANTS_SV.APPLICATION_ID;
    x_entity_code := PO_CONSTANTS_SV.REL_ENTITY_CODE;
    x_event_class_code :=PO_CONSTANTS_SV.REL_EVENT_CLASS_CODE;
  ELSIF p_doc_type = 'REQUISITION' THEN
    d_progress := 30;
    x_application_id := PO_CONSTANTS_SV.APPLICATION_ID;
    x_entity_code := PO_CONSTANTS_SV.REQ_ENTITY_CODE;
    x_event_class_code :=PO_CONSTANTS_SV.REQ_EVENT_CLASS_CODE;
  END IF;

  d_progress := 40;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
    PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
    PO_LOG.proc_end(d_module_base, 'x_application_id', x_application_id);
    PO_LOG.proc_end(d_module_base, 'x_entity_code', x_entity_code);
    PO_LOG.proc_end(d_module_base, 'x_event_class_code', x_event_class_code);
  END IF;

  d_progress := 50;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unexpected error in '||l_module_name);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
      PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
      PO_LOG.proc_end(d_module_base, 'x_application_id', x_application_id);
      PO_LOG.proc_end(d_module_base, 'x_entity_code', x_entity_code);
      PO_LOG.proc_end(d_module_base, 'x_event_class_code', x_event_class_code);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in '||l_module_name);
      PO_LOG.proc_end(d_module_base, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module_base, 'x_msg_count', x_msg_count);
      PO_LOG.proc_end(d_module_base, 'x_msg_data', x_msg_data);
      PO_LOG.proc_end(d_module_base, 'x_application_id', x_application_id);
      PO_LOG.proc_end(d_module_base, 'x_entity_code', x_entity_code);
      PO_LOG.proc_end(d_module_base, 'x_event_class_code', x_event_class_code);
    END IF;
END get_document_tax_constants;


END PO_TAX_INTERFACE_GRP;

/
