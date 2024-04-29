--------------------------------------------------------
--  DDL for Package PO_SIGNATURE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SIGNATURE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGSIGS.pls 115.2 2004/03/09 22:02:27 bao noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_SIGNATURE_GRP';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';


---------------------------------------------------------------------------------
-- Updates the PO tables
---------------------------------------------------------------------------------
  PROCEDURE Update_Po_Details(p_api_version         IN NUMBER, -- bug3488839
                              p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                              p_po_header_id        IN NUMBER,
                              p_status              IN VARCHAR2,
                              p_action_code         IN VARCHAR2,
                              p_object_type_code    IN VARCHAR2,
                              p_object_subtype_code IN VARCHAR2,
                              p_employee_id         IN NUMBER,
                              p_revision_num        IN NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_msg_data            OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- To create Item key for the Document Signature Process
---------------------------------------------------------------------------------
  PROCEDURE Get_Item_Key(p_api_version   IN NUMBER,  -- bug3488839
                         p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                         p_po_header_id  IN  NUMBER,
                         p_revision_num  IN  NUMBER,
                         p_document_type IN  VARCHAR2,
                         x_itemkey       OUT NOCOPY VARCHAR2,
                         x_result        OUT NOCOPY VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- Returns item key of the active Document Signature Process
---------------------------------------------------------------------------------
  PROCEDURE Find_Item_Key(p_api_version   IN NUMBER,  -- bug3488839
                          p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                          p_po_header_id  IN  NUMBER,
                          p_revision_num  IN  NUMBER,
                          p_document_type IN  VARCHAR2,
                          x_itemkey       OUT NOCOPY VARCHAR2,
                          x_result        OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- To Abort Document Signature Process after Signatures are completed
---------------------------------------------------------------------------------
  PROCEDURE Abort_Doc_Sign_Process(p_api_version   IN NUMBER,  -- bug3488839
                                   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                                   p_itemkey       IN  VARCHAR2,
                                   x_result        OUT NOCOPY VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- To check if eRecords is installed and enabled or not
---------------------------------------------------------------------------------
  PROCEDURE Erecords_Enabled(p_api_version       IN NUMBER, -- bug3488839
                             p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
                             x_erecords_enabled  OUT NOCOPY VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2);

END PO_SIGNATURE_GRP;

 

/
