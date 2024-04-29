--------------------------------------------------------
--  DDL for Package Body OE_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_SECURITY" AS
/* $Header: OEXXHDRB.pls 120.1.12010000.2 2009/02/11 09:24:57 haagarwa ship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Security';

-- LOCAL PROCEDURES


FUNCTION Is_Op_Constrained
( p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record       IN OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER IS
l_constraint_id	NUMBER;
l_grp	NUMBER;
l_result		NUMBER;
l_column_name	VARCHAR2(30);
l_audit_trail_enabled VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');
l_code_level varchar2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

-- Variables for Integration Event Code
  l_party_id            Number;
  l_party_site_id       Number;
  l_is_delivery_reqd    Varchar2(1);
  l_return_status       Varchar2(30);
  l_gen_xml             Varchar2(1) := 'P';
--
BEGIN

l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
    ( p_responsibility_id     => nvl(fnd_global.resp_id, -1)
    , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
    , p_operation   => p_operation
    , p_qualifier_attribute => p_record.transaction_phase_code
    , p_entity_id   => OE_PC_GLOBALS.G_ENTITY_HEADER
    , p_column_name => p_column_name
    , p_check_all_cols_constraint  => g_check_all_cols_constraint
    , p_is_caller_defaulting  => g_is_caller_defaulting
    , x_constraint_id    => l_constraint_id
    , x_constraining_conditions_grp     => l_grp
    , x_on_operation_action   => x_on_operation_action
    );

if l_result = OE_PC_GLOBALS.YES then

    IF g_check_all_cols_constraint = 'Y'
       AND (p_operation = OE_PC_GLOBALS.UPDATE_OP
            OR p_operation = OE_PC_GLOBALS.CREATE_OP)
       AND x_on_operation_action = 0
       AND p_column_name IS NOT NULL THEN
           SELECT column_name
           INTO l_column_name
           FROM oe_pc_constraints
           WHERE constraint_id = l_constraint_id;
           if l_column_name is null then
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('There is an UPDATE constraint on all columns - Error',1);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           end if;
    END IF;

elsif l_result = OE_PC_GLOBALS.ERROR then

    raise FND_API.G_EXC_UNEXPECTED_ERROR;

end if;

g_check_all_cols_constraint := 'N';

/* Start Versioning */
IF l_code_level >= '110510' AND
  ( p_column_name = 'TRANSACTION_PHASE_CODE' OR
    x_on_operation_action IN (.1,.2))THEN
   OE_Versioning_Util.Check_Security(p_column_name => p_column_name,
                   p_on_operation_action => x_on_operation_action);
END IF;
/* End Versioning */


--Start Integration Framework Code

  If l_code_level          >= '110510'          And
     l_result              = OE_PC_GLOBALS.YES  And
     x_on_operation_action = 3                  And
     nvl(p_record.transaction_phase_code,'F') = 'F'
  Then

   If p_record.order_source_id = 20 Then
    OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => p_record.sold_to_org_id,
                         p_transaction_type     => OE_Acknowledgment_Pub.G_TRANSACTION_TYPE,
                         p_transaction_subtype  => OE_Acknowledgment_Pub.G_TRANSACTION_SSO,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
    If l_return_status    = FND_API.G_RET_STS_SUCCESS And
       l_is_delivery_reqd = 'Y'
    Then
      l_gen_xml := 'B';
    End If;
   End If;
        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.header_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_HEADER,
            p_requesting_entity_id          => p_record.header_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_HDR,
            p_request_unique_key1           => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param1                        => p_record.header_id,
            p_param2                        => p_record.order_source_id,
            p_param3                        => p_record.orig_sys_document_ref,
            p_param4                        => p_record.sold_to_org_id,
            p_param5                        => Null,
            p_param6                        => p_record.org_id,
            p_param7                        => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param8                        => Null,
            p_param9                        => p_record.sold_to_org_id,
            p_param10                       => l_party_site_id,
            p_param11                       => Null,
            p_param12                       => l_gen_xml,
            x_return_status                 => l_return_status);

  End If;

  If l_code_level          >= '110510'          And
     l_result              = OE_PC_GLOBALS.YES  And
     x_on_operation_action = 0.05               And
     nvl(p_record.transaction_phase_code,'F') = 'F'
  Then

    OE_Versioning_Util.Check_Security
      (p_column_name          => p_column_name,
       p_on_operation_action  => .1);

    If p_record.order_source_id = 20 Then
      OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => p_record.sold_to_org_id,
                         p_transaction_type     => OE_Acknowledgment_Pub.G_TRANSACTION_TYPE,
                         p_transaction_subtype  => OE_Acknowledgment_Pub.G_TRANSACTION_SSO,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
      If l_return_status      = FND_API.G_RET_STS_SUCCESS And
         l_is_delivery_reqd   = 'Y'
      Then
        l_gen_xml := 'B';
      End If;
    End If;
        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.header_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_HEADER,
            p_requesting_entity_id          => p_record.header_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_HDR,
            p_request_unique_key1           => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param1                        => p_record.header_id,
            p_param2                        => p_record.order_source_id,
            p_param3                        => p_record.orig_sys_document_ref,
            p_param4                        => p_record.sold_to_org_id,
            p_param5                        => Null,
            p_param6                        => p_record.org_id,
            p_param7                        => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param8                        => Null,
            p_param9                        => p_record.sold_to_org_id,
            p_param10                       => l_party_site_id,
            p_param11                       => Null,
            p_param12                       => l_gen_xml,
            x_return_status                 => l_return_status);

  End If;

  If l_code_level >= '110510'          And
     l_result = OE_PC_GLOBALS.YES      And
     x_on_operation_action = 0.5       And
     nvl(p_record.transaction_phase_code,'F') = 'F'
  Then
    If g_is_caller_defaulting = 'N'    And
       nvl(l_audit_trail_enabled,'D') <> 'D' And
       not OE_GLOBALS.G_HEADER_CREATED
    Then
      If l_audit_trail_enabled = 'B' Then
        If p_record.booked_flag = 'Y' Then
          OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
        End If;
      Else
        OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
        OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
      End IF;
    End If;

    If p_record.order_source_id = 20 Then
      OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => p_record.sold_to_org_id,
                         p_transaction_type     => OE_Acknowledgment_Pub.G_TRANSACTION_TYPE,
                         p_transaction_subtype  => OE_Acknowledgment_Pub.G_TRANSACTION_SSO,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
      If l_return_status    = FND_API.G_RET_STS_SUCCESS And
         l_is_delivery_reqd = 'Y'
      Then
        l_gen_xml := 'B';
      End If;
    End If;

        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.header_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_HEADER,
            p_requesting_entity_id          => p_record.header_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_HDR,
            p_request_unique_key1           => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param1                        => p_record.header_id,
            p_param2                        => p_record.order_source_id,
            p_param3                        => p_record.orig_sys_document_ref,
            p_param4                        => p_record.sold_to_org_id,
            p_param5                        => Null,
            p_param6                        => p_record.org_id,
            p_param7                        => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param8                        => Null,
            p_param9                        => p_record.sold_to_org_id,
            p_param10                       => l_party_site_id,
            p_param11                       => Null,
            p_param12                       => l_gen_xml,
            x_return_status                 => l_return_status);

  End If;

