--------------------------------------------------------
--  DDL for Package Body OKE_MILPAC_INTG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_MILPAC_INTG_WF" AS
/* $Header: OKEMIRVB.pls 115.9 2004/05/26 17:56:44 tweichen ship $ */

--
-- Global Variables
--
EventName    VARCHAR2(240) := NULL;
XmlUrl       VARCHAR2(2000):= NULL;
--
-- Private Procedures and Functions
--
PROCEDURE GetEventName
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

BEGIN

  EventName := WF_ENGINE.GetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName    => 'ECX_EVENT_NAME' );

END GetEventName;

PROCEDURE Initialize_DD250
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

CURSOR DeliveryInfo ( C_Form_Header_ID  NUMBER ) IS
  SELECT wd.name
  ,      o.name
  FROM   oke_k_form_headers kfh
  ,      wsh_deliveries wd
  ,      hr_all_organization_units_tl o
  WHERE  kfh.form_header_id = C_Form_Header_ID
  AND    wd.delivery_id = kfh.reference1
  AND    o.organization_id = wd.organization_id
  AND    o.language = userenv('LANG');

ContractNum  VARCHAR2(240) := NULL;
OrderNum     VARCHAR2(240) := NULL;
ShipmentNum  VARCHAR2(240) := NULL;
Requestor    VARCHAR2(30)  := NULL;
FormHeaderID NUMBER        := NULL;
DeliveryName VARCHAR2(30)  := NULL;
ShipFromOrg  VARCHAR2(240) := NULL;

BEGIN
  --
  -- Contract Number is stored in Parameter 1
  --
  ContractNum := WF_ENGINE.GetItemAttrText
                 ( ItemType => ItemType
                 , ItemKey  => ItemKey
                 , AName    => 'ECX_PARAMETER1' );

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'CONTRACT_NUM'
  , AValue   => ContractNum );

  --
  -- Order Number, if any, is stored in Parameter 2
  --
  OrderNum := WF_ENGINE.GetItemAttrText
              ( ItemType => ItemType
              , ItemKey  => ItemKey
              , AName    => 'ECX_PARAMETER2' );

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'ORDER_NUM'
  , AValue   => OrderNum );

  --
  -- Shipment Number is stored in Parameter 3
  --
  ShipmentNum := WF_ENGINE.GetItemAttrText
                 ( ItemType => ItemType
                 , ItemKey  => ItemKey
                 , AName    => 'ECX_PARAMETER3' );

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'SHIPMENT_NUM'
  , AValue   => ShipmentNum );

  --
  -- Requestor is stored in Parameter 3
  --
  Requestor := WF_ENGINE.GetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName    => 'ECX_PARAMETER5' );

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'REQUESTOR'
  , AValue   => Requestor );

  --
  -- Finally, get Shipping information from the reference column in
  -- OKE_K_FORM_HEADERS
  --
  FormHeaderID := WF_ENGINE.GetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'ECX_DOCUMENT_ID' );

  OPEN DeliveryInfo ( FormHeaderID );
  FETCH DeliveryInfo INTO DeliveryName , ShipFromOrg;
  CLOSE DeliveryInfo;

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'DELIVERY_NAME'
  , AValue   => DeliveryName );

  WF_ENGINE.SetItemAttrText
  ( ItemType => ItemType
  , ItemKey  => ItemKey
  , AName    => 'SHIP_FROM_ORG'
  , AValue   => ShipFromOrg );


END Initialize_DD250;


--
-- Public Procedures
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

OutputMimeType VARCHAR2(240);


