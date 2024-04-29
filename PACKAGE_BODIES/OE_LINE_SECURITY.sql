--------------------------------------------------------
--  DDL for Package Body OE_LINE_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_SECURITY" AS
/* $Header: OEXXLINB.pls 120.12.12010000.4 2009/05/21 08:20:34 nitagarw ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Security';

g_header_id                   NUMBER := FND_API.G_MISS_NUM;

-- LOCAL PROCEDURES

FUNCTION Is_Op_Constrained
( p_operation           IN VARCHAR2
 , p_column_name         IN VARCHAR2 DEFAULT NULL
 , p_record       IN OE_AK_ORDER_LINES_V%ROWTYPE
 , x_on_operation_action	OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER IS
l_constraint_id	        NUMBER;
l_grp	                NUMBER;
l_on_operation_action	NUMBER;
l_result		NUMBER;
l_column_name	        VARCHAR2(30);
l_audit_trail_enabled   VARCHAR2(1) := OE_SYS_PARAMETERS.VALUE('AUDIT_TRAIL_ENABLE_FLAG');
l_code_level            VARCHAR2(6) := OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL;
l_ctr                   NUMBER := OE_GLOBALS.OE_AUDIT_HISTORY_TBL.count;
l_ind                   NUMBER;
l_history_captured      BOOLEAN; -- Is history captured for this line?

-- Variables for Integration Event Code
  l_party_id            Number;
  l_party_site_id       Number;
  l_is_delivery_reqd    Varchar2(1);
  l_return_status       Varchar2(30);
  l_gen_xml             Varchar2(1) := 'P';
--

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Bug 1755817: if line belongs to a different order, then
-- clear the cached results so that the cache is reset for
-- the new order
IF p_record.header_id <> g_header_id THEN
   OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results;
   g_header_id := p_record.header_id;
END IF;

l_result := OE_PC_Constraints_Admin_PVT.Is_OP_constrained
    ( p_responsibility_id	=> nvl(fnd_global.resp_id, -1)
    , p_application_id          => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
    , p_operation	=> p_operation
    , p_qualifier_attribute => p_record.transaction_phase_code
    , p_entity_id	=> OE_PC_GLOBALS.G_ENTITY_LINE
    , p_column_name	=> p_column_name
    , p_check_all_cols_constraint	=> g_check_all_cols_constraint
    , p_is_caller_defaulting	=> g_is_caller_defaulting
    , p_use_cached_results      => 'Y'
    , x_constraint_id	=> l_constraint_id
    , x_constraining_conditions_grp	=> l_grp
    , x_on_operation_action	=> x_on_operation_action
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

IF l_debug_level  > 0 THEN
   OE_DEBUG_PUB.add('Action performed code : '||x_on_operation_action,1);
END IF;

-- Bug 8537214, Reason requirement to be set for operation actions .1,.5 and 1 only

IF l_result = OE_PC_GLOBALS.YES THEN
   IF x_on_operation_action IN (.1,.5,1) THEN
      IF p_column_name = 'ORDERED_QUANTITY'
         -- QUOTING change - set cancellation require reason flag only
         -- for lines in fulfillment phase
         AND nvl(p_record.transaction_phase_code,'F') = 'F'
       THEN
        IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Setting Cancellation Flag to True',1);
        END IF;
         oe_sales_can_util.G_REQUIRE_REASON := TRUE;
      END IF;
   END IF;
END IF;

/* Start Versioning */
IF l_code_level >= '110510' AND
  ( p_column_name = 'TRANSACTION_PHASE_CODE' OR
    x_on_operation_action IN (.1,.2))THEN
   OE_Versioning_Util.Check_Security(p_column_name => p_column_name,
                   p_on_operation_action => x_on_operation_action);
END IF;
/* End Versioning */


--Start Integration Framework Code

  If l_code_level           >= '110510'           And
     l_result               = OE_PC_GLOBALS.YES   And
     x_on_operation_action  = 3                   And
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

        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.line_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id          => p_record.line_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_LN,
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
            x_return_status                 => l_return_status);

  End If;

  If l_code_level >= '110510'          And
     l_result = OE_PC_GLOBALS.YES      And
     x_on_operation_action = 0.05      And
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

      If l_return_status    = FND_API.G_RET_STS_SUCCESS And
         l_is_delivery_reqd = 'Y'
      Then
        l_gen_xml := 'B';
      End IF;
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

        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.line_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id          => p_record.line_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_LN,
            p_request_unique_key1           => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param1                        => p_record.header_id,
            p_param2                        => 20,
            p_param3                        => p_record.orig_sys_document_ref,
            p_param4                        => p_record.sold_to_org_id,
            p_param5                        => Null,
            p_param6                        => p_record.org_id,
            p_param7                        => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param8                        => Null,
            p_param9                        => p_record.sold_to_org_id,
            p_param10                       => l_party_site_id,
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
          l_history_captured := FALSE;
          Begin
            FOR l_ind in 1..l_ctr LOOP
              IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                l_history_captured := TRUE;
              END IF;
            END LOOP;
          EXCEPTION WHEN OTHERS THEN
            NULL;
          END;
          IF NOT l_history_captured THEN
            OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
            OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
            OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
            OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
          END IF;
        End If;
      Else
        l_history_captured := FALSE;
        BEGIN
          FOR l_ind in 1..l_ctr LOOP
            IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
               l_history_captured := TRUE;
            END IF;
          END LOOP;
        EXCEPTION WHEN OTHERS THEN
          NULL;
        END;
        IF NOT l_history_captured THEN
           OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
           OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
           OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
           OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
        END IF;
      End If;
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

        OE_delayed_requests_pvt.log_request
           (p_entity_code                   => OE_GLOBALS.G_ENTITY_HEADER,
            p_entity_id                     => p_record.line_id,
            p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id          => p_record.line_id,
            p_request_type                  => OE_GLOBALS.G_GENERATE_XML_REQ_LN,
            p_request_unique_key1           => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param1                        => p_record.header_id,
            p_param2                        => 20,
            p_param3                        => p_record.orig_sys_document_ref,
            p_param4                        => p_record.sold_to_org_id,
            p_param5                        => Null,
            p_param6                        => p_record.org_id,
            p_param7                        => OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO,
            p_param8                        => Null,
            p_param9                        => p_record.sold_to_org_id,
            p_param10                       => l_party_site_id,
            x_return_status                 => l_return_status);


  End If;

-- End Integration Framework Code