--End Integration Event Code


/* Start AuditTrail */
IF g_is_caller_defaulting = 'N' THEN
   IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' and
      nvl(p_record.transaction_phase_code,'F') = 'F' and
      not OE_GLOBALS.G_HEADER_CREATED THEN
      IF l_audit_trail_enabled = 'B' THEN  -- capture only for booked orders
         IF p_record.booked_flag = 'Y' THEN
            IF l_result = OE_PC_GLOBALS.YES THEN
               IF x_on_operation_action = 1 THEN
                  -- set OUT result to NOT CONSTRAINED
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
                  END IF;
                  OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                  OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
               ELSIF x_on_operation_action = 2 THEN
                  -- set OUT result to NOT CONSTRAINED
                  IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
                     END IF;
	             OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSE -- capture audit trail for all orders
         IF l_result = OE_PC_GLOBALS.YES THEN
            IF x_on_operation_action = 1 THEN
               -- set OUT result to NOT CONSTRAINED
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES REASON' , 1 ) ;
               END IF;
               OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
               OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
            ELSIF x_on_operation_action = 2 THEN
               -- set OUT result to NOT CONSTRAINED
               IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'HEADER SECURITY , ATTRIBUTE CHANGE REQUIRES HISTORY' , 1 ) ;
                  END IF;
	          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;
END IF;


IF x_on_operation_action > 0 THEN
   l_result := OE_PC_GLOBALS.NO;
END IF;
/* End AuditTrail */
RETURN l_result;

END Is_Op_Constrained;


-- PUBLIC PROCEDURES


FUNCTION ACCOUNTING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ACCOUNTING_RULE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ACCOUNTING_RULE;

FUNCTION ACCOUNTING_RULE_DURATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ACCOUNTING_RULE_DURATION'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ACCOUNTING_RULE_DURATION;


 -- Start of fix #1459428  for function definition

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE1'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE1;

FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE10'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE10;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE11'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE11;


FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE12'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE12;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE13'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE13;


FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE14'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE14;

FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE15'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE15;

-- For bug 2184255
FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE16'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE16;


FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE17'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE17;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE18'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE18;


FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE19'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE19;


FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE2'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE2;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE20'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE20;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE3'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE3;


FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE4'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE4;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE5'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE5;


FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE6'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE6;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE7'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE7;


FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE8'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE8;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'ATTRIBUTE9'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END ATTRIBUTE9;

FUNCTION CANCELLED
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> OE_PC_GLOBALS.CANCEL_OP
    ,p_column_name	=> null
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CANCELLED;

FUNCTION AGREEMENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'AGREEMENT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END AGREEMENT;

FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CONTEXT'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CONTEXT;

-- End  of fix #1459428  for function definition

FUNCTION CONVERSION_RATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CONVERSION_RATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CONVERSION_RATE;


