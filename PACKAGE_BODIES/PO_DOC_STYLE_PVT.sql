--------------------------------------------------------
--  DDL for Package Body PO_DOC_STYLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOC_STYLE_PVT" AS
  /* $Header: PO_DOC_STYLE_PVT.plb 120.7.12010000.5 2012/06/28 02:31:35 jozhong ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOC_STYLE_PVT';


  --forward Declarations

  FUNCTION is_line_type_enabled(p_style_id       IN NUMBER,
                                p_line_type_id   IN NUMBER) RETURN BOOLEAN;

  PROCEDURE check_purchase_basis_enabled(p_style_id               IN NUMBER,
                                         p_purchase_basis         IN VARCHAR2,
                                         x_purchase_basis_enabled OUT NOCOPY BOOLEAN,
                                         x_related_line_types     OUT NOCOPY VARCHAR2);

  FUNCTION is_rate_based_temp_labor(p_line_type_id NUMBER) RETURN BOOLEAN;

  FUNCTION is_amount_based_services_line(p_line_type_id NUMBER) RETURN BOOLEAN;
  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: style_validate_req_lines
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This function would check whether the req lines inserted in the
  --  PO_SESSION_GT are comapatible with all other in terms of style.
  --Parameters:
  --IN:
  --  p_session_gt_key
  --    key to identify the records inserted for a given session
  --  p_po_header_id
  --    Header id of the Document to which the requisition lines are added to
  --    would be NULL incase of autocreating a NEW Document
  --  p_style_id
  --    Paramter to pass in the group style against which the req lines
  --    would be validated for style compatilbity
  --OUT:
  --  x_style_id
  --    returns the style compatible for a group of requisition lines
  --    would be NULL incase of style incompatiblities
  --
  -- x_return_status
  --    FND_API.g_ret_sts_success : indicates a group of requisition lines
  --                                 are compatible
  --    FND_API.g_ret_sts_error  : group of requisition lines encountered
  --                               style incomaptibility
  --End of Comments
  -------------------------------------------------------------------------------

  PROCEDURE style_validate_req_lines(p_api_version    IN NUMBER DEFAULT 1.0,
                                     p_init_msg_list  IN VARCHAR2 default fnd_api.g_false,
                                     x_return_status  OUT NOCOPY VARCHAR2,
                                     x_msg_count      OUT NOCOPY NUMBER,
                                     x_msg_data       OUT NOCOPY VARCHAR2,
                                     p_session_gt_key IN NUMBER,
                                     p_po_header_id   IN NUMBER,
                                     p_po_style_id    IN NUMBER DEFAULT NULL,
                                     x_style_id       OUT NOCOPY NUMBER) IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.style_validate_req_lines';

    l_api_name    CONSTANT VARCHAR2(30) := 'style_validate_req_lines';
    l_api_version CONSTANT NUMBER := 1.0;

    /*MAPPING FOR PO_SESSION_GT for STYLES */
    /*
    * PO_SESSION_GT:
    * key = key into table
    * num1 = Requisition line ID
    * num2 = Source Document ID
    * num3 = Line Type ID
    * char1 = Destination type
    * char2 = Purchase Basis
    */

       --Fetch the lines from the GT table with source doc refrence
      CURSOR REQ_LINES_SOURCE_CSR IS
      SELECT PGT.NUM2    source_doc_id,
             PGT.NUM3    line_type_id,
             PGT.CHAR1   destination_type,
             PGT.CHAR2   purchase_basis,
             PH.style_id source_doc_style_id
        FROM PO_SESSION_GT  PGT,
             PO_HEADERS_ALL PH
       WHERE PGT.KEY = p_session_gt_key
         AND PGT.NUM2 = PH.PO_HEADER_ID
	 AND PGT.NUM2 IS NOT NULL;

    --Fetch the lines from the GT table without source doc reference
      CURSOR REQ_LINES_NOSOURCE_CSR IS
      SELECT PGT.NUM3    line_type_id,
             PGT.CHAR1   destination_type,
             PGT.CHAR2   purchase_basis
        FROM PO_SESSION_GT  PGT
       WHERE PGT.KEY = p_session_gt_key
	 AND PGT.NUM2 IS NULL;

    l_style_id_tbl    po_tbl_number;
    l_group_style_id  PO_DOC_STYLE_HEADERS.style_id%TYPE;

    l_source_doc_id       PO_REQUISITION_LINES_ALL.blanket_po_header_id%TYPE;
    l_line_type_id        PO_REQUISITION_LINES_ALL.line_type_id%TYPE;
    l_purchase_basis      PO_REQUISITION_LINES_ALL.purchase_basis%TYPE;
    l_destination_type    PO_REQUISITION_LINES_ALL.destination_type_code%TYPE;
    l_source_doc_style_id PO_DOC_STYLE_HEADERS.style_id%TYPE;


  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_session_gt_key', p_session_gt_key);
       PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
       PO_LOG.proc_begin(d_module, 'p_po_style_id', p_po_style_id);
    END IF;

    d_progress := 10;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    d_progress := 20;
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


      d_progress := 25;

      OPEN REQ_LINES_SOURCE_CSR;
      LOOP
        FETCH REQ_LINES_SOURCE_CSR
          INTO l_source_doc_id,
	       l_line_type_id,
               l_destination_type,
               l_purchase_basis,
	       l_source_doc_style_id;
        EXIT WHEN REQ_LINES_SOURCE_CSR%NOTFOUND;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'style validate Req attrs bef');
        END IF;


        STYLE_VALIDATE_REQ_ATTRS(p_api_version      => 1.0,
                                 p_init_msg_list    => p_init_msg_list,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_doc_style_id     => l_source_doc_style_id,
                                 p_document_id      => null,
                                 p_line_type_id     => l_line_type_id,
                                 p_purchase_basis   => l_purchase_basis,
                                 p_destination_type => l_destination_type,
                                 p_source           => 'AUTOCREATE');

        IF (x_return_status <> FND_API.g_ret_sts_success) THEN

          X_style_id := NULL;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                    p_data  => x_msg_data);

          IF (PO_LOG.d_proc) THEN
              PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
              PO_LOG.proc_end(d_module, 'x_style_id', x_style_id);
              PO_LOG.proc_end(d_module);
          END IF;

          CLOSE REQ_LINES_SOURCE_CSR;
          RETURN;
        END IF;

      END LOOP;

    CLOSE REQ_LINES_SOURCE_CSR;

    d_progress := 30;
    IF p_po_style_id is NOT NULL THEN

    d_progress := 32;
       l_group_style_id := p_po_style_id;

    ELSE

       d_progress := 40;
      --Determine how many styles exist in the requisition lines
      --Get the source doc styles and group by style id.
      select poh.style_id BULK COLLECT
        into l_style_id_tbl
        from po_session_gt  pgt,
             po_headers_all poh
       where pgt.key = p_session_gt_key
         and pgt.num2 = poh.po_header_id
       group by poh.style_id;


    IF p_po_header_id is NULL THEN

      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Style Validate Action NEW');
      END IF;
      ---ACTION NEW

      -- If more than one record is retrieved it means that
      -- more than one style exists on the document
      -- populate the error messages and return false

      IF l_style_id_tbl.count > 1 THEN

        d_progress := 50;
        FND_MESSAGE.SET_NAME('PO','PO_REQ_LINES_MIXED_STYLES');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_style_id_tbl.count = 0 THEN
        --There is no style and hence all are
        --compatible and they would have a standard style
        d_progress      := 60;

        x_style_id      := PO_DOC_STYLE_GRP.get_standard_doc_style;
        x_return_status := FND_API.g_ret_sts_success;

        IF (PO_LOG.d_proc) THEN
            PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
            PO_LOG.proc_end(d_module, 'x_style_id', x_style_id);
            PO_LOG.proc_end(d_module);
        END IF;
        RETURN;
      END IF;

      IF l_style_id_tbl.count = 1 THEN
        d_progress       := 70;
        l_group_style_id := l_style_id_tbl(1);
      END IF;
    ELSE  /*ACTION ADD_TO */

       d_progress := 110;

       IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Style Validate Action ADD');
       END IF;

       l_group_style_id := get_doc_style_id(p_po_header_id);

      IF l_style_id_tbl.count > 1 THEN
        d_progress := 120;

        FND_MESSAGE.SET_NAME('PO','PO_ADDTO_DOCSTYLE_MISMATCH');
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_style_id_tbl.count = 1 THEN
            IF l_style_id_tbl(1)<> l_group_style_id THEN
                FND_MESSAGE.SET_NAME('PO','PO_ADDTO_DOCSTYLE_MISMATCH');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

      d_progress       := 130;


    END IF; /*IF p_po_header_id is NULL THEN*/
   END IF; /*IF p_style_id is NOT NULL THEN*/

    d_progress := 200;
    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'Group style id',l_group_style_id);
    END IF;

    IF PO_DOC_STYLE_GRP.is_standard_doc_style(l_group_style_id) = 'Y' THEN

       x_style_id      := l_group_style_id;
       x_return_status := FND_API.g_ret_sts_success;

       IF (PO_LOG.d_proc) THEN
          PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
          PO_LOG.proc_end(d_module, 'x_style_id', x_style_id);
          PO_LOG.proc_end(d_module);
        END IF;
       RETURN;
    ELSE
      --Fetch req lines without source refernces from the GT table
      OPEN REQ_LINES_NOSOURCE_CSR;
      LOOP
        FETCH REQ_LINES_NOSOURCE_CSR
          INTO l_line_type_id,
               l_destination_type,
               l_purchase_basis;
        EXIT WHEN REQ_LINES_NOSOURCE_CSR%NOTFOUND;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'style validate Req attrs');
        END IF;


        STYLE_VALIDATE_REQ_ATTRS(p_api_version      => 1.0,
                                 p_init_msg_list    => p_init_msg_list,
                                 x_return_status    => x_return_status,
                                 x_msg_count        => x_msg_count,
                                 x_msg_data         => x_msg_data,
                                 p_doc_style_id     => l_group_style_id,
                                 p_document_id      => null,
                                 p_line_type_id     => l_line_type_id,
                                 p_purchase_basis   => l_purchase_basis,
                                 p_destination_type => l_destination_type,
                                 p_source           => 'AUTOCREATE');

        IF (x_return_status <> FND_API.g_ret_sts_success) THEN

          X_style_id := NULL;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                    p_data  => x_msg_data);

          IF (PO_LOG.d_proc) THEN
              PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
              PO_LOG.proc_end(d_module, 'x_style_id', x_style_id);
              PO_LOG.proc_end(d_module);
          END IF;

          CLOSE REQ_LINES_NOSOURCE_CSR;
          RETURN;
        END IF;

      END LOOP;

        x_style_id := l_group_style_id;
        x_return_status := FND_API.g_ret_sts_success;

        IF (PO_LOG.d_proc) THEN
            PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
            PO_LOG.proc_end(d_module, 'x_style_id', x_style_id);
            PO_LOG.proc_end(d_module);
        END IF;

        CLOSE REQ_LINES_NOSOURCE_CSR;
        RETURN;
    END IF;  /*IF PO_DOC_STYLE_GRP.is_standard_doc_style*/


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_style_id      := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data
          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;

  END style_validate_req_lines;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: style_validate_req_attrs
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This procedure would check whether the attributes of requisition line would be
  --  be compatible with style
  --Parameters:
  --IN:
  -- p_doc_style_id
  --   Document Style against which attributes of a requisition line are validated
  -- p_document_id
  --   Document against which attributes of a requisition line are validated for style
  -- p_line_type_id
  --   Line type of requisition line
  -- p_purchase_basis
  --   Purchase basis of a requisition line
  -- p_destination_type
  --   Destination type of a requisition line
  -- p_source
  --   Calling program
  --   Possible values
  --    'AUTOCREATE'   called from Autocreate Forms
  --    'REQUISITION'  called from Requisition Entry and Automatic Sourcing
  --OUT:
  -- x_return_status
  --    FND_API.g_ret_sts_success : indicates the attributes of requisition line
  --                                 are compatible with a style
  --    FND_API.g_ret_sts_error  : attributes of requisition line encountered
  --                               style incomaptibility
  --End of Comments
  -------------------------------------------------------------------------------

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

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.style_validate_req_attrs';

    l_api_name    CONSTANT VARCHAR2(30) := 'style_validate_req_attrs';
    l_api_version CONSTANT NUMBER := 1.0;


    l_doc_style_id                PO_DOC_STYLE_HEADERS.style_id%type;
    l_purchase_basis              PO_REQUISITION_LINES_ALL.purchase_basis%TYPE;
    l_purchase_basis_enabled      BOOLEAN;
    l_line_type_allowed           PO_DOC_STYLE_HEADERS.line_type_allowed%TYPE;
    l_destination_type            PO_LOOKUP_CODES.lookup_code%TYPE;

  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_doc_style_id', p_doc_style_id);
       PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
       PO_LOG.proc_begin(d_module, 'p_line_type_id', p_line_type_id);
       PO_LOG.proc_begin(d_module, 'p_purchase_basis', p_purchase_basis);
       PO_LOG.proc_begin(d_module, 'p_destination_type', p_destination_type);
       PO_LOG.proc_begin(d_module, 'p_source', p_source);
    END IF;

    d_progress := 10;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    d_progress := 20;
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF p_doc_style_id is NULL then
       l_doc_style_id := get_doc_style_id(p_document_id);
    ELSE
        l_doc_style_id := p_doc_style_id;
    END IF;

    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module, 'l_doc_style_id', l_doc_style_id);
    END IF;

    IF p_purchase_basis is null THEN

       d_progress := 20;

       SELECT purchase_basis
        INTO  l_purchase_basis
        FROM  po_line_types_b
       WHERE  line_type_id = p_line_type_id;

    ELSE
       l_purchase_basis := p_purchase_basis;
    END IF;

    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module, 'l_purchase_basis', l_purchase_basis);
    END IF;
    /*Validate Purchase basis*/

    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'validate purchase basis ');
    END IF;

    CHECK_PURCHASE_BASIS_ENABLED(p_style_id               => l_doc_style_id,
                                 p_purchase_basis         => l_purchase_basis,
                                 x_purchase_basis_enabled => l_purchase_basis_enabled,
                                 x_related_line_types     => l_line_type_allowed);

     IF NOT l_purchase_basis_enabled THEN

        FND_MESSAGE.set_name('PO', 'PO_REQLINE_ATTR_INCOMPATIBLE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('PO','PO_LINE_TYPE_PURCHASE_BASIS'));
        RAISE FND_API.G_EXC_ERROR;
     END IF;


    /*Validate Line Type */

    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'validate line type ');
    END IF;

    IF (l_line_type_allowed = 'SPECIFIED') THEN

        IF NOT IS_LINE_TYPE_ENABLED(l_doc_style_id,
                                    p_line_type_id
                                   ) THEN

          d_progress := 30;
          FND_MESSAGE.set_name('PO','PO_REQLINE_ATTR_INCOMPATIBLE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('PO','PO_LINE_TYPE'));
          RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;

    -- The complex work validations need to be done only in the case
    -- of Autocreate and Requisitions Forms
    -- Skip these when called from iProcuremnt (p_source= 'ICX')
    -- Bug 5070181

   IF p_source IN ('AUTOCREATE', 'REQUISITION') then
    /*Complex work validations :*/

    IF is_progress_payments_enabled(l_doc_style_id) THEN
       d_progress := 100;

       IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_progress, 'complex work validations: line type');
       END IF;

      /*Complex work validation :1 */
      IF IS_RATE_BASED_TEMP_LABOR(p_line_type_id) THEN
         d_progress := 110;
         IF (p_source = 'AUTOCREATE') THEN
             d_progress := 120;
             FND_MESSAGE.set_name('PO','PO_REQLINE_ATTR_INCOMPATIBLE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('PO','PO_LINE_TYPE'));
         ELSIF (p_source = 'REQUISITION') THEN
             d_progress := 130;
             FND_MESSAGE.SET_NAME('PO','PO_DOCSTYLE_TEMPLABOR_MISMATCH');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*Complex work Validation :2 */
      IF is_amount_based_services_line(p_line_type_id) THEN
         d_progress := 135;
         IF (p_source = 'AUTOCREATE') THEN
             d_progress := 137;
             FND_MESSAGE.set_name('PO','PO_REQLINE_ATTR_INCOMPATIBLE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('PO','PO_LINE_TYPE'));
         ELSIF (p_source = 'REQUISITION') THEN
             d_progress := 139;
             FND_MESSAGE.SET_NAME('PO','PO_AMT_SRV_PRO_PAY_INVALID');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      /*Complex work validation :3 */
       IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_progress, 'complex work validations: destination type');
       END IF;

      IF p_destination_type is not null AND
         p_destination_type IN ('INVENTORY', 'SHOP FLOOR') THEN
        d_progress := 150;


        IF (p_source = 'AUTOCREATE') THEN
            d_progress := 160;
            FND_MESSAGE.set_name('PO','PO_REQLINE_ATTR_INCOMPATIBLE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('PO','PO_DESTINATION_TYPE'));

        ELSIF (p_source = 'REQUISITION') THEN
            d_progress := 170;
            select displayed_field
            into l_destination_type
            from po_lookup_codes
            where LOOKUP_TYPE = 'DESTINATION TYPE'
            and LOOKUP_CODE = p_destination_type;

            FND_MESSAGE.set_name('PO','PO_DOCSTYLE_DEST_TYPE_MISMATCH');
            FND_MESSAGE.SET_TOKEN('DESTINATION_TYPE',l_destination_type);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;  /*IF is_progress_payments_enabled(l_doc_style_id)*/
  END IF;  /*IF p_source IN ('AUTOCREATE', 'REQUISITION')*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (PO_LOG.d_proc) THEN
         PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
         PO_LOG.proc_end(d_module);
     END IF;
    RETURN;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data
          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;

  END style_validate_req_attrs;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: check_purchase_basis_enabled
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  check if purchase basis is enabled for a given style
  --  is of STANDARD type.
  --Parameters:
  --IN:
  --  p_style_id
  --   Indicates the Document Style
  --  p_purchase_basis
  --   Purchase basis of a requisition line
  --OUT:
  --  x_purchase_basis_enabled
  --    Indicates that the purchasis basis is enabled for the document style
  --  x_related_line_types
  --    returns which line types are enabled
  --End of Comments
  -------------------------------------------------------------------------------

  PROCEDURE check_purchase_basis_enabled(p_style_id               IN NUMBER,
                                         p_purchase_basis         IN VARCHAR2,
                                         x_purchase_basis_enabled OUT NOCOPY BOOLEAN,
                                         x_related_line_types     OUT NOCOPY VARCHAR2) IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.check_purchase_basis_enabled';

  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
       PO_LOG.proc_begin(d_module, 'p_purchase_basis', p_purchase_basis);
    END IF;

    d_progress := '010';

    SELECT pdsh.line_type_allowed
      INTO x_related_line_types
      FROM po_doc_style_values  pdsv,
           po_doc_style_headers pdsh
     WHERE pdsh.style_id = p_style_id
       AND pdsv.style_id = pdsh.style_id
       AND pdsv.style_attribute_name = 'PURCHASE_BASES'
       AND pdsv.style_allowed_value = p_purchase_basis
       AND nvl(pdsv.enabled_flag,
               'N') = 'Y';

    d_progress := '020';

    X_purchase_basis_enabled := TRUE;
    IF (PO_LOG.d_proc) THEN
         PO_LOG.proc_end(d_module, 'x_purchase_basis_enabled', x_purchase_basis_enabled);
         PO_LOG.proc_end(d_module, 'x_related_line_types', x_related_line_types);
         PO_LOG.proc_end(d_module);
     END IF;

    RETURN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_purchase_basis_enabled := FALSE;
      x_related_line_types := NULL;
      IF (PO_LOG.d_proc) THEN
         PO_LOG.proc_end(d_module, 'x_purchase_basis_enabled', x_purchase_basis_enabled);
         PO_LOG.proc_end(d_module, 'x_related_line_types', x_related_line_types);
         PO_LOG.proc_end(d_module);
      END IF;

      RETURN;
  END check_purchase_basis_enabled;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_line_type_enabled
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  validates the line type for a given style
  --Parameters:
  --IN:
  --  p_style_id
  --   Indicates the Document Style
  --  p_line_type_id
  --   Line Type of a requisition line
  --End of Comments
  -------------------------------------------------------------------------------
  FUNCTION is_line_type_enabled(p_style_id       IN NUMBER,
                                p_line_type_id   IN NUMBER
                                ) RETURN BOOLEAN IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.is_line_type_enabled';



    l_count NUMBER;
  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
       PO_LOG.proc_begin(d_module, 'p_line_type_id', p_line_type_id);
    END IF;

    d_progress := 10;


        SELECT count(1)
          INTO l_count
          FROM dual
         WHERE exists
         (SELECT NULL
                  FROM PO_DOC_STYLE_VALUES pdv
                 WHERE pdv.style_id = p_style_id
                   AND pdv.style_attribute_name = 'LINE_TYPES'
                   AND pdv.style_allowed_value = to_char(p_line_type_id)
                   AND nvl(pdv.enabled_flag,
                           'N') = 'Y');

     d_progress := 20;
        IF l_count > 0 THEN
          return TRUE;
        END IF;

    d_progress := 030;

    return FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END is_line_type_enabled;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_rate_based_temp_labor
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  checks whether the  line type  is rate temp based labour
  --Parameters:
  --IN:
  --  p_line_type_id
  --   Line Type of a requisition line
  --End of Comments
  -------------------------------------------------------------------------------
  FUNCTION is_rate_based_temp_labor(p_line_type_id NUMBER) RETURN BOOLEAN is

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.is_rate_based_temp_labor';

    l_result       VARCHAR2(1);
    l_count        NUMBER;
  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_line_type_id', p_line_type_id);
    END IF;
    d_progress := 10;

        SELECT count(1)
          INTO l_count
          FROM dual
        WHERE exists
         (SELECT NULL
               FROM po_line_types_b
     WHERE purchase_basis = 'TEMP LABOR'
       AND order_type_lookup_code = 'RATE'
       AND line_type_id = p_line_type_id);

     d_progress := 20;
        IF l_count > 0 THEN
          return TRUE;
        END IF;

    d_progress := 030;

    return FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END is_rate_based_temp_labor;


    --------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_amount_based_services_line
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  checks whether the  line type  is amount based services line type
  --Parameters:
  --IN:
  --  p_line_type_id
  --   Line Type of a requisition line
  --End of Comments
  -------------------------------------------------------------------------------
  FUNCTION is_amount_based_services_line(p_line_type_id NUMBER) RETURN BOOLEAN is

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.is_amount_based_services_line';

    l_result       VARCHAR2(1);
    l_count        NUMBER;
  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_line_type_id', p_line_type_id);
    END IF;
    d_progress := 10;

        SELECT count(1)
          INTO l_count
          FROM dual
        WHERE exists
         (SELECT NULL
               FROM po_line_types_b
     WHERE purchase_basis = 'SERVICES'
       AND order_type_lookup_code = 'AMOUNT'
       AND line_type_id = p_line_type_id);

     d_progress := 20;
        IF l_count > 0 THEN
          return TRUE;
        END IF;

    d_progress := 030;

    return FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END is_amount_based_services_line;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: get_doc_style_id
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  gets the style id associated with a document
  --Parameters:
  --IN:
  --  p_style_id
  --   Indicates the Document Style
  --End of Comments
  -------------------------------------------------------------------------------

  FUNCTION get_doc_style_id(p_doc_id IN NUMBER) RETURN VARCHAR2 IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.get_doc_style_id';

    l_style_id     PO_DOC_STYLE_HEADERS.STYLE_ID%type;
  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_doc_id', p_doc_id);
    END IF;

    d_progress := 10;

    SELECT style_id
      INTO l_style_id
      FROM PO_HEADERS_MERGE_V
     WHERE po_header_id = p_doc_id;

    RETURN l_style_id;

  EXCEPTION
    WHEN OTHERS THEN

      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END get_doc_style_id;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: get_style_display_name
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  gets the style display name associated with a document
  --Parameters:
  --IN:
  --  p_style_id
  --   Indicates the Document Style
  --End of Comments
  -------------------------------------------------------------------------------

  FUNCTION get_style_display_name(p_doc_id   IN NUMBER,
                                  p_language IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.get_style_display_name';

    l_style_display_name PO_DOC_STYLE_LINES_TL.DISPLAY_NAME%type;
    --Bug 14115069 Need to check if type is planned po
    l_type_lookup_code PO_HEADERS_ALL.TYPE_LOOKUP_CODE%type;

  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_doc_id', p_doc_id);
       PO_LOG.proc_begin(d_module, 'p_language', p_language);
    END IF;

    d_progress := 10;

  SELECT type_lookup_code
  INTO l_type_lookup_code
  FROM PO_HEADERS_ALL
  WHERE po_header_id = p_doc_id;

  --Bug 14115069 Need to check if type is planned po
  IF(l_type_lookup_code <> 'PLANNED') THEN
    SELECT display_name
      INTO l_style_display_name
      FROM PO_DOC_STYLE_LINES_TL tl,
           PO_HEADERS_MERGE_V ph
     WHERE tl.language = nvl(p_language,
                             USERENV('LANG'))
       AND tl.style_id = ph.style_id
       AND ph.po_header_id = p_doc_id
       AND tl.document_subtype = ph.type_lookup_code;
  ELSE
    SELECT TYPE_NAME
    INTO l_style_display_name
    FROM PO_DOCUMENT_TYPES_TL tl,
         PO_HEADERS_MERGE_V ph
    WHERE tl.language       = NVL(p_language, USERENV('LANG'))
    AND ph.po_header_id     = p_doc_id
    AND tl.document_subtype = 'PLANNED';
  END IF;

    RETURN l_style_display_name;

  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END get_style_display_name;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_progress_payments_enabled
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  checks if progress payemnts are enabled for a given style
  --Parameters:
  --  p_style_id
  --   Indicates the Document Style
  --End of Comments
  -------------------------------------------------------------------------------

  FUNCTION is_progress_payments_enabled(p_style_id NUMBER) RETURN BOOLEAN IS

    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.is_progress_payments_enabled';

    l_result       VARCHAR2(1);
  BEGIN

    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
    END IF;
    d_progress := 10;

    SELECT progress_payment_flag
      INTO l_result
      FROM po_doc_style_headers
     WHERE style_id = p_style_id;

    IF l_result = 'Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END is_progress_payments_enabled;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: populate_gt_and_validate
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  Populates the Po session gt with requistion lines to be style validated
  --End of Comments
  -------------------------------------------------------------------------------
  PROCEDURE populate_gt_and_validate(p_api_version             IN	NUMBER DEFAULT 1.0,
                                     p_init_msg_list           IN VARCHAR2,
                                     x_return_status           OUT NOCOPY VARCHAR2,
                                     x_msg_count               OUT NOCOPY NUMBER,
                                     x_msg_data                OUT NOCOPY VARCHAR2,
                                     p_req_line_id_table       IN g_po_tbl_num,
                                     p_source_doc_id_table     IN g_po_tbl_num,
                                     p_line_type_id_table      IN g_po_tbl_num,
                                     p_destination_type_table  IN g_po_tbl_char30,
                                     p_purchase_basis_table    IN g_po_tbl_char30,
                                     p_po_header_id            IN NUMBER,
                                     p_po_style_id             IN NUMBER DEFAULT NULL,
                                     x_style_id                OUT NOCOPY NUMBER) IS
    d_progress NUMBER;
    d_module   VARCHAR2(60) := 'po.plsql.PO_DOC_STYLE_PVT.populate_gt_and_validate';

    l_session_gt_key PO_SESSION_GT.KEY%TYPE;
    l_return_status  VARCHAR2(2);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

  BEGIN


    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module);
       PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    END IF;

    SELECT PO_SESSION_GT_S.nextval INTO l_session_gt_key FROM dual;

    /*
    * PO_SESSION_GT:
    * key = key into table
    * num1 = Requisition line ID
    * num2 = Source Document ID
    * num3 = Line Type ID
    * char1 = Destination type
    * char2 = Purchase Basis
    */
    d_progress := 10;
       IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_progress, 'inserting into po_session_gt');
       END IF;

    FORALL i IN p_req_line_id_table.first .. p_req_line_id_table.last
      insert into po_session_gt
        (key,
         num1,
         num2,
         num3,
         char1,
         char2)
      values
        (l_session_gt_key,
         p_req_line_id_table(i),
         p_source_doc_id_table(i),
         p_line_type_id_table(i),
         p_destination_type_table(i),
         p_purchase_basis_table(i)
        );

    d_progress := 20;
   IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_progress, 'style_validate_req_lines');
    END IF;

    STYLE_VALIDATE_REQ_LINES(p_api_version    => 1.0,
                             p_init_msg_list  => FND_API.G_TRUE,
                             X_return_status  => x_return_status,
                             X_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_session_gt_key => l_session_gt_key,
                             p_po_header_id   => p_po_header_id,
                             p_po_style_id    => p_po_style_id,
                             x_style_id       => x_style_id);

     delete po_session_gt where key = l_session_gt_key;

       IF (PO_LOG.d_proc) THEN
          PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
          PO_LOG.proc_end(d_module);
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module,d_progress,SQLCODE || SQLERRM);
      END IF;
      RAISE;
  END populate_gt_and_validate;

END PO_DOC_STYLE_PVT;

/