/* Start AuditTrail */
-- Code level should be OM-H and
-- if Audit Trail enabled
IF g_is_caller_defaulting='N' THEN
   IF l_code_level >= '110508' and nvl(l_audit_trail_enabled,'D') <> 'D' and
      nvl(p_record.transaction_phase_code,'F') = 'F' and
      not OE_GLOBALS.G_HEADER_CREATED THEN
     IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.add('Audit Trail enabled ',5);
     END IF;
      IF l_audit_trail_enabled = 'B' THEN  -- capture only for booked orders
        IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.add('Audit Trail enabled for booked orders only ...',5);
        END IF;
         IF p_record.booked_flag = 'Y' THEN
            IF l_result = OE_PC_GLOBALS.YES THEN
               l_history_captured := FALSE;
               IF x_on_operation_action = 1 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id
                         AND OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).HISTORY_TYPE = 'R' --5735600
                         THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                    END IF;
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
                    IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Line Security, attribute change requires reason',1);
                    END IF;
                     OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                     OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
                  END IF;
               ELSIF x_on_operation_action = 2 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                    END IF;
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'H';
                    IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Line Security, attribute change requires history',7);
                    END IF;
                     IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                      IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Line Security, attribute change requires history',7);
                      END IF;
   	                OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      ELSE -- capture audit for all orders
         IF l_result = OE_PC_GLOBALS.YES THEN
              l_history_captured := FALSE;
              IF x_on_operation_action = 1 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id
                         AND OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).HISTORY_TYPE = 'R' --5735600
                         THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                    END IF;
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'R';
                    IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Line Security, attribute change requires reason',1);
                    END IF;
                     OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                     OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
                  END IF;
              ELSIF x_on_operation_action = 2 THEN
                  BEGIN
                     FOR l_ind in 1..l_ctr LOOP
                         IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr).LINE_ID = p_record.line_id THEN
                            l_history_captured := TRUE;
                         END IF;
                     END LOOP;
                  EXCEPTION WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.add('While capturing history : '||sqlerrm,1);
                    END IF;
                     NULL;
                  END;
                  IF NOT l_history_captured THEN
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).LINE_ID := p_record.line_id;
                     OE_GLOBALS.OE_AUDIT_HISTORY_TBL(l_ctr+1).HISTORY_TYPE := 'H';
                    IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Line Security, attribute change requires history',7);
                    END IF;
                     IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'Y' then
                       IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Line Security, attribute change requires history',7);
                       END IF;
   	                OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'Y';
                     END IF;
                  END IF;
              END IF;
         END IF;
     END IF;
  ELSE
    IF l_debug_level  > 0 THEN
     OE_DEBUG_PUB.add('Audit Trail is disabled..',5);
    END IF;
  END IF;
END IF;
IF g_operation_action is null THEN
	g_operation_action := x_on_operation_action;
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION calculate_price_flag(p_operation           IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
                             ,p_record              IN  oe_ak_order_lines_v%ROWTYPE
                             ,x_on_operation_action OUT NOCOPY NUMBER)
RETURN NUMBER IS
   l_result   NUMBER := 0;
BEGIN

   l_result := is_op_constrained(p_operation           => p_operation
                                ,p_column_name         => 'CALCULATE_PRICE_FLAG'
                                ,p_record              => p_record
                                ,x_on_operation_action => x_on_operation_action);
   RETURN(l_result);

END calculate_price_flag;

---bug#4399426

FUNCTION COMMITMENT_ID
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result        NUMBER :=0;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'COMMITMENT_ID'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );
RETURN(l_result);

END COMMITMENT_ID;

FUNCTION AGREEMENT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION AUTHORIZED_TO_SHIP
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'AUTHORIZED_TO_SHIP_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END AUTHORIZED_TO_SHIP;

-- Start of fix #1459428  for function definition

FUNCTION ATTRIBUTE1
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		  (p_operation     => p_operation
		   ,p_column_name   => 'ATTRIBUTE1'
		   ,p_record   => p_record
		   ,x_on_operation_action     => x_on_operation_action
		    );

	    RETURN(l_result);

END ATTRIBUTE1;


FUNCTION ATTRIBUTE10
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

   l_result := Is_OP_constrained
		 (p_operation     => p_operation
	      ,p_column_name   => 'ATTRIBUTE10'
		 ,p_record   => p_record
		 ,x_on_operation_action     => x_on_operation_action
	      );

	   RETURN(l_result);

END ATTRIBUTE10;

FUNCTION ATTRIBUTE11
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE11'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

   RETURN(l_result);

END ATTRIBUTE11;

FUNCTION ATTRIBUTE12
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		 (p_operation     => p_operation
		 ,p_column_name   => 'ATTRIBUTE12'
		 ,p_record   => p_record
		 ,x_on_operation_action     => x_on_operation_action
		  );

    RETURN(l_result);

END ATTRIBUTE12;

FUNCTION ATTRIBUTE13
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		  (p_operation     => p_operation
		   ,p_column_name   => 'ATTRIBUTE13'
		   ,p_record   => p_record
		   ,x_on_operation_action     => x_on_operation_action
		    );

		    RETURN(l_result);

 END ATTRIBUTE13;

FUNCTION ATTRIBUTE14
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE14'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

	 RETURN(l_result);

END ATTRIBUTE14;


FUNCTION ATTRIBUTE15
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
 BEGIN

   l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE15'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

	RETURN(l_result);

END ATTRIBUTE15;

-- For Bug 2184255
FUNCTION ATTRIBUTE16
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE16'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

   RETURN(l_result);

END ATTRIBUTE16;

FUNCTION ATTRIBUTE17
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		 (p_operation     => p_operation
		 ,p_column_name   => 'ATTRIBUTE17'
		 ,p_record   => p_record
		 ,x_on_operation_action     => x_on_operation_action
		  );

    RETURN(l_result);

END ATTRIBUTE17;

FUNCTION ATTRIBUTE18
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		  (p_operation     => p_operation
		   ,p_column_name   => 'ATTRIBUTE18'
		   ,p_record   => p_record
		   ,x_on_operation_action     => x_on_operation_action
		    );

		    RETURN(l_result);

 END ATTRIBUTE18;

FUNCTION ATTRIBUTE19
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE19'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

	 RETURN(l_result);

END ATTRIBUTE19;

FUNCTION ATTRIBUTE2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE2'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

    RETURN(l_result);

END ATTRIBUTE2;

FUNCTION ATTRIBUTE20
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
 BEGIN

   l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE20'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

	RETURN(l_result);

END ATTRIBUTE20;

FUNCTION ATTRIBUTE3
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		  (p_operation     => p_operation
		   ,p_column_name   => 'ATTRIBUTE3'
		   ,p_record   => p_record
		   ,x_on_operation_action     => x_on_operation_action
		    );

    RETURN(l_result);

END ATTRIBUTE3;