FUNCTION CONVERSION_RATE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CONVERSION_RATE_DATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CONVERSION_RATE_DATE;

FUNCTION CUSTOMER_PREFERENCE_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CUSTOMER_PREFERENCE_SET_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CUSTOMER_PREFERENCE_SET;

FUNCTION CONVERSION_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CONVERSION_TYPE_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CONVERSION_TYPE;


FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CREATED_BY'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CREATED_BY;


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CUST_PO_NUMBER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CUST_PO_NUMBER;


FUNCTION DELIVER_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'DELIVER_TO_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END DELIVER_TO_CONTACT;

FUNCTION IB_OWNER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'IB_OWNER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END IB_OWNER;

FUNCTION IB_INSTALLED_AT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'IB_INSTALLED_AT_LOCATION'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END IB_INSTALLED_AT_LOCATION;

FUNCTION IB_CURRENT_LOCATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'IB_CURRENT_LOCATION'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END IB_CURRENT_LOCATION;

FUNCTION END_CUSTOMER_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'END_CUSTOMER_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END END_CUSTOMER_CONTACT;


FUNCTION END_CUSTOMER_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'END_CUSTOMER_SITE_USE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END END_CUSTOMER_SITE_USE;


FUNCTION END_CUSTOMER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'END_CUSTOMER_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END END_CUSTOMER;


FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'DELIVER_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END DELIVER_TO_ORG;


FUNCTION DEMAND_CLASS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'DEMAND_CLASS_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END DEMAND_CLASS;

FUNCTION EARLIEST_SCHEDULE_LIMIT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'EARLIEST_SCHEDULE_LIMIT'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END EARLIEST_SCHEDULE_LIMIT;

FUNCTION FOB_POINT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'FOB_POINT_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END FOB_POINT;


FUNCTION FREIGHT_CARRIER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'FREIGHT_CARRIER_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END FREIGHT_CARRIER;


FUNCTION FREIGHT_TERMS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'FREIGHT_TERMS_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END FREIGHT_TERMS;

FUNCTION INVOICE_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'INVOICE_TO_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END INVOICE_TO_CONTACT;

FUNCTION INVOICE_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'INVOICE_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END INVOICE_TO_ORG;

FUNCTION INVOICING_RULE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'INVOICING_RULE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END INVOICING_RULE;

FUNCTION LATEST_SCHEDULE_LIMIT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'LATEST_SCHEDULE_LIMIT'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END LATEST_SCHEDULE_LIMIT;


FUNCTION ORDERED_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDERED_DATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDERED_DATE;


FUNCTION ORDER_DATE_TYPE_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_DATE_TYPE_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_DATE_TYPE_CODE;

FUNCTION ORDER_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_NUMBER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_NUMBER;


FUNCTION ORDER_SOURCE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_SOURCE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_SOURCE;


FUNCTION ORDER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORDER_TYPE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORDER_TYPE;



FUNCTION ORIG_SYS_DOCUMENT_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'ORIG_SYS_DOCUMENT_REF'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END ORIG_SYS_DOCUMENT_REF;

FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PACKING_INSTRUCTIONS'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PACKING_INSTRUCTIONS;


FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PAYMENT_TERM_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PAYMENT_TERM;


FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PRICE_LIST_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PRICE_LIST;


FUNCTION PRICING_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'PRICING_DATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END PRICING_DATE;

FUNCTION REQUEST_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'REQUEST_DATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END REQUEST_DATE;


FUNCTION RETURN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'RETURN_REASON_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END RETURN_REASON;


FUNCTION SALESREP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SALESREP_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SALESREP;


FUNCTION SHIPMENT_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIPMENT_PRIORITY_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIPMENT_PRIORITY;

FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIPPING_INSTRUCTIONS'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_INSTRUCTIONS;

FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIPPING_METHOD_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_METHOD;

FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_FROM_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_FROM_ORG;


FUNCTION SHIP_TOLERANCE_ABOVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_TOLERANCE_ABOVE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_TOLERANCE_ABOVE;


FUNCTION SHIP_TOLERANCE_BELOW
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_TOLERANCE_BELOW'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_TOLERANCE_BELOW;


FUNCTION SHIP_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_TO_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_TO_CONTACT;


FUNCTION SHIP_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SHIP_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SHIP_TO_ORG;


FUNCTION SOLD_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SOLD_TO_CONTACT_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SOLD_TO_CONTACT;


FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SOLD_TO_ORG_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SOLD_TO_ORG;


FUNCTION SOURCE_DOCUMENT_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'SOURCE_DOCUMENT_TYPE_ID'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END SOURCE_DOCUMENT_TYPE;


FUNCTION TAX_EXEMPT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'TAX_EXEMPT_FLAG'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END TAX_EXEMPT;


FUNCTION TAX_EXEMPT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'TAX_EXEMPT_NUMBER'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END TAX_EXEMPT_NUMBER;


FUNCTION TAX_EXEMPT_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'TAX_EXEMPT_REASON_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END TAX_EXEMPT_REASON;



FUNCTION TRANSACTIONAL_CURR
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'TRANSACTIONAL_CURR_CODE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END TRANSACTIONAL_CURR;