BEGIN

  OutputMimeType  := 'application/vnd.milpac.fex';

  IF ( FuncMode = 'RUN' ) THEN
    --
    -- Getting the event name from the Workflow attribute
    --
    GetEventName( ItemType , ItemKey );

    --
    -- The URL should be generic for all types of documents.
    -- Perform this action before form specific initializations
    -- so it is possible to override the result on a form-by-form
    -- basis.
    --

    XmlUrl := wf_oam_util.getviewXMLURL('ECX_EVENT_MESSAGE',ItemType,ItemKey,OutputMimeType);

    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'DOCUMENT_URL'
    , AValue   => XmlUrl
    );

    IF ( EventName = 'oracle.apps.oke.forms.DD250.Generate' ) THEN

      Initialize_DD250( ItemType , ItemKey );

    END IF;

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_Core.Context
            ( 'OKE_MILPAC_INTG_WF'
            , 'INITIALIZE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;

END Initialize;


PROCEDURE Create_Attachment
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

RowID               VARCHAR2(80);
DocumentID          NUMBER;
MediaID             NUMBER;
SeqNum              NUMBER;
FileName            VARCHAR2(2000);
FormHeaderID        NUMBER;
FormCreationDate    DATE;
CategoryID          NUMBER;
AttachmentDesc      VARCHAR2(240);

CURSOR f IS
  SELECT form_header_number
  ,      print_form_code
  ,      k_header_id
  ,      fnd_attached_documents_s.nextval attached_document_id
  FROM oke_k_form_headers
  WHERE form_header_id = FormHeaderID;
frec f%rowtype;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    IF ( WF_ENGINE.GetItemAttrNumber
         ( ItemType => ItemType
         , ItemKey  => ItemKey
         , AName    => 'ATTACHED_DOCUMENT_ID' ) IS NOT NULL ) THEN
      ResultOut := 'COMPLETE:';
      RETURN;
    END IF;

    FormHeaderID := WF_ENGINE.GetItemAttrText
                    ( ItemType => ItemType
                    , ItemKey  => ItemKey
                    , AName    => 'ECX_DOCUMENT_ID' );

    FormCreationDate := to_date( WF_ENGINE.GetItemAttrText
                                 ( ItemType => ItemType
                                 , ItemKey  => ItemKey
                                 , AName    => 'ECX_PARAMETER4' )
                               , 'DDMONRRHH24MISS' );

    FileName := WF_ENGINE.GetItemAttrText
                ( ItemType => ItemType
                , ItemKey  => ItemKey
                , AName    => 'DOCUMENT_URL' );

    OPEN f;
    FETCH f INTO frec;
    CLOSE f;

    SELECT nvl(max(seq_num) , 0) + 1
    INTO   SeqNum
    FROM   fnd_attached_documents
    WHERE  entity_name = 'OKE_K_FORM_HEADERS'
    AND    pk1_value = frec.print_form_code
    AND    pk2_value = to_char(frec.k_header_id)
    AND    pk3_value is null;

    --
    -- Hardcoded to Miscellaneous for now
    --
    CategoryID := 1;

    fnd_message.set_name('OKE' , 'OKE_MILPAC_OUTPUT_DESC');
    fnd_message.set_token('FORM' , frec.form_header_number);
    fnd_message.set_token('DATE' , FND_DATE.date_to_displaydt( FormCreationDate ) );
    AttachmentDesc := fnd_message.get;

    fnd_attached_documents_pkg.insert_row
    ( X_ROWID                        => RowID
    , X_ATTACHED_DOCUMENT_ID         => frec.attached_document_id
    , X_DOCUMENT_ID                  => DocumentID
    , X_CREATION_DATE                => sysdate
    , X_CREATED_BY                   => fnd_global.user_id
    , X_LAST_UPDATE_DATE             => sysdate
    , X_LAST_UPDATED_BY              => fnd_global.user_id
    , X_LAST_UPDATE_LOGIN            => fnd_global.login_id
    , X_SEQ_NUM                      => SeqNum
    , X_ENTITY_NAME                  => 'OKE_K_FORM_HEADERS'
    , X_COLUMN1                      => NULL
    , X_PK1_VALUE                    => frec.print_form_code
    , X_PK2_VALUE                    => frec.k_header_id
    , X_PK3_VALUE                    => NULL
    , X_PK4_VALUE                    => NULL
    , X_PK5_VALUE                    => NULL
    , X_AUTOMATICALLY_ADDED_FLAG     => 'Y'
    , X_DATATYPE_ID                  => 5
    , X_CATEGORY_ID                  => 1
    , X_SECURITY_TYPE                => 4
    , X_PUBLISH_FLAG                 => 'Y'
    , X_USAGE_TYPE                   => 'O'
    , X_LANGUAGE                     => userenv('LANG')
    , X_DESCRIPTION                  => AttachmentDesc
    , X_FILE_NAME                    => FileName
    , X_MEDIA_ID                     => MediaID
    , X_CREATE_DOC                   => 'Y'
    );

    WF_ENGINE.SetItemAttrNumber
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'ATTACHED_DOCUMENT_ID'
    , AValue   => frec.attached_document_id
    );

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_Core.Context
            ( 'OKE_MILPAC_INTG_WF'
            , 'CREATE_ATTACHMENT'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;

END Create_Attachment;

END OKE_MILPAC_INTG_WF;

/