FUNCTION ATTRIBUTE4
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE4'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
       );

    RETURN(l_result);

END ATTRIBUTE4;

FUNCTION ATTRIBUTE5
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE5'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

    RETURN(l_result);

END ATTRIBUTE5;

FUNCTION ATTRIBUTE6
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE6'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	    );

    RETURN(l_result);

END ATTRIBUTE6;

FUNCTION ATTRIBUTE7
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE7'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

	 RETURN(l_result);

END ATTRIBUTE7;

FUNCTION ATTRIBUTE8
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
		(p_operation     => p_operation
		 ,p_column_name   => 'ATTRIBUTE8'
		 ,p_record   => p_record
		 ,x_on_operation_action     => x_on_operation_action
		   );

    RETURN(l_result);

END ATTRIBUTE8;

FUNCTION ATTRIBUTE9
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'ATTRIBUTE9'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	   );

    RETURN(l_result);

END ATTRIBUTE9;

FUNCTION CONTEXT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
	  (p_operation     => p_operation
	  ,p_column_name   => 'CONTEXT'
	  ,p_record   => p_record
	  ,x_on_operation_action     => x_on_operation_action
	    );

    RETURN(l_result);

END CONTEXT;

-- End  of fix #1459428  for function definition

FUNCTION CREATED_BY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION CREDIT_INVOICE_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CREDIT_INVOICE_LINE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CREDIT_INVOICE_LINE;


FUNCTION CUSTOMER_LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CUSTOMER_LINE_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_LINE_NUMBER;


FUNCTION CUSTOMER_TRX_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'CUSTOMER_TRX_LINE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_TRX_LINE;


FUNCTION CUST_PO_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

-- Added for bug #7608170
FUNCTION CUSTOMER_JOB
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'CUSTOMER_JOB'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_JOB; -- Bug 8508275


FUNCTION DELIVERY_LEAD_TIME
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DELIVERY_LEAD_TIME'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DELIVERY_LEAD_TIME;


FUNCTION DELIVER_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION DELIVER_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION DEP_PLAN_REQUIRED
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'DEP_PLAN_REQUIRED_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END DEP_PLAN_REQUIRED;


FUNCTION EARLIEST_ACCEPTABLE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'EARLIEST_ACCEPTABLE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END EARLIEST_ACCEPTABLE_DATE;

FUNCTION END_ITEM_UNIT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'END_ITEM_UNIT_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END END_ITEM_UNIT_NUMBER;


FUNCTION FOB_POINT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION FULFILLED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'FULFILLED_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END FULFILLED_QUANTITY;

-- INVCONV

FUNCTION FULFILLED_QUANTITY2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'FULFILLED_QUANTITY2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END FULFILLED_QUANTITY2;


FUNCTION INVENTORY_ITEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'INVENTORY_ITEM_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END INVENTORY_ITEM;

FUNCTION INVOICE_TO_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION ITEM_REVISION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ITEM_REVISION'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ITEM_REVISION;


FUNCTION ITEM_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ITEM_TYPE_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ITEM_TYPE;


FUNCTION LATEST_ACCEPTABLE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LATEST_ACCEPTABLE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LATEST_ACCEPTABLE_DATE;


FUNCTION LINE_CATEGORY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LINE_CATEGORY_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LINE_CATEGORY;


FUNCTION LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LINE_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LINE_NUMBER;


FUNCTION LINE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'LINE_TYPE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END LINE_TYPE;


FUNCTION ORDERED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
l_old_qty 	NUMBER;
BEGIN

-- to fix #2312158
oe_sales_can_util.G_REQUIRE_REASON := FALSE;

IF p_operation = OE_PC_GLOBALS.UPDATE_OP THEN
   SELECT Ordered_Quantity
   INTO l_old_qty
   FROM OE_ORDER_LINES
   WHERE line_id = p_record.line_id;
END IF;

-- Added for #2871055, frontporting 3329897
IF NVL(OE_LINE_SECURITY.g_record.line_id,-1) <> p_record.line_id then
   OE_LINE_SECURITY.g_record := p_record;
END IF;

-- CHECK CONSTRAINTS FOR CANCEL OPERATION IF QUANTITY IS REDUCED
-- QUOTING change - check for cancellation constraint only for
-- lines in fulfillment phase, ordered quantity reduction on
-- quote lines should only check for quantity UPDATE constraints.
IF NVL(p_record.transaction_phase_code,'F') = 'F'
   AND p_operation = OE_PC_GLOBALS.UPDATE_OP
   AND nvl(p_record.ordered_quantity,0) < nvl(l_old_qty,0)
   AND NOT(p_record.split_action_code IS NOT NULL AND
		p_record.split_action_code <> FND_API.G_MISS_CHAR) THEN
    l_result := ORDERED_QUANTITY
        (p_operation	=> OE_PC_GLOBALS.CANCEL_OP
        ,p_record	=> p_record
        ,x_on_operation_action => x_on_operation_action
        );
ELSIF p_operation = OE_PC_GLOBALS.UPDATE_OP
   AND (p_record.split_action_code IS NOT NULL AND
		p_record.split_action_code <> FND_API.G_MISS_CHAR AND
		p_record.split_action_code = 'SPLIT') THEN
    l_result := ORDERED_QUANTITY
        (p_operation	=> OE_PC_GLOBALS.SPLIT_OP
        ,p_record	=> p_record
        ,x_on_operation_action => x_on_operation_action
        );
ELSE
    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ORDERED_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );
END IF;

RETURN(l_result);

END ORDERED_QUANTITY;

-- OPM 1857167 start

FUNCTION ORDERED_QUANTITY2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
l_old_qty2 	NUMBER;
BEGIN

IF p_operation = OE_PC_GLOBALS.UPDATE_OP THEN
    SELECT Ordered_Quantity2
    INTO l_old_qty2
    FROM OE_ORDER_LINES
    WHERE line_id = p_record.line_id;
END IF;

-- CHECK CONSTRAINTS FOR CANCEL OPERATION IF QUANTITY IS REDUCED
IF p_operation = OE_PC_GLOBALS.UPDATE_OP
   AND nvl(p_record.ordered_quantity2,0) < nvl(l_old_qty2,0)
   AND NOT(p_record.split_action_code IS NOT NULL AND
		p_record.split_action_code <> FND_API.G_MISS_CHAR) THEN
    l_result := ORDERED_QUANTITY2
        (p_operation	=> OE_PC_GLOBALS.CANCEL_OP
        ,p_record	=> p_record
        ,x_on_operation_action => x_on_operation_action
        );