FUNCTION CREDIT_CARD_APPROVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation	=> p_operation
    ,p_column_name	=> 'CREDIT_CARD_APPROVAL_DATE'
    ,p_record	=> p_record
    ,x_on_operation_action	=> x_on_operation_action
    );

RETURN(l_result);

END CREDIT_CARD_APPROVAL_DATE;

     /* The following Function is added to fix the issue #1651331 to enable
	   the Sales Channel Field be allowed to set the security rules  */

FUNCTION SALES_CHANNEL_CODE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

l_result := Is_OP_constrained
      (p_operation    => p_operation
      ,p_column_name  => 'SALES_CHANNEL_CODE'
	 ,p_record  => p_record
	 ,x_on_operation_action    => x_on_operation_action
	 );

RETURN(l_result);

END SALES_CHANNEL_CODE;

/* START PREPAYMENT */
FUNCTION PAYMENT_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'PAYMENT_TYPE_CODE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END PAYMENT_TYPE;

FUNCTION CREDIT_CARD_HOLDER_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CREDIT_CARD_HOLDER_NAME'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CREDIT_CARD_HOLDER_NAME;

FUNCTION CREDIT_CARD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CREDIT_CARD_CODE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CREDIT_CARD;

FUNCTION CREDIT_CARD_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CREDIT_CARD_NUMBER'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CREDIT_CARD_NUMBER;

FUNCTION CREDIT_CARD_EXPIRATION_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CREDIT_CARD_EXPIRATION_DATE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CREDIT_CARD_EXPIRATION_DATE;
/* END PREPAYMENT */

/* For bug 2395032 */

FUNCTION PAYMENT_AMOUNT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'PAYMENT_AMOUNT'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END PAYMENT_AMOUNT;

FUNCTION CHECK_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'CHECK_NUMBER'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END CHECK_NUMBER;

/* End 2395032 */

FUNCTION BLANKET_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'BLANKET_NUMBER'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END BLANKET_NUMBER;

-- QUOTING changes

FUNCTION QUOTE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'QUOTE_NUMBER'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END QUOTE_NUMBER;

FUNCTION QUOTE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'QUOTE_DATE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END QUOTE_DATE;

FUNCTION SALES_DOCUMENT_NAME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'SALES_DOCUMENT_NAME'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END SALES_DOCUMENT_NAME;

FUNCTION TRANSACTION_PHASE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'TRANSACTION_PHASE_CODE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END TRANSACTION_PHASE;

FUNCTION USER_STATUS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'USER_STATUS'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END USER_STATUS;

FUNCTION EXPIRATION_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'EXPIRATION_DATE'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END EXPIRATION_DATE;

FUNCTION VERSION_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
    ,p_column_name      => 'VERSION_NUMBER'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END VERSION_NUMBER;

FUNCTION SOLD_TO_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_on_operation_action OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation        => p_operation
     -- Bug 3378203 -
     -- Correct the column name
    ,p_column_name      => 'SOLD_TO_SITE_USE_ID'
    ,p_record   => p_record
    ,x_on_operation_action      => x_on_operation_action
    );

RETURN(l_result);

END SOLD_TO_SITE_USE;

-- Quoting Changes END

-- Comment Label for procedure added as part of Inline Documentation Drive.
---------------------------------------------------------------------------------
-- Procedure Name : DEFAULT_FULFILLMENT_SET
-- Input Params   : p_operation          : Operation being performed.
--                  p_record             : Record being processed.
-- Output Params  : x_on_operation_action: operation action output.
-- Description    : This checks if there are any constraints setup on the
--                  attribute DEFAULT_FULFILLMENT_SET field on Order Header.
--                  This Function invokes the Processing Constraint Framework
--                  for this particular attribute, like all others.
--                  Without such a function in place, the Processing Constraint
--                  won't fire even if a setup exists.
--                  This code is called only from the Attributes procedure in
--                  this package if the value of the Default Fulfillment Set
--                  field has changed.
---------------------------------------------------------------------------------

-- Bug 8217769 New Function added for Default Fulfillment Set
FUNCTION DEFAULT_FULFILLMENT_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   x_on_operation_action          OUT  NOCOPY NUMBER
) RETURN NUMBER
IS
l_result      NUMBER;
BEGIN
l_result := Is_OP_constrained
    (p_operation      => p_operation
    ,p_column_name    => 'DEFAULT_FULFILLMENT_SET'
    ,p_record => p_record
    ,x_on_operation_action    => x_on_operation_action
    );
RETURN(l_result);
END DEFAULT_FULFILLMENT_SET;
-- Bug 8217769 Function ends.

PROCEDURE Entity
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action	NUMBER;
l_rowtype_rec	OE_AK_ORDER_HEADERS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_HEADER_SECURITY.ENTITY' , 1 ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    l_operation := OE_PC_GLOBALS.CREATE_OP;
ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
    l_operation := OE_PC_GLOBALS.DELETE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_HEADER_UTIL.API_Rec_To_Rowtype_Rec(p_HEADER_rec, l_rowtype_rec);

