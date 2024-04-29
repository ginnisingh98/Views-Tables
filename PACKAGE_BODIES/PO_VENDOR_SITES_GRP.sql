--------------------------------------------------------
--  DDL for Package Body PO_VENDOR_SITES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDOR_SITES_GRP" AS
/* $Header: POXGDVSB.pls 120.2 2006/07/21 13:32:05 skalra noship $ */
-------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Transmission_Defaults
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure is built as a wrapper over procedure get_transmission_defaults--  in the package PO_VENDOR_SITES_SV to allowed to be called by other apps.

--Parameters:
--IN:
--p_api_version
--  API version
--p_init_msg_list
--  True/False parameter to initialize message list
--p_document_id
--  PO header ID
--p_document_type
--    This will be parsed to retrieve the PO document type
--    The document types are :
--        PO : For Standard/Planned
--        PA : For Blanket/Contract
--        RELEASE : Release
--p_document_subtype:
--    The subtype of the document.
--        Valid Document types and Document subtypes are
--        Document Type      Document Subtype
--        RELEASE      --->  SCHEDULED/BLANKET
--        PO           --->  PLANNED/STANDARD
--        PA           --->  CONTRACT/BLANKET
--
--p_preparer_id
--     Preparer_id of the document.
--OUT:
--x_default_method -
--     Default supplier communication method set up in the vendor sites.
--x_email_address
--     Email address where the email should be sent.
--x_fax_number
--     Fax number where the fax should be sent.
--x_document_num
--     Document Number.
--x_print_flag
--     Set to 'Y' if default transmission method is PRINT
--x_fax_flag
--     Set to 'Y' if default transmission method is FAX
--x_email_flag
--     Set to 'Y' if default transmission method is EMAIL
--x_return_status
--     FND_API.G_RET_STS_ERROR - for expected error
--     FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--     FND_API.G_RET_STS_SUCCESS - for success
--x_msg_count
--     Message count i.e number of messages in the fnd message stack
--x_msg_data
--     Message data in fnd message stack

--Notes:
-- This is a wrapper API for PO_VENDOR_SITES_SV.Get_Transmission_Defaults() to
-- retrieve Supplier's default transmission method. Print,Fax or E-Mail flags
-- are set appropriately to help in calling of further APIs such as
-- po_reqapproval_init1.start_wf_process().
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
Procedure Get_Transmission_Defaults(p_api_version        IN VARCHAR2,
                                    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
                                    p_document_id        IN NUMBER,
                                    p_document_type      IN VARCHAR2,
                                    p_document_subtype   IN VARCHAR2,
                                    p_preparer_id        IN OUT NOCOPY NUMBER,
                                    x_default_method     OUT NOCOPY VARCHAR2,
                                    x_email_address      OUT NOCOPY VARCHAR2,
                                    x_fax_number         OUT NOCOPY VARCHAR2,
                                    x_document_num       OUT NOCOPY VARCHAR2,
                                    x_print_flag         OUT NOCOPY VARCHAR2,
                                    x_fax_flag           OUT NOCOPY VARCHAR2,
                                    x_email_flag         OUT NOCOPY VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2) IS

l_api_name CONSTANT VARCHAR2(30) := 'Get_Transmission_Defaults';
l_api_version CONSTANT NUMBER := 1.0;
BEGIN
x_print_flag := 'N';
x_fax_flag := 'N';
x_email_flag := 'N';

    IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name)) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- initialize API return status to success
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

    IF (FND_API.to_Boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Call Get_transmission_Defaults from PO_VENDOR_SITES_SV package */
    PO_VENDOR_SITES_SV.Get_Transmission_Defaults(
                                      p_document_id =>  p_document_id,
                                      p_document_type =>  p_document_type,
                                      p_document_subtype => p_document_subtype,
                                      p_preparer_id => p_preparer_id,
                                      x_default_method => x_default_method,
                                      x_email_address => x_email_address,
                                      x_fax_number => x_fax_number,
                                      x_document_num => x_document_num);

    IF (x_default_method = 'EMAIL') THEN
        x_email_flag := 'Y';
    ELSIF  (x_default_method = 'PRINT') THEN
        x_print_flag := 'Y';
    ELSIF  (x_default_method = 'FAX') THEN
        x_fax_flag := 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF (g_fnd_debug='Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(log_level => FND_LOG.level_unexpected
                               ,module    => g_module_prefix ||l_api_name
                               ,message   => SQLERRM);
                END IF;
            END IF;
       END IF;

       FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);

END Get_Transmission_Defaults;

END PO_VENDOR_SITES_GRP;

/