ELSIF p_operation = OE_PC_GLOBALS.UPDATE_OP
   AND (p_record.split_action_code IS NOT NULL AND
		p_record.split_action_code <> FND_API.G_MISS_CHAR AND
		p_record.split_action_code = 'SPLIT') THEN
    l_result := ORDERED_QUANTITY2
        (p_operation	=> OE_PC_GLOBALS.SPLIT_OP
        ,p_record	=> p_record
        ,x_on_operation_action => x_on_operation_action
        );
ELSE
    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ORDERED_QUANTITY2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );
END IF;

RETURN(l_result);

END ORDERED_QUANTITY2;

-- OPM 1857167 end


FUNCTION ORDER_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ORDER_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ORDER_QUANTITY_UOM;


FUNCTION ORIG_SYS_DOCUMENT_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION ORIG_SYS_LINE_REF
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ORIG_SYS_LINE_REF'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ORIG_SYS_LINE_REF;


FUNCTION OVER_SHIP_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'OVER_SHIP_REASON_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END OVER_SHIP_REASON;


FUNCTION OVER_SHIP_RESOLVED
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'OVER_SHIP_RESOLVED_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END OVER_SHIP_RESOLVED;

FUNCTION PACKING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PACKING_INSTRUCTIONS'
        ,p_record	     => p_record
        ,x_on_operation_action	=> x_on_operation_action
        );


RETURN(l_result);

END PACKING_INSTRUCTIONS;


FUNCTION PAYMENT_TERM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION PLANNING_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PLANNING_PRIORITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PLANNING_PRIORITY;


FUNCTION PRICE_LIST
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION PRICING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PRICING_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PRICING_QUANTITY;


FUNCTION PRICING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PRICING_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PRICING_QUANTITY_UOM;


FUNCTION PROJECT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PROJECT_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PROJECT;


FUNCTION PROMISE_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'PROMISE_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END PROMISE_DATE;

FUNCTION REFERENCE_CUST_TRX_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REFERENCE_CUSTOMER_TRX_LINE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REFERENCE_CUST_TRX_LINE;

FUNCTION REFERENCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'REFERENCE_TYPE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END REFERENCE_TYPE;


FUNCTION REQUEST_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION SHIP_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_SET_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_SET;

FUNCTION ARRIVAL_SET
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ARRIVAL_SET_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ARRIVAL_SET;


FUNCTION SCHEDULE_ARRIVAL_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SCHEDULE_ARRIVAL_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SCHEDULE_ARRIVAL_DATE;

FUNCTION SCHEDULE_SHIP_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SCHEDULE_SHIP_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SCHEDULE_SHIP_DATE;


FUNCTION SHIPMENT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPMENT_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPMENT_NUMBER;


FUNCTION SHIPMENT_PRIORITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION SHIPPED_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPED_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPED_QUANTITY;

-- INVCONV

FUNCTION SHIPPED_QUANTITY2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPED_QUANTITY2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPED_QUANTITY2;


FUNCTION SHIPPING_INSTRUCTIONS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation    => p_operation
    ,p_column_name  => 'SHIPPING_INSTRUCTIONS'
    ,p_record  => p_record
    ,x_on_operation_action    => x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_INSTRUCTIONS;


FUNCTION SHIPPING_METHOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

l_result := Is_OP_constrained
    (p_operation    => p_operation
    ,p_column_name  => 'SHIPPING_METHOD_CODE'
    ,p_record  => p_record
    ,x_on_operation_action    => x_on_operation_action
    );

RETURN(l_result);

END SHIPPING_METHOD;


FUNCTION SHIPPING_QUANTITY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY;

-- INVCONV

FUNCTION SHIPPING_QUANTITY2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY2;

FUNCTION SHIPPING_QUANTITY_UOM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY_UOM'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY_UOM;



-- INVCONV

FUNCTION SHIPPING_QUANTITY_UOM2
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIPPING_QUANTITY_UOM2'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIPPING_QUANTITY_UOM2;


FUNCTION SHIP_FROM_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION SUBINVENTORY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result  NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation     => p_operation
        ,p_column_name   => 'SUBINVENTORY'
        ,p_record   => p_record
        ,x_on_operation_action     => x_on_operation_action
        );

RETURN(l_result);

END SUBINVENTORY;

FUNCTION SHIP_MODEL_COMPLETE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SHIP_MODEL_COMPLETE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SHIP_MODEL_COMPLETE;


FUNCTION SHIP_TOLERANCE_ABOVE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION SOLD_TO_ORG
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION SOURCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SOURCE_TYPE_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SOURCE_TYPE;


FUNCTION TASK
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TASK_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TASK;


FUNCTION TAX
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX;


FUNCTION TAX_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'TAX_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END TAX_DATE;


FUNCTION TAX_EXEMPT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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




FUNCTION UNIT_LIST_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'UNIT_LIST_PRICE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END UNIT_LIST_PRICE;



FUNCTION UNIT_SELLING_PRICE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'UNIT_SELLING_PRICE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END UNIT_SELLING_PRICE;


FUNCTION SERVICE_REFERENCE_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_REFERENCE_TYPE_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_REFERENCE_TYPE;

FUNCTION SERVICE_REFERENCE_LINE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_REFERENCE_LINE_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_REFERENCE_LINE;

FUNCTION SERVICE_REFERENCE_SYSTEM
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_REFERENCE_SYSTEM_ID'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_REFERENCE_SYSTEM;

/* Fix to bug 2205900: Added constraints functions for
some missing SERVICE fields */
FUNCTION SERVICE_COTERMINATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_COTERMINATE_FLAG'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_COTERMINATE;

FUNCTION SERVICE_DURATION
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_DURATION'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_DURATION;

FUNCTION SERVICE_END_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_END_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_END_DATE;

FUNCTION SERVICE_PERIOD
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_PERIOD'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_PERIOD;

FUNCTION SERVICE_START_DATE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_START_DATE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_START_DATE;

FUNCTION SERVICE_TXN_COMMENTS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_TXN_COMMENTS'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_TXN_COMMENTS;

FUNCTION SERVICE_TXN_REASON
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'SERVICE_TXN_REASON_CODE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END SERVICE_TXN_REASON;

/*1449220*/
FUNCTION ITEM_IDENTIFIER_TYPE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'ITEM_IDENTIFIER_TYPE'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END ITEM_IDENTIFIER_TYPE;
/*1449220*/

FUNCTION USER_ITEM_DESCRIPTION

(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'USER_ITEM_DESCRIPTION'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END USER_ITEM_DESCRIPTION;

FUNCTION BLANKET_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_NUMBER;

FUNCTION BLANKET_LINE_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
) RETURN NUMBER
IS
l_result 	NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation	=> p_operation
        ,p_column_name	=> 'BLANKET_LINE_NUMBER'
        ,p_record	=> p_record
        ,x_on_operation_action	=> x_on_operation_action
        );