-- Initialize security global record
OE_Header_SECURITY.g_record := l_rowtype_rec;

x_result := Is_OP_constrained
    (p_operation	=> l_operation
    ,p_record	=> l_rowtype_rec
    ,x_on_operation_action	=> l_on_operation_action
    );

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_HEADER_SECURITY.ENTITY' , 1 ) ;
END IF;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Entity'
        );
    END IF;

END Entity;

-- Comment Label for procedure added as part of Inline Documentation Drive.
-------------------------------------------------------------------------------------
-- Procedure Name : Attributes
-- Input Params   : p_HEADER_rec         : New/changed Header Record.
--                  p_old_HEADER_rec     : Old Header Record.
-- Output Params  : x_result             : Result out for Attribute Security check.
--                  x_return_status      : Return Status from this Procedure.
-- Description    : This procedure check the Processing Constraints for the various
--                  attributes of the Header Entity, during any operation invoked
--                  for Order Header Entity. If Attribute Security Check is passed,
--                  only then the operation progresses, else if it is constrained,
--                  for any attribute, an Error is raised with appropriate message.
--                  This code calls the various Functions, created for various
--                  attributes of Header Entity, if the value for an attribute has
--                  changed.
--                  This code is called as part of the Process Order Call, whenever
--                  there is any operation on the Header Entity.
-------------------------------------------------------------------------------------

PROCEDURE Attributes
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   p_old_HEADER_rec                IN  OE_Order_PUB.HEADER_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC
, x_result OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

) IS
l_operation	VARCHAR2(1);
l_on_operation_action  NUMBER;
l_result		NUMBER;
l_rowtype_rec	OE_AK_ORDER_HEADERS_V%ROWTYPE;
l_column_name	VARCHAR2(30);
l_active_flag   VARCHAR2(1);
e_inacitve_pl   EXCEPTION;
l_check_all_cols_constraint VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_HEADER_SECURITY.ATTRIBUTES' , 1 ) ;
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initializing out result to NOT CONSTRAINED
x_result := OE_PC_GLOBALS.NO;

 -- Get the operation code to be passed to the security framework API
IF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
    -- Bug 1987983 : if the order source is Copy then skip the Attribute
    -- level check
   IF p_HEADER_rec.source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_COPY
      THEN
      RETURN;
   ELSE
    l_operation := OE_PC_GLOBALS.CREATE_OP;
   END IF;
    -- Bug 1755817: if there are no attribute-specific insert
    -- constraints, then no need to go further. Entity level
    -- security check for CREATE will be called again from
    -- process order after defaulting.
    IF NOT OE_PC_Constraints_Admin_PVT.Check_On_Insert_Exists
           (p_entity_id   => OE_PC_GLOBALS.G_ENTITY_HEADER
           ,p_responsibility_id     => nvl(fnd_global.resp_id, -1)
           ,p_application_id        => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
           )
    THEN
       RETURN;
    END IF;

ELSIF p_HEADER_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID OPERATION' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_HEADER_UTIL.API_Rec_To_Rowtype_Rec(p_HEADER_rec, l_rowtype_rec);

-- Initialize security global record
OE_Header_SECURITY.g_record := l_rowtype_rec;