RETURN(l_result);

END BLANKET_LINE_NUMBER;

FUNCTION CUSTOMER_SHIPMENT_NUMBER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER /* file.sql.39 change */
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN

    l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'CUSTOMER_SHIPMENT_NUMBER'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );

RETURN(l_result);

END CUSTOMER_SHIPMENT_NUMBER;


PROCEDURE Entity
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,   x_result                        OUT NOCOPY NUMBER  /* file.sql.39 change */
,   x_return_status                 OUT NOCOPY VARCHAR2  /* file.sql.39 change */
) IS
l_operation	VARCHAR2(1);
l_on_operation_action	NUMBER;
l_rowtype_rec	OE_AK_ORDER_LINES_V%ROWTYPE;
l_flow_status_code  VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
oe_debug_pub.add('Enter OE_LINE_Security.Entity',1);
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* start of bug 2922204 */

IF l_debug_level  > 0 THEN
oe_debug_pub.add('hash before create operation');
END IF;

IF p_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

IF l_debug_level  > 0 THEN
oe_debug_pub.add('hash in create operation');
END IF;

  IF p_Line_rec.item_type_code = 'SERVICE' AND
     p_line_rec.service_reference_type_code = 'ORDER' AND   --3390589
     p_line_rec.service_reference_line_id IS NOT NULL THEN
-- use p_line_rec.service_ref_line_id to get flow_status_code of parent
    BEGIN
	SELECT flow_status_code
	INTO l_flow_status_code
	FROM oe_order_lines
	WHERE line_id = p_line_rec.service_reference_line_id;
    END;

    IF l_flow_status_code = 'CANCELLED' THEN
      IF l_debug_level  > 0 THEN
	oe_debug_pub.add('hash flow status is cancelled..x_result is' || x_result);
      END IF;
        x_result := OE_PC_GLOBALS.YES;
      IF l_debug_level  > 0 THEN
	oe_debug_pub.add('hash flow status is cancelled..x_result is' || x_result);
      END IF;
        -- Add msg to stack
        FND_MESSAGE.SET_NAME('ONT','OE_SVC_PROD_CANCELLED');
	OE_MSG_PUB.Add;
        RETURN;
    ELSE
      IF l_debug_level  > 0 THEN
	oe_debug_pub.add('hash flow status is not cancelled');
      END IF;
        l_operation := OE_PC_GLOBALS.CREATE_OP;
    END IF; -- if cancelled
  ElSE
  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('hash not a service');
  END IF;
    l_operation := OE_PC_GLOBALS.CREATE_OP;
  END IF; -- end if service

--IF p_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
--    l_operation := OE_PC_GLOBALS.CREATE_OP;
/* end of bug 2922204 */


ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
    l_operation := OE_PC_GLOBALS.DELETE_OP;
ELSE
    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Invalid operation',1);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_LINE_Util_Ext.API_Rec_To_Rowtype_Rec
	(p_LINE_rec		=> p_line_rec
	, x_rowtype_rec	=> l_rowtype_rec);

--Initialize security global record
OE_LINE_SECURITY.g_record := l_rowtype_rec;

    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXXLINB operation is ' || p_line_rec.operation);
    END IF;
    IF (p_line_rec.split_from_line_id IS NOT NULL AND p_line_rec.operation = 'CREATE')
    THEN
       l_operation := OE_PC_GLOBALS.SPLIT_OP;
    END IF;
    x_result := Is_OP_constrained
    (p_operation	=> l_operation
    ,p_record	=> l_rowtype_rec
    ,x_on_operation_action	=> l_on_operation_action
    );


IF l_debug_level  > 0 THEN
oe_debug_pub.add('Exit OE_LINE_Security.Entity',1);
END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Entity'
        );
    END IF;

END Entity;

PROCEDURE Attributes
(   p_LINE_rec                      IN  OE_Order_PUB.LINE_Rec_Type
,   p_old_LINE_rec                  IN  OE_Order_PUB.LINE_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
,   x_result                        OUT NOCOPY NUMBER  /* file.sql.39 change */
,   x_return_status                 OUT NOCOPY VARCHAR2  /* file.sql.39 change */
) IS
l_operation	VARCHAR2(1);
l_on_operation_action  NUMBER;
l_result		NUMBER;
l_rowtype_rec	OE_AK_ORDER_LINES_V%ROWTYPE;
l_column_name	VARCHAR2(30);
l_active_flag  VARCHAR2(1);
l_check_all_cols_constraint VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
oe_debug_pub.add('Enter OE_LINE_Security.Attributes',1);
END IF;

-- Initializing return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Initialize g_operation_action to null
	g_operation_action := null;

-- Initializing out result to NOT CONSTRAINED
x_result := OE_PC_GLOBALS.NO;

 -- Get the operation code to be passed to the security framework API
IF p_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

    -- Bug 2639336 : if the order source is Copy then skip the Attribute
    -- level check
    -- Bug 3859436 : if the line is being split, skip attribute check.
   IF p_LINE_rec.source_document_type_id = OE_GLOBALS.G_ORDER_SOURCE_COPY
      OR p_line_rec.split_from_line_id <> FND_API.G_MISS_NUM
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
           (p_entity_id   => OE_PC_GLOBALS.G_ENTITY_LINE
           ,p_responsibility_id     => nvl(fnd_global.resp_id, -1)
           ,p_application_id        => nvl(fnd_global.resp_appl_id,-1) --added for bug3631547
           )
    THEN
       RETURN;
    END IF;

ELSIF p_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
    l_operation := OE_PC_GLOBALS.UPDATE_OP;
ELSE
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Invalid operation',1);
  END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OE_LINE_Util_Ext.API_Rec_To_Rowtype_Rec
	(p_LINE_rec		=> p_line_rec
	, x_rowtype_rec	=> l_rowtype_rec);

--Initialize security global record
OE_LINE_SECURITY.g_record := l_rowtype_rec;

-- Compare the new and old entity records and
-- check constraints for all the changed attributes.

    IF p_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.accounting_rule_id,p_old_line_rec.accounting_rule_id) THEN

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

    IF p_line_rec.IB_OWNER = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.IB_OWNER,p_old_line_rec.IB_OWNER) THEN

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
    IF p_line_rec.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.IB_CURRENT_LOCATION,p_old_line_rec.IB_CURRENT_LOCATION) THEN

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
    IF p_line_rec.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.IB_INSTALLED_AT_LOCATION,p_old_line_rec.IB_INSTALLED_AT_LOCATION) THEN

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
  IF p_line_rec.END_CUSTOMER_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.END_CUSTOMER_ID,p_old_line_rec.END_CUSTOMER_ID) THEN

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
   IF p_line_rec.END_CUSTOMER_CONTACT_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.END_CUSTOMER_CONTACT_ID,p_old_line_rec.END_CUSTOMER_CONTACT_ID) THEN

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
   IF p_line_rec.END_CUSTOMER_SITE_USE_ID = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.END_CUSTOMER_SITE_USE_ID,p_old_line_rec.END_CUSTOMER_SITE_USE_ID) THEN

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

    IF p_line_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.accounting_rule_duration,p_old_line_rec.accounting_rule_duration) THEN

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

    IF p_line_rec.agreement_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.agreement_id,p_old_line_rec.agreement_id) THEN

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

    IF p_line_rec.commitment_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.commitment_id,p_old_line_rec.commitment_id) THEN

        l_result := COMMITMENT_ID
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.arrival_set_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.arrival_set_id,p_old_line_rec.arrival_set_id)
    OR    NOT OE_GLOBALS.EQUAL(p_line_rec.arrival_set,p_old_line_rec.arrival_set) THEN

        l_result := ARRIVAL_SET
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.authorized_to_ship_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.authorized_to_ship_flag,p_old_line_rec.authorized_to_ship_flag) THEN

        l_result := AUTHORIZED_TO_SHIP
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.credit_invoice_line_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.credit_invoice_line_id,p_old_line_rec.credit_invoice_line_id) THEN

        l_result := CREDIT_INVOICE_LINE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.customer_line_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.customer_line_number,p_old_line_rec.customer_line_number) THEN

        l_result := CUSTOMER_LINE_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.customer_trx_line_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.customer_trx_line_id,p_old_line_rec.customer_trx_line_id) THEN

        l_result := CUSTOMER_TRX_LINE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.cust_po_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.cust_po_number,p_old_line_rec.cust_po_number) THEN

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

   -- Added for bug #7608170
   IF p_line_rec.customer_job = FND_API.G_MISS_CHAR THEN NULL;
   ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.customer_job,p_old_line_rec.customer_job) THEN

        l_result := CUSTOMER_JOB
            (p_operation => l_operation
            ,p_record    => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.delivery_lead_time = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.delivery_lead_time,p_old_line_rec.delivery_lead_time) THEN

        l_result := DELIVERY_LEAD_TIME
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_contact_id,p_old_line_rec.deliver_to_contact_id) THEN

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

    IF p_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id,p_old_line_rec.deliver_to_org_id) THEN

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

    IF p_line_rec.demand_class_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.demand_class_code,p_old_line_rec.demand_class_code) THEN

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

    IF p_line_rec.dep_plan_required_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.dep_plan_required_flag,p_old_line_rec.dep_plan_required_flag) THEN

        l_result := DEP_PLAN_REQUIRED
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.earliest_acceptable_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.earliest_acceptable_date,p_old_line_rec.earliest_acceptable_date) THEN

        l_result := EARLIEST_ACCEPTABLE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.end_item_unit_number,p_old_line_rec.end_item_unit_number) THEN

        l_result := END_ITEM_UNIT_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.fob_point_code,p_old_line_rec.fob_point_code) THEN

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

    IF p_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.freight_terms_code,p_old_line_rec.freight_terms_code) THEN

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

    IF p_line_rec.fulfilled_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.fulfilled_quantity,p_old_line_rec.fulfilled_quantity) THEN

        l_result := FULFILLED_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

-- INVCONV
    IF p_line_rec.fulfilled_quantity2 = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.fulfilled_quantity2,p_old_line_rec.fulfilled_quantity2) THEN

        l_result := FULFILLED_QUANTITY2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id) THEN

        l_result := INVENTORY_ITEM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_contact_id,p_old_line_rec.invoice_to_contact_id) THEN

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

    IF p_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id,p_old_line_rec.invoice_to_org_id) THEN

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

    IF p_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.invoicing_rule_id,p_old_line_rec.invoicing_rule_id) THEN

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

    IF p_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.item_identifier_type,p_old_line_rec.item_identifier_type) THEN

        l_result := ITEM_IDENTIFIER_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.item_revision = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.item_revision,p_old_line_rec.item_revision) THEN

        l_result := ITEM_REVISION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.item_type_code,p_old_line_rec.item_type_code) THEN

        l_result := ITEM_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.latest_acceptable_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.latest_acceptable_date,p_old_line_rec.latest_acceptable_date) THEN

        l_result := LATEST_ACCEPTABLE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.line_category_code,p_old_line_rec.line_category_code) THEN

        l_result := LINE_CATEGORY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.line_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.line_number,p_old_line_rec.line_number) THEN

        l_result := LINE_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.line_type_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.line_type_id,p_old_line_rec.line_type_id) THEN

        l_result := LINE_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.ordered_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity) THEN

        l_result := ORDERED_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

-- OPM 1857167 start
    IF p_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2) THEN

        l_result := ORDERED_QUANTITY2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