-- Compare the new and old entity records and
-- check constraints for all the changed attributes.

   IF p_header_rec.cancelled_flag <> FND_API.G_MISS_CHAR
     AND NOT OE_GLOBALS.Equal(p_header_rec.cancelled_flag,
		 p_old_header_rec.cancelled_flag)
            THEN
		IF p_header_rec.cancelled_flag = 'Y' THEN
        l_result := CANCELLED
            (p_operation => l_operation
            ,p_record    => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
             x_result := OE_PC_GLOBALS.YES;
		   --RAISE;
        END IF;
	     END IF;

    END IF;

    IF ((p_header_rec.price_list_id IS NOT NULL)
      AND (NOT oe_globals.equal(p_header_rec.price_list_id,
      p_old_HEADER_rec.price_list_id))
      AND (p_header_rec.order_category_code IS NOT NULL)
      AND (p_header_rec.order_category_code <>
                 Oe_Globals.G_RETURN_CATEGORY_CODE)) THEN
      BEGIN
        SELECT active_flag
        INTO l_active_flag
        FROM qp_List_headers_vl
        WHERE list_header_id = p_header_rec.price_list_id;
        IF(nvl(l_active_flag,'N')='N') THEN
          RAISE e_inacitve_pl;
        END IF;
      EXCEPTION
        WHEN e_inacitve_pl  THEN
          RAISE e_inacitve_pl ;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'WHEN OTHERS' , 2 ) ;
          END IF;
      END;
    END IF;

    IF p_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.accounting_rule_id,p_old_header_rec.accounting_rule_id) THEN

        l_result := ACCOUNTING_RULE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

   IF p_header_rec.IB_OWNER = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.IB_OWNER,p_old_header_rec.IB_OWNER) THEN

        l_result := IB_OWNER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
   IF p_header_rec.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.IB_INSTALLED_AT_LOCATION,p_old_header_rec.IB_INSTALLED_AT_LOCATION) THEN

        l_result := IB_INSTALLED_AT_LOCATION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
   IF p_header_rec.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.IB_CURRENT_LOCATION,p_old_header_rec.IB_CURRENT_LOCATION) THEN

        l_result := IB_CURRENT_LOCATION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
  IF p_header_rec.END_CUSTOMER_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.END_CUSTOMER_ID,p_old_header_rec.END_CUSTOMER_ID) THEN

        l_result := END_CUSTOMER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
  IF p_header_rec.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.END_CUSTOMER_SITE_USE_ID,p_old_header_rec.END_CUSTOMER_SITE_USE_ID) THEN

        l_result := END_CUSTOMER_SITE_USE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
  IF p_header_rec.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.END_CUSTOMER_CONTACT_ID,p_old_header_rec.END_CUSTOMER_CONTACT_ID) THEN

        l_result := END_CUSTOMER_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.accounting_rule_duration,p_old_header_rec.accounting_rule_duration) THEN

        l_result := ACCOUNTING_RULE_DURATION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.agreement_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.agreement_id,p_old_header_rec.agreement_id) THEN

        l_result := AGREEMENT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.conversion_rate = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.conversion_rate,p_old_header_rec.conversion_rate) THEN

        l_result := CONVERSION_RATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.conversion_rate_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.conversion_rate_date,p_old_header_rec.conversion_rate_date) THEN

        l_result := CONVERSION_RATE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.conversion_type_code,p_old_header_rec.conversion_type_code) THEN

        l_result := CONVERSION_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.created_by = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.created_by,p_old_header_rec.created_by) THEN

        l_result := CREATED_BY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.cust_po_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.cust_po_number,p_old_header_rec.cust_po_number) THEN

        l_result := CUST_PO_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_contact_id,p_old_header_rec.deliver_to_contact_id) THEN

        l_result := DELIVER_TO_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id,p_old_header_rec.deliver_to_org_id) THEN

        l_result := DELIVER_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.demand_class_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.demand_class_code,p_old_header_rec.demand_class_code) THEN

        l_result := DEMAND_CLASS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.earliest_schedule_limit = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.earliest_schedule_limit,p_old_header_rec.earliest_schedule_limit) THEN

        l_result := EARLIEST_SCHEDULE_LIMIT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.fob_point_code,p_old_header_rec.fob_point_code) THEN

        l_result := FOB_POINT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.freight_terms_code,p_old_header_rec.freight_terms_code) THEN

        l_result := FREIGHT_TERMS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_contact_id,p_old_header_rec.invoice_to_contact_id) THEN

        l_result := INVOICE_TO_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id,p_old_header_rec.invoice_to_org_id) THEN

        l_result := INVOICE_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.invoicing_rule_id,p_old_header_rec.invoicing_rule_id) THEN

        l_result := INVOICING_RULE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.latest_schedule_limit = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.latest_schedule_limit,p_old_header_rec.latest_schedule_limit) THEN

        l_result := LATEST_SCHEDULE_LIMIT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ordered_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ordered_date,p_old_header_rec.ordered_date) THEN

        l_result := ORDERED_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.order_date_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.order_date_type_code,p_old_header_rec.order_date_type_code) THEN

        l_result := ORDER_DATE_TYPE_CODE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.order_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.order_number,p_old_header_rec.order_number) THEN

        l_result := ORDER_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.order_type_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.order_type_id,p_old_header_rec.order_type_id) THEN

        l_result := ORDER_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.packing_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.packing_instructions,p_old_header_rec.packing_instructions) THEN

        l_result := PACKING_INSTRUCTIONS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.payment_term_id,p_old_header_rec.payment_term_id) THEN

        l_result := PAYMENT_TERM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.price_list_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.price_list_id,p_old_header_rec.price_list_id) THEN

        l_result := PRICE_LIST
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.pricing_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.pricing_date,p_old_header_rec.pricing_date) THEN

        l_result := PRICING_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.request_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.request_date,p_old_header_rec.request_date) THEN

        l_result := REQUEST_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.return_reason_code,p_old_header_rec.return_reason_code) THEN

        l_result := RETURN_REASON
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.salesrep_id,p_old_header_rec.salesrep_id) THEN

        l_result := SALESREP
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sales_channel_code,p_old_header_rec.sales_channel_code) THEN

        l_result := SALES_CHANNEL_CODE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

/* START PREPAYMENT */
    IF p_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.payment_type_code, p_old_header_rec.payment_type_code) THEN

        l_result := PAYMENT_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_holder_name, p_old_header_rec.credit_card_holder_name) THEN

        l_result := CREDIT_CARD_HOLDER_NAME
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_code, p_old_header_rec.credit_card_code) THEN

        l_result := CREDIT_CARD
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.credit_card_number = FND_API.G_MISS_CHAR THEN NULL;
    --R12 CC Encryption
    --Since the credit card numbers are encrypted, calling
    --the function same credit card to determine whether the old
    --and new card numbers are equal.
    ELSIF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,
	    p_header_rec.credit_card_number,
	    p_old_header_rec.cc_instrument_id,
	    p_header_rec.cc_instrument_id) THEN
        l_result := CREDIT_CARD_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_expiration_date, p_old_header_rec.credit_card_expiration_date) THEN

        l_result := CREDIT_CARD_EXPIRATION_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );
        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