-- OPM 1857167 end



    IF p_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom) THEN

        l_result := ORDER_QUANTITY_UOM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.over_ship_reason_code,p_old_line_rec.over_ship_reason_code) THEN

        l_result := OVER_SHIP_REASON
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.over_ship_resolved_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.over_ship_resolved_flag,p_old_line_rec.over_ship_resolved_flag) THEN

        l_result := OVER_SHIP_RESOLVED
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.packing_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.packing_instructions,p_old_line_rec.packing_instructions) THEN

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

    IF p_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.payment_term_id,p_old_line_rec.payment_term_id) THEN

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

    IF p_line_rec.planning_priority = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.planning_priority,p_old_line_rec.planning_priority) THEN

        l_result := PLANNING_PRIORITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.price_list_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.price_list_id,p_old_line_rec.price_list_id) THEN

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

    IF p_line_rec.pricing_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.pricing_date,p_old_line_rec.pricing_date) THEN

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

    IF p_line_rec.pricing_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.pricing_quantity,p_old_line_rec.pricing_quantity) THEN

        l_result := PRICING_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.pricing_quantity_uom,p_old_line_rec.pricing_quantity_uom) THEN

        l_result := PRICING_QUANTITY_UOM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.project_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.project_id,p_old_line_rec.project_id) THEN

        l_result := PROJECT
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.promise_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.promise_date,p_old_line_rec.promise_date) THEN

        l_result := PROMISE_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.request_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.request_date,p_old_line_rec.request_date) THEN

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

    IF p_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.return_reason_code,p_old_line_rec.return_reason_code) THEN

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

    IF p_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.salesrep_id,p_old_line_rec.salesrep_id) THEN

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

    IF p_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE THEN NULL;
     ELSIF NOT OE_GLOBALS.EQUAL(trunc(p_line_rec.schedule_arrival_date),trunc(p_old_line_rec.schedule_arrival_date)) THEN

        l_result := SCHEDULE_ARRIVAL_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.schedule_ship_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(trunc(p_line_rec.schedule_ship_date),trunc(p_old_line_rec.schedule_ship_date)) THEN

        l_result := SCHEDULE_SHIP_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_reference_line_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_reference_line_id,p_old_line_rec.service_reference_line_id) THEN

        l_result := SERVICE_REFERENCE_LINE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_reference_system_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_reference_system_id,p_old_line_rec.service_reference_system_id) THEN

        l_result := SERVICE_REFERENCE_SYSTEM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_reference_type_code,p_old_line_rec.service_reference_type_code) THEN

        l_result := SERVICE_REFERENCE_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    /* Fix to bug 2205900: Added constraints functions for
    some missing SERVICE fields */

    IF p_line_rec.service_coterminate_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_coterminate_flag,p_old_line_rec.service_coterminate_flag) THEN

        l_result := SERVICE_COTERMINATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_duration = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_duration,p_old_line_rec.service_duration) THEN

        l_result := SERVICE_DURATION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_end_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_end_date,p_old_line_rec.service_end_date) THEN

        l_result := SERVICE_END_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_period = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_period,p_old_line_rec.service_period) THEN

        l_result := SERVICE_PERIOD
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_start_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_start_date,p_old_line_rec.service_start_date) THEN

        l_result := SERVICE_START_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_txn_comments = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_txn_comments,p_old_line_rec.service_txn_comments) THEN

        l_result := SERVICE_TXN_COMMENTS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.service_txn_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.service_txn_reason_code,p_old_line_rec.service_txn_reason_code) THEN

        l_result := SERVICE_TXN_REASON
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.shipment_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipment_number,p_old_line_rec.shipment_number) THEN

        l_result := SHIPMENT_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipment_priority_code,p_old_line_rec.shipment_priority_code) THEN

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

    IF p_line_rec.shipped_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipped_quantity,p_old_line_rec.shipped_quantity) THEN

        l_result := SHIPPED_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

-- INVCONV
   IF p_line_rec.shipped_quantity2 = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipped_quantity2,p_old_line_rec.shipped_quantity2) THEN

        l_result := SHIPPED_QUANTITY2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;


    IF p_line_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_instructions,p_old_line_rec.shipping_instructions) THEN

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

    IF p_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_method_code,p_old_line_rec.shipping_method_code) THEN

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

    IF p_line_rec.shipping_quantity = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_quantity,p_old_line_rec.shipping_quantity) THEN

        l_result := SHIPPING_QUANTITY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

-- INVCONV
	  IF p_line_rec.shipping_quantity2 = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_quantity2,p_old_line_rec.shipping_quantity2) THEN

        l_result := SHIPPING_QUANTITY2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;



    IF p_line_rec.shipping_quantity_uom = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_quantity_uom,p_old_line_rec.shipping_quantity_uom) THEN

        l_result := SHIPPING_QUANTITY_UOM
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

-- INVCONV
		IF p_line_rec.shipping_quantity_uom2 = FND_API.G_MISS_CHAR THEN NULL;
     ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_quantity_uom2,p_old_line_rec.shipping_quantity_uom2) THEN

        l_result := SHIPPING_QUANTITY_UOM2
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

     END IF;


    IF p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id) THEN

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

    IF p_line_rec.ship_model_complete_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_model_complete_flag,p_old_line_rec.ship_model_complete_flag) THEN

        l_result := SHIP_MODEL_COMPLETE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.ship_set_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_set_id,p_old_line_rec.ship_set_id)
    OR    NOT OE_GLOBALS.EQUAL(p_line_rec.ship_set,p_old_line_rec.ship_set) THEN

        l_result := SHIP_SET
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_tolerance_above,p_old_line_rec.ship_tolerance_above) THEN

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

    IF p_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_tolerance_below,p_old_line_rec.ship_tolerance_below) THEN

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

    IF p_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_contact_id,p_old_line_rec.ship_to_contact_id) THEN

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

    IF p_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id,p_old_line_rec.ship_to_org_id) THEN

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

    IF p_line_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id,p_old_line_rec.sold_to_org_id) THEN

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

    IF p_line_rec.source_type_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.source_type_code,p_old_line_rec.source_type_code) THEN

        l_result := SOURCE_TYPE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.subinventory = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.subinventory,p_old_line_rec.subinventory) THEN

        l_result := SUBINVENTORY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.task_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.task_id,p_old_line_rec.task_id) THEN

        l_result := TASK
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.tax_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.tax_code,p_old_line_rec.tax_code) THEN

        l_result := TAX
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.tax_date = FND_API.G_MISS_DATE THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.tax_date,p_old_line_rec.tax_date) THEN

        l_result := TAX_DATE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.tax_exempt_flag,p_old_line_rec.tax_exempt_flag) THEN

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

    IF p_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.tax_exempt_number,p_old_line_rec.tax_exempt_number) THEN

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

    IF p_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.tax_exempt_reason_code,p_old_line_rec.tax_exempt_reason_code) THEN

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

    IF p_line_rec.unit_list_price = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.unit_list_price,p_old_line_rec.unit_list_price) THEN

        l_result := UNIT_LIST_PRICE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.unit_selling_price = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.unit_selling_price,p_old_line_rec.unit_selling_price) THEN

        l_result := UNIT_SELLING_PRICE
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    -- BEGIN: Blankets Code Merge
    IF p_line_rec.blanket_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number,p_old_line_rec.blanket_number) THEN

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

    IF p_line_rec.blanket_line_number = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number,p_old_line_rec.blanket_line_number) THEN

        l_result := BLANKET_LINE_NUMBER
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

    IF ((nvl(p_line_rec.calculate_price_flag,'N')='Y') AND
	  (p_line_rec.price_list_id IS NOT NULL) AND
	  (NOT OE_GLOBALS.Equal(p_line_rec.price_list_id,
		 p_old_line_rec.price_list_id)) )   THEN
      BEGIN
	   SELECT active_flag
	   INTO l_active_flag
	   FROM qp_List_headers_vl
	   WHERE list_header_id = p_line_rec.price_list_id;

	   IF NVL(l_active_flag,'N')='N' THEN
		FND_MESSAGE.SET_NAME('ONT','OE_INACTIVE_PRICELIST');
          OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	   END IF;
	 EXCEPTION
	   WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
		oe_debug_pub.add('when others',1);
              END IF;
	 END;
    END IF;

    IF p_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR THEN
       NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.calculate_price_flag
                              ,p_old_line_rec.calculate_price_flag) THEN

       l_result := calculate_price_flag(p_operation           => l_operation
                                       ,p_record              => l_rowtype_rec
                                       ,x_on_operation_action => l_on_operation_action);

       IF l_result = OE_PC_GLOBALS.YES THEN
          -- set OUT result to CONSTRAINED
          x_result := OE_PC_GLOBALS.YES;
       END IF;
    END IF;

    IF p_line_rec.customer_shipment_number = FND_API.G_MISS_CHAR THEN
       NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.customer_shipment_number,p_old_line_rec.customer_shipment_number) THEN

        l_result := CUSTOMER_SHIPMENT_NUMBER
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;



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

    IF p_line_rec.context = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.context,p_old_line_rec.context) THEN

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

    IF p_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute1,p_old_line_rec.attribute1) THEN

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

    IF p_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute10,p_old_line_rec.attribute10) THEN

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

    IF p_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute11,p_old_line_rec.attribute11) THEN

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

    IF p_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute12,p_old_line_rec.attribute12) THEN

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

    IF p_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute13,p_old_line_rec.attribute13) THEN

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

    IF p_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute14,p_old_line_rec.attribute14) THEN

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

    IF p_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute15,p_old_line_rec.attribute15) THEN

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

-- For bug 2184255

    IF p_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute16,p_old_line_rec.attribute16) THEN

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

    IF p_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute17,p_old_line_rec.attribute17) THEN

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

    IF p_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute18,p_old_line_rec.attribute18) THEN

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

    IF p_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute19,p_old_line_rec.attribute19) THEN

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

    IF p_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute2,p_old_line_rec.attribute2) THEN

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


    IF p_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute20,p_old_line_rec.attribute20) THEN

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

-- End bug 2184255

    IF p_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute3,p_old_line_rec.attribute3) THEN

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

    IF p_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute4,p_old_line_rec.attribute4) THEN

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

    IF p_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute5,p_old_line_rec.attribute5) THEN

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

    IF p_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute6,p_old_line_rec.attribute6) THEN

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

    IF p_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute7,p_old_line_rec.attribute7) THEN

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

    IF p_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute8,p_old_line_rec.attribute8) THEN

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

    IF p_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.attribute9,p_old_line_rec.attribute9) THEN

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

    IF p_line_rec.user_item_description = FND_API.G_MISS_CHAR THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.user_item_description, p_old_line_rec.user_item_description) THEN

        l_result := USER_ITEM_DESCRIPTION
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    /* Customer Acceptance - Start */
    IF p_line_rec.contingency_id = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.contingency_id,p_old_line_rec.contingency_id) THEN

        l_result := CONTINGENCY
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;

    IF p_line_rec.revrec_expiration_days = FND_API.G_MISS_NUM THEN NULL;
    ELSIF NOT OE_GLOBALS.EQUAL(p_line_rec.revrec_expiration_days,p_old_line_rec.revrec_expiration_days) THEN

        l_result := REVREC_EXPIRATION_DAYS
            (p_operation        => l_operation
            ,p_record   => l_rowtype_rec
            ,x_on_operation_action => l_on_operation_action
            );

        IF l_result = OE_PC_GLOBALS.YES THEN
            -- set OUT result to CONSTRAINED
            x_result := OE_PC_GLOBALS.YES;
        END IF;

    END IF;
    /* Customer Acceptance - End */

    IF OE_PC_GLOBALS.G_CHECK_UPDATE_ALL_FOR_DFF = 'N' THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('setting check all cols constraint to:'||l_check_all_cols_constraint);
     END IF;
       g_check_all_cols_constraint := l_check_all_cols_constraint;
    END IF;

    -- END: CHECK FOR CONSTRAINTS ON DESC FLEXFIELD ATTRIBUTES
    -- NOTE: Please add constraints check for new attributes before the
    -- descriptive flexfield attributes check.

IF l_debug_level  > 0 THEN
oe_debug_pub.add('Exit OE_LINE_Security.Attributes',1);
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Attributes'
        );
    END IF;

END Attributes;


FUNCTION IB_OWNER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

FUNCTION END_CUSTOMER
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION END_CUSTOMER_SITE_USE
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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


FUNCTION END_CUSTOMER_CONTACT
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER  /* file.sql.39 change */
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

PROCEDURE ALLOW_TAX_CODE_OVERRIDE
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER  /* file.sql.39 change */
)
IS
    Ret_Val    VARCHAR2(1);
BEGIN
    --Ret_Val := FND_PROFILE.VALUE('AR_ALLOW_TAX_CODE_OVERRIDE');
    Ret_Val := FND_PROFILE.VALUE('ZX_ALLOW_TAX_CLASSIF_OVERRIDE');
    IF Ret_Val = 'Y' THEN
        p_result := 1;
    ELSE
        p_result := 0;
    END IF;
END ALLOW_TAX_CODE_OVERRIDE;

PROCEDURE ALLOW_TRX_LINE_EXEMPTIONS
( p_application_id                  IN NUMBER,
  p_entity_short_name               IN VARCHAR2,
  p_validation_entity_short_name    IN VARCHAR2,
  p_validation_tmplt_short_name     IN VARCHAR2,
  p_record_set_tmplt_short_name     IN VARCHAR2,
  p_scope                           IN VARCHAR2,
  p_result                          OUT NOCOPY NUMBER  /* file.sql.39 change */
)
IS
    Ret_Val    VARCHAR2(1);
BEGIN
    --Ret_Val := FND_PROFILE.VALUE('AR_ALLOW_TRX_LINE_EXEMPTIONS');
    Ret_Val := FND_PROFILE.VALUE('ZX_ALLOW_TRX_LINE_EXEMPTIONS');
    IF Ret_Val = 'Y' THEN
        p_result := 1;
    ELSE
        p_result := 0;
    END IF;
END ALLOW_TRX_LINE_EXEMPTIONS;

FUNCTION CONTINGENCY
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN
   l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'CONTINGENCY_ID'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );
RETURN(l_result);

END CONTINGENCY;

FUNCTION REVREC_EXPIRATION_DAYS
(   p_operation                     IN  VARCHAR2 DEFAULT OE_PC_GLOBALS.UPDATE_OP
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   x_on_operation_action           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
l_result        NUMBER;
BEGIN
   l_result := Is_OP_constrained
        (p_operation    => p_operation
        ,p_column_name  => 'REVREC_EXPIRATION_DAYS'
        ,p_record       => p_record
        ,x_on_operation_action  => x_on_operation_action
        );
RETURN(l_result);

END REVREC_EXPIRATION_DAYS;

END OE_Line_Security;

/