/* END PREPAYMENT */

    IF p_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.shipment_priority_code,p_old_header_rec.shipment_priority_code) THEN

        l_result := SHIPMENT_PRIORITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.shipping_instructions,p_old_header_rec.shipping_instructions) THEN

        l_result := SHIPPING_INSTRUCTIONS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.shipping_method_code,p_old_header_rec.shipping_method_code) THEN

        l_result := SHIPPING_METHOD
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_from_org_id,p_old_header_rec.ship_from_org_id) THEN

        l_result := SHIP_FROM_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_tolerance_above,p_old_header_rec.ship_tolerance_above) THEN

        l_result := SHIP_TOLERANCE_ABOVE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_tolerance_below,p_old_header_rec.ship_tolerance_below) THEN

        l_result := SHIP_TOLERANCE_BELOW
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_contact_id,p_old_header_rec.ship_to_contact_id) THEN

        l_result := SHIP_TO_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id,p_old_header_rec.ship_to_org_id) THEN

        l_result := SHIP_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_contact_id,p_old_header_rec.sold_to_contact_id) THEN

        l_result := SOLD_TO_CONTACT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id,p_old_header_rec.sold_to_org_id) THEN

        l_result := SOLD_TO_ORG
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.tax_exempt_flag,p_old_header_rec.tax_exempt_flag) THEN

        l_result := TAX_EXEMPT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.tax_exempt_number,p_old_header_rec.tax_exempt_number) THEN

        l_result := TAX_EXEMPT_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.tax_exempt_reason_code,p_old_header_rec.tax_exempt_reason_code) THEN

        l_result := TAX_EXEMPT_REASON
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code) THEN

        l_result := TRANSACTIONAL_CURR
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    -- for bug 2395032
    IF p_header_rec.payment_amount = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.payment_amount,p_old_header_rec.payment_amount) THEN

        l_result := PAYMENT_AMOUNT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.check_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.check_number,p_old_header_rec.check_number) THEN

        l_result := CHECK_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
    -- end 2395032

    -- BEGIN: Blankets Code Merge
    IF p_header_rec.blanket_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_number,p_old_header_rec.blanket_number) THEN

        l_result := BLANKET_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
    -- END: Blankets Code Merge

    -- Quoting Changes Start

    IF p_header_rec.quote_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.quote_number,p_old_header_rec.quote_number) THEN

        l_result := QUOTE_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.quote_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.quote_date,p_old_header_rec.quote_date) THEN

        l_result := QUOTE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sales_document_name = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sales_document_name,p_old_header_rec.sales_document_name) THEN

        l_result := SALES_DOCUMENT_NAME
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.transaction_phase_code,p_old_header_rec.transaction_phase_code) THEN

        l_result := TRANSACTION_PHASE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.user_status_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.user_status_code,p_old_header_rec.user_status_code) THEN

        l_result := USER_STATUS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.expiration_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(trunc(p_header_rec.expiration_date),trunc(p_old_header_rec.expiration_date)) THEN

        l_result := EXPIRATION_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.version_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.version_number,p_old_header_rec.version_number) THEN

        l_result := VERSION_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_site_use_id,p_old_header_rec.sold_to_site_use_id) THEN

        l_result := SOLD_TO_SITE_USE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    -- Quoting Changes END

    -- Bug 8217769 New IF added for Default Fulfillment Set
    IF p_header_rec.DEFAULT_FULFILLMENT_SET = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.DEFAULT_FULFILLMENT_SET,p_old_header_rec.DEFAULT_FULFILLMENT_SET) THEN

        l_result := DEFAULT_FULFILLMENT_SET
            (p_operation  => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
    -- Bug 8217769 End IF

    -- BEGIN: CHECK FOR CONSTRAINTS ON DESC FLEXFIELD ATTRIBUTES
    -- Bug 2003823:
    -- If profile indicates that generic update constraints (e.g. seeded
    -- closed order condition) should not be checked for DFF, then
    -- set the global to 'N'.
    -- Also, store the current value of global in a local variable and
    -- re-set it after DFF check. If DFF were the only fields being
    -- updated and profile was set to 'N', global at the end should
    -- be re-set to 'Y' - this indicates to process order that no
    -- constrainable attributes were updated and thus, it would
    -- suppress entity level security check also.
    IF OE_PC_GLOBALS.G_CHECK_UPDATE_ALL_FOR_DFF = 'N' THEN
       l_check_all_cols_constraint := g_check_all_cols_constraint;
       g_check_all_cols_constraint := 'N';
    END IF;

    IF p_header_rec.context = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.context,p_old_header_rec.context) THEN

        l_result := CONTEXT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute1,p_old_header_rec.attribute1) THEN

        l_result := ATTRIBUTE1
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute10,p_old_header_rec.attribute10) THEN

        l_result := ATTRIBUTE10
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute11,p_old_header_rec.attribute11) THEN

        l_result := ATTRIBUTE11
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute12,p_old_header_rec.attribute12) THEN

        l_result := ATTRIBUTE12
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute13,p_old_header_rec.attribute13) THEN

        l_result := ATTRIBUTE13
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute14,p_old_header_rec.attribute14) THEN

        l_result := ATTRIBUTE14
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute15,p_old_header_rec.attribute15) THEN

        l_result := ATTRIBUTE15
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

--For bug 2184255
    IF p_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute16,p_old_header_rec.attribute16) THEN

        l_result := ATTRIBUTE16
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute17,p_old_header_rec.attribute17) THEN

        l_result := ATTRIBUTE17
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute18,p_old_header_rec.attribute18) THEN

        l_result := ATTRIBUTE18
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute19,p_old_header_rec.attribute19) THEN

        l_result := ATTRIBUTE19
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute2,p_old_header_rec.attribute2) THEN

        l_result := ATTRIBUTE2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute20,p_old_header_rec.attribute20) THEN

        l_result := ATTRIBUTE20
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

--End bug 2184255

    IF p_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute3,p_old_header_rec.attribute3) THEN

        l_result := ATTRIBUTE3
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute4,p_old_header_rec.attribute4) THEN

        l_result := ATTRIBUTE4
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute5,p_old_header_rec.attribute5) THEN

        l_result := ATTRIBUTE5
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute6,p_old_header_rec.attribute6) THEN

        l_result := ATTRIBUTE6
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute7,p_old_header_rec.attribute7) THEN

        l_result := ATTRIBUTE7
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute8,p_old_header_rec.attribute8) THEN

        l_result := ATTRIBUTE8
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_header_rec.attribute9,p_old_header_rec.attribute9) THEN

        l_result := ATTRIBUTE9
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF OE_PC_GLOBALS.G_CHECK_UPDATE_ALL_FOR_DFF = 'N' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SETTING CHECK ALL COLS CONSTRAINT TO:'||L_CHECK_ALL_COLS_CONSTRAINT ) ;
       END IF;
       g_check_all_cols_constraint := l_check_all_cols_constraint;
    END IF;

    -- END: CHECK FOR CONSTRAINTS ON DESC FLEXFIELD ATTRIBUTES
    -- NOTE: Please add constraints check for new attributes before the
    -- descriptive flexfield attributes check.

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_HEADER_SECURITY.ATTRIBUTES' , 1 ) ;
END IF;

EXCEPTION
   WHEN e_inacitve_pl THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_INACTIVE_PRICELIST');
      OE_MSG_PUB.ADD;

    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Attributes'
        );
    END IF;

END Attributes;

/*---------------------------------------------------------------
PROCEDURE Copied_From_Quote
----------------------------------------------------------------*/
PROCEDURE Copied_From_Quote
(p_application_id                 IN NUMBER
,p_entity_short_name              IN VARCHAR2
,p_validation_entity_short_name   IN VARCHAR2
,p_validation_tmplt_short_name    IN VARCHAR2
,p_record_set_short_name          IN VARCHAR2
,p_scope                          IN VARCHAR2
,x_result                         OUT NOCOPY NUMBER
)
IS
  l_phase                              VARCHAR2(30);
  l_source_document_id                 NUMBER;
  l_source_document_type_id            NUMBER;
  l_source_document_ver_num            NUMBER;
  CURSOR c_hdr IS
         SELECT nvl(transaction_phase_code,'F')
           FROM OE_ORDER_HEADERS
          WHERE header_id = l_source_document_id
            AND version_number = l_source_document_ver_num;
  CURSOR c_hdr_hist IS
         SELECT nvl(transaction_phase_code,'F')
           FROM OE_ORDER_HEADER_HISTORY
          WHERE header_id = l_source_document_id
            AND version_number = l_source_document_ver_num
            AND version_flag = 'Y';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
     oe_debug_pub.add('Enter Copied_From_Quote');
  end if;

  x_result := 0;

  IF p_validation_entity_short_name = 'HEADER' THEN
     l_source_document_type_id := oe_header_security.g_record.source_document_type_id;
     l_source_document_id := oe_header_security.g_record.source_document_id;
     l_source_document_ver_num :=
                     oe_header_security.g_record.source_document_version_number;
  END IF;

  -- If copied order
  IF l_source_document_type_id = 2 THEN

     OPEN c_hdr;
     FETCH c_hdr INTO l_phase;
        IF c_hdr%NOTFOUND THEN
           OPEN c_hdr_hist;
           FETCH c_hdr_hist INTO l_phase;
           CLOSE c_hdr_hist;
        END IF;
     CLOSE c_hdr;

     IF l_phase = 'N' THEN
        x_result := 1;
     END IF;

  END IF;

  if l_debug_level > 0 then
     oe_debug_pub.add('Exit Copied_From_Quote');
  end if;

EXCEPTION
  WHEN OTHERS THEN
     if l_debug_level > 0 then
        oe_debug_pub.add('Others error :'||substr(sqlerrm,1,200));
     end if;
     x_result := 0;
END Copied_From_Quote;

END OE_Header_Security;

/
