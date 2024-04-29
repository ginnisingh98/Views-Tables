--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PVT" AS
/* $Header: OEXVORDB.pls 120.14.12010000.13 2010/10/19 07:39:08 gabhatia ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_PVT';
g_header_id                   NUMBER;
g_upgraded_flag		     VARCHAR2(1);
g_booked_flag                 VARCHAR2(1);

--  Header

-- Global Flags for setting Recursion
po_ctr number := 0;
hdr_ctr number := 0;
hdr_adj_ctr number := 0;
hdr_scredit_ctr number := 0;
line_ctr number := 0;
line_adj_ctr number := 0;
line_scredit_ctr number := 0;
prn_ctr number := 0;
pr_ctr number := 0;
prrt_ctr number := 0;
poa_ctr number := 0;

-- Set recursion Mode

-- SAM
TYPE OE_OPTION_INDEX_TBL_TYPE IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT;
--SUN OIP ER
TYPE event_Tbl IS TABLE OF boolean
     INDEX BY BINARY_INTEGER;
L_event_tbl  event_Tbl;
--End of SUN OIP ER
Procedure Set_Recursion_Mode (p_Entity_Code number,
                              p_In_Out number := 1)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTER SET RECURSION MODE' , 1 ) ;
            oe_debug_pub.add(  'ENTITY CODE-'||P_ENTITY_CODE , 1 ) ;
            oe_debug_pub.add(  'ENTRY-EXIT MODE -'||P_IN_OUT , 1 ) ;
    oe_debug_pub.add(  'RECURSION MODE AT ENTRY -' || OE_GLOBALS.G_RECURSION_MODE , 1 ) ;
		     oe_debug_pub.add(  'RECURSION MODE WITHOUT EXP AT ENTRY -' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION , 1 ) ;
        END IF;

          IF p_entity_code = 1 THEN
                        IF p_In_Out = 1 THEN
                                po_ctr := po_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                po_ctr := po_ctr - 1;
                        END IF;
                         IF (line_ctr > 0 OR
                          Hdr_ctr > 0 OR
                          Hdr_adj_ctr > 0 OR
                          Hdr_scredit_ctr > 0 OR
                          line_adj_ctr > 0 OR
                          line_scredit_ctr > 0 OR
                          prn_ctr > 0 OR
                                pr_ctr > 0 ) THEN
				--prrt_ctr > 0  ) THEN
                         oe_globals.g_recursion_mode := 'Y';
                           OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                         OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

/* This is added to control notification call to just one call out. */
			IF po_ctr > 1 THEN
		OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
			ELSE
		OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
			END IF;

               NULL;
          ELSIF p_entity_code = 2 THEN

                      IF p_In_Out = 1 THEN
                                hdr_ctr := hdr_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                hdr_ctr := hdr_ctr - 1;
                        END IF;
                    IF hdr_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                         OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                         null; /* SAM */
                    END IF;


               NULL;
          ELSIF p_entity_code = 3 THEN
                      IF p_In_Out = 1 THEN
                                hdr_adj_ctr := hdr_adj_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                hdr_adj_ctr := hdr_adj_ctr - 1;
                        END IF;
                    IF hdr_adj_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                      OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

               NULL;

          ELSIF p_entity_code = 4 THEN

                        IF p_In_Out = 1 THEN
                                hdr_scredit_ctr := hdr_scredit_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                hdr_scredit_ctr := hdr_scredit_ctr - 1;
                        END IF;
                    IF hdr_scredit_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                        OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

               NULL;
          ELSIF p_entity_code = 5 THEN
                      IF p_In_Out = 1 THEN
                                line_ctr := line_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                line_ctr := line_ctr - 1;
                        END IF;
                    IF line_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                     OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

               NULL;
          ELSIF p_entity_code = 6 THEN
                     IF p_In_Out = 1 THEN
                                line_adj_ctr := line_adj_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                line_adj_ctr := line_adj_ctr - 1;
                        END IF;
                    IF line_adj_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                      OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

               NULL;
          ELSIF p_entity_code = 7 THEN
                      IF p_In_Out = 1 THEN
                                line_scredit_ctr := line_scredit_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                line_scredit_ctr := line_scredit_ctr - 1;
                      END IF;
                    IF line_scredit_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                     OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                     OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;

               NULL;
          ELSIF p_entity_code = 8 THEN
                      IF p_In_Out = 1 THEN
                                prn_ctr := prn_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                prn_ctr := prn_ctr - 1;
                      END IF;

                   /* IF (prn_ctr > 1 AND
                                pr_ctr >  0) THEN
                         oe_globals.g_recursion_mode := 'Y';*/
                    IF prn_ctr > 0 AND
                         (line_ctr > 0 OR
                          Hdr_ctr > 0 OR
                          Hdr_adj_ctr > 0 OR
                          Hdr_scredit_ctr > 0 OR
                          line_adj_ctr > 0 OR
                          line_scredit_ctr > 0 OR
                          po_ctr > 1 OR
			  --prrt_ctr > 0 OR
                                pr_ctr > 0  ) THEN
                         oe_globals.g_recursion_mode := 'Y';
		    ELSIF prn_ctr > 1 THEN
			oe_globals.g_recursion_mode := 'Y';
		    ELSIF
			 prn_ctr = 0 AND
                         (line_ctr > 1 OR
                          Hdr_ctr > 1 OR
                          Hdr_adj_ctr > 1 OR
                          Hdr_scredit_ctr > 1 OR
                          line_adj_ctr > 1 OR
                          line_scredit_ctr > 1 OR
                          po_ctr > 1 OR
                                pr_ctr > 1  ) THEN
			oe_globals.g_recursion_mode := 'Y';

                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                     END IF;

                   IF prn_ctr > 0 AND
                         (line_ctr > 0 OR
                          Hdr_ctr > 0 OR
                          Hdr_adj_ctr > 0 OR
                          Hdr_scredit_ctr > 0 OR
                          line_adj_ctr > 0 OR
                          line_scredit_ctr > 0 OR
                          po_ctr > 1 OR
                                pr_ctr > 0 OR
				--prrt_ctr > 0 OR
			poa_ctr > 0  ) THEN

			OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
		   ELSIF  prn_ctr > 1 THEN
			OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
			OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';

                    END IF;


                        NULL;
          ELSIF p_entity_code = 9 THEN
                      IF p_In_Out = 1 THEN
                                pr_ctr := pr_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                pr_ctr := pr_ctr - 1;
                        END IF;
                    IF pr_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                      OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF;
                        NULL;

           ELSIF p_entity_code = 10 THEN
                      IF p_In_Out = 1 THEN
                                poa_ctr := poa_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                poa_ctr := poa_ctr - 1;
                        END IF;
                    IF poa_ctr > 1 THEN
			OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
			OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';

                    END IF;
                        NULL;
		ELSIF p_entity_code = 11 THEN
                      IF p_In_Out = 1 THEN
                                prrt_ctr := prrt_ctr + 1;
                        ELSIF p_In_Out = 0 THEN
                                prrt_ctr := prrt_ctr - 1;
                        END IF;
-- We stopped tracking recursion in request type since it was causing issues
-- around executing configuration related requests and update shipping.
-- Pricing is now going by ui flag to set the process as false while
-- executing request for req type in validate and write.

                    /*IF prrt_ctr > 1 THEN
                         oe_globals.g_recursion_mode := 'Y';
                      OE_ORDER_UTIL.G_Recursion_Without_Exception := 'Y';
                    ELSE
                         oe_globals.g_recursion_mode := 'N';
                       OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
                    END IF; */
                        NULL;


          ELSE
                         oe_globals.g_recursion_mode := 'N';
                   OE_ORDER_UTIL.G_Recursion_Without_Exception := 'N';
               NULL;
          END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'RECURSION MODE AT EXIT -' || OE_GLOBALS.G_RECURSION_MODE , 1 ) ;
    oe_debug_pub.add(  'RECURSION MODE WITHOUT EXP AT EXIT -' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION , 1 ) ;
END IF;
End Set_Recursion_Mode ;


/*---------------------------------------------------------------------
 Forward Declarations related to configurations.
----------------------------------------------------------------------*/
PROCEDURE Print_Time(p_msg   IN  VARCHAR2);


-- ##1828866 added p_process_partial.
PROCEDURE Complete_Config_line
( p_x_line_rec       IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
 ,p_item_type        IN     NUMBER
 ,p_x_line_tbl       IN     OE_ORDER_PUB.Line_Tbl_Type
 ,p_process_partial  IN     BOOLEAN := FALSE);

PROCEDURE Get_Missing_Class_Lines
( p_x_line_tbl         IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
 ,p_options_index_tbl  IN  OE_OPTION_INDEX_TBL_TYPE
,x_class_index OUT NOCOPY NUMBER

,x_class_count OUT NOCOPY NUMBER);



/*-------------------------------------------------------------------
FUNCTION Valid_Upgraded_Order

--------------------------------------------------------------------*/
FUNCTION Valid_Upgraded_Order(p_header_id Number)
RETURN Boolean
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER VALID UPGRADED ORDER' ) ;
  END IF;
  IF (NOT OE_GLOBALS.EQUAL(p_header_id, g_header_id)) OR
-- aksingh perf removing OR part of below condition as not required
-- (g_header_id IS  NULL OR g_upgraded_flag IS NULL)
   (g_header_id IS  NULL)
  THEN
    select UPGRADED_FLAG, booked_flag into
    g_upgraded_flag, g_booked_flag
    from oe_order_headers_all
    where header_id = p_header_id;
    g_header_id := p_header_id;
  END IF;

  IF g_upgraded_flag IN ('P','I') THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER PARTIALLY UPGRADED ' ) ;
    END IF;
    FND_MESSAGE.SET_NAME('ONT','OE_INVALID_UPG_ORDER');
    OE_MSG_PUB.Add;
    RETURN FALSE;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT VALID UPGRADED ORDER ' ) ;
  END IF;
  RETURN TRUE;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN TRUE;

END Valid_Upgraded_Order;


/*----------------------------------------------------------------------
PROCEDURE Header
-----------------------------------------------------------------------*/

PROCEDURE Header
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_header_rec                  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_x_old_header_rec              IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_user_id                      NUMBER;
l_resp_id                      NUMBER;
l_application_id               NUMBER;
l_hdr_process_name             VARCHAR2(30);
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
x_msg_count		NUMBER;
x_msg_data		VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id    number ;
--
BEGIN
    --Moac changes start
    l_org_id := MO_GLOBAL.get_current_org_id;
    IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
    --Moac changes end
    --  Initialize message list.
    set_recursion_mode(p_Entity_Code => 2,
                       p_In_out  => 1);

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.HEADER' , 1 ) ;
    END IF;

    -- This is to check if the order is an upgraded order and is upgraded
    -- correctly
    IF p_x_header_rec.operation <> OE_GLOBALS.G_OPR_CREATE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING VALID UPGRADE ORDER' , 2 ) ;
        END IF;
	   IF NOT Valid_Upgraded_Order(p_x_header_rec.header_id ) THEN
                 RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    IF p_x_old_header_rec.header_id = FND_API.G_MISS_NUM
	  OR p_x_old_header_rec.header_id IS NULL
    THEN

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER'
  	,p_entity_id         		=> p_x_header_rec.header_id
    	,p_header_id         		=> p_x_header_rec.header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> p_x_header_rec.orig_sys_document_ref
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => p_x_header_rec.change_sequence
    	,p_source_document_id		=> p_x_header_rec.source_document_id
    	,p_source_document_line_id	=> null
	,p_order_source_id            => p_x_header_rec.order_source_id
	,p_source_document_type_id    => p_x_header_rec.source_document_type_id);

    ELSE

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER'
  	,p_entity_id         		=> p_x_old_header_rec.header_id
    	,p_header_id         		=> p_x_old_header_rec.header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> p_x_old_header_rec.orig_sys_document_ref
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => p_x_header_rec.change_sequence
    	,p_source_document_id		=> p_x_old_header_rec.source_document_id
    	,p_source_document_line_id	=> null
	,p_order_source_id            => p_x_old_header_rec.order_source_id
	,p_source_document_type_id    => p_x_old_header_rec.source_document_type_id);

    END IF;


    --  Load API control record

    l_control_rec := OE_GLOBALS.Init_Control_Rec
    (   p_operation     => p_x_header_rec.operation
    ,   p_control_rec   => p_control_rec
    );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_ORDER_PVT.HEADER AFTER INIT CONTROL REC' , 2 ) ;
   END IF;

    --  Set record return status.

    p_x_header_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'OPERATION = CREATE SO SET OLD TO NULL' , 2 ) ;
    	END IF;
        p_x_header_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        OE_Header_Util.Convert_Miss_To_Null (p_x_old_header_rec);

    ELSIF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR    p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE
    THEN

    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'OPERATION = UPDATE SO QUERY OLD' , 2 ) ;
    	END IF;

        p_x_header_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  p_x_old_header_rec.header_id = FND_API.G_MISS_NUM
		  OR p_x_old_header_rec.header_id IS NULL
        THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'QUERYING OLD HEADER REC' ) ;
		  END IF;

            OE_Header_Util.Query_Row
            (   p_header_id                   => p_x_header_rec.header_id
		  ,   x_header_rec                  => p_x_old_header_rec
            );

        ELSE

            --  Set missing old record elements to NULL.

           OE_Header_Util.Convert_Miss_To_Null (p_x_old_header_rec);

        END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING COMPLETE RECORD' , 2 ) ;
       END IF;

        --  Complete new record from old

        OE_Header_Util.Complete_Record
        (   p_x_header_rec                => p_x_header_rec
        ,   p_old_header_rec              => p_x_old_header_rec
        );

	OE_MSG_PUB.update_msg_context(
	   p_entity_code		=> 'HEADER'
  	  ,p_entity_id         		=> p_x_header_rec.header_id
    	  ,p_header_id         		=> p_x_header_rec.header_id
    	  ,p_line_id           		=> null
          ,p_order_source_id            => p_x_header_rec.order_source_id
    	  ,p_orig_sys_document_ref	=> p_x_header_rec.orig_sys_document_ref
    	  ,p_orig_sys_document_line_ref	=> null
    	  ,p_source_document_id		=> p_x_header_rec.source_document_id
    	  ,p_source_document_line_id	=> null );

    END IF;

  IF ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
    OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE)  THEN


   -- Check security
   IF l_control_rec.check_security
    AND (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ATTRIBUTES SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Header_Security.Attributes
                (p_header_rec   	=> p_x_header_rec
                , p_old_header_rec	=> p_x_old_header_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

    --  Attribute level validation.

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'VALIDATE ATTRIBUTES' , 2 ) ;
        END IF;

            OE_Validate_Header.Attributes
            (   x_return_status               => l_return_status
            ,   p_x_header_rec                => p_x_header_rec
            ,   p_old_header_rec              => p_x_old_header_rec
            ,   p_validation_level	      => p_validation_level
            );

	    IF p_validation_level <> OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	    END IF;
        END IF;


        --  Clear dependent attributes.

    IF  l_control_rec.clear_dependents THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CLEAR DEPENDENT' , 2 ) ;
        END IF;

        OE_Header_Util.Clear_Dependent_Attr
        (   p_x_header_rec                => p_x_header_rec
        ,   p_old_header_rec              => p_x_old_header_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    THEN

    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'DEFAULT MISSING' , 2 ) ;
    	END IF;

        OE_Default_Header.Attributes
        (   p_x_header_rec                => p_x_header_rec
        ,   p_old_header_rec              => p_x_old_header_rec
        );

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER DEFAULT MISSING' , 2 ) ;
    END IF;

    --  Apply attribute changes

    IF  l_control_rec.change_attributes
    THEN

    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'APPLY ATTRIBUTE CHANGES' , 2 ) ;
    	END IF;

        OE_Header_Util.Apply_Attribute_Changes
        (   p_x_header_rec                => p_x_header_rec
        ,   p_old_header_rec              => p_x_old_header_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity
    and p_x_header_rec.cancelled_flag<>'Y'  --added for bug 6494347
    THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'VALIDATE ENTITY' , 2 ) ;
        END IF;

        IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Validate_Header.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_header_rec                  => p_x_header_rec
            );

        ELSE

            OE_Validate_Header.Entity
            (   x_return_status               => l_return_status
            ,   p_header_rec                  => p_x_header_rec
            ,   p_old_header_rec              => p_x_old_header_rec
            ,   p_validation_level            => p_validation_level
/* Added the above line to fix the bug 2824240 */
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;


    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    -- For UPDATE operations, entity security checks for constraints setup
    -- with a NULL column i.e. the constraint restricts update on ANY of
    -- the columns.
    -- However, this check should NOT be done if user did not try to update
    -- any of the constrainable attributes and also none of the defaulted
    -- attributes was constrainable!. In such a case, the g_check_all_cols
    -- _constraint flag would still be 'Y' as the flag is reset only
    -- when checking for constraints.
    IF NOT (p_x_header_rec.operation  = OE_GLOBALS.G_OPR_UPDATE
               AND OE_Header_Security.g_check_all_cols_constraint = 'Y')
       AND l_control_rec.check_security
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ENTITY SECURITY' ) ;
        END IF;

           OE_Header_Security.Entity
                (p_header_rec   	=> p_x_header_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

    --  Step 4. Write to DB
    IF l_control_rec.write_to_db THEN
		Oe_Header_Util.Pre_Write_Process(p_x_header_rec => p_x_header_rec,
						p_old_header_rec => p_x_old_header_rec);
    END IF;

    IF l_control_rec.write_to_db THEN

    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'WRITE TO DB' , 2 ) ;
    	END IF;

        IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Header_Util.Delete_Row
            (   p_header_id                   => p_x_header_rec.header_id
            );

        ELSE

            --  Get Who Information

            p_x_header_rec.last_update_date  := SYSDATE;
            p_x_header_rec.last_updated_by   := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
            p_x_header_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF p_x_header_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
			p_x_header_rec.credit_card_approval_date := NULL;
            END IF;

            IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'HEADER FLOW STATUS :'||P_X_HEADER_REC.FLOW_STATUS_CODE , 1 ) ;
			END IF;
                OE_Header_Util.Update_Row (p_x_header_rec);

            ELSIF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                p_x_header_rec.creation_date     := SYSDATE;
                p_x_header_rec.created_by        := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

                l_user_id := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
                l_resp_id := FND_GLOBAL.RESP_ID;
                l_application_id := FND_GLOBAL.RESP_APPL_ID;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'USER ID IS '|| L_USER_ID ) ;
                    oe_debug_pub.add(  'RESP ID IS '|| L_RESP_ID ) ;
                    oe_debug_pub.add(  'APPL ID IS '|| L_APPLICATION_ID ) ;
                END IF;


                OE_Header_Util.Insert_Row (p_x_header_rec);

            END IF;

        END IF;

    END IF;

    --  Step 4. Write to DB
    IF l_control_rec.write_to_db THEN
		OE_Header_Util.Post_Write_Process
		  ( p_x_header_rec    => p_x_header_rec,
		    p_old_header_rec  => p_x_old_header_rec
		   );
    END IF;

  END IF;

    --  Load OUT parameters
    p_x_header_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    OE_Header_Security.g_check_all_cols_constraint := 'Y';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PVT.HEADER' , 1 ) ;
    END IF;
    OE_MSG_PUB.reset_msg_context('HEADER');

    set_recursion_mode(p_Entity_Code => 2,
                       p_In_out  => 0);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        set_recursion_mode(p_Entity_Code => 2,
                           p_In_out  => 0);
        p_x_header_rec.return_status     := FND_API.G_RET_STS_ERROR;
	   x_return_status 				 := FND_API.G_RET_STS_ERROR;
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST1' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        set_recursion_mode(p_Entity_Code => 2,
                                   p_In_out  => 0);
        p_x_header_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
	   x_return_status 				 := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST2' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER');

    WHEN OTHERS THEN

        set_recursion_mode(p_Entity_Code => 2,
                                   p_In_out  => 0);
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        p_x_header_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
	   x_return_status 				 := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST3' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER');

END Header;



/*-------------------------------------------------------------------
PROCEDURE  Header_Scredits
-------------------------------------------------------------------*/
PROCEDURE Header_Scredits
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_old_Header_Scredit_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_del_ret_status              VARCHAR2(1);
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_old_Header_Scredit_rec      OE_Order_PUB.Header_Scredit_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;

I 				    NUMBER; -- Used as index for while loop
--bug 5049879
l_booked_flag                 VARCHAR2(1);
l_quota_flag                  VARCHAR2(1);
--bug 5049879
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id number ;
--
BEGIN

    --MOAC changes start
      l_org_id := MO_GLOBAL.get_current_org_id;
      IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    --MOAC changes end

    set_recursion_mode(p_Entity_Code => 4,
                                   p_In_out  => 1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    IF p_control_rec.Process_Partial THEN
        SAVEPOINT Header_Scredits;
    END IF;

    --  Init local table variables.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.HEADER_SCREDITS' , 1 ) ;
    END IF;

--    FOR I IN 1..p_x_Header_Scredit_tbl.COUNT LOOP

    I := p_x_Header_Scredit_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Scredit_rec := p_x_Header_Scredit_tbl(I);

        IF p_x_old_Header_Scredit_tbl.EXISTS(I) THEN
            l_old_Header_Scredit_rec := p_x_old_Header_Scredit_tbl(I);
        ELSE
            l_old_Header_Scredit_rec := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;
        END IF;

      if l_old_header_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM
	    OR l_old_header_Scredit_rec.sales_credit_id IS NULL
	 Then

         IF l_header_Scredit_rec.header_id IS NOT NULL AND
            l_header_Scredit_rec.header_id <> FND_API.G_MISS_NUM THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_Scredit_rec.header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_Scredit_rec.header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;

        OE_MSG_PUB.set_msg_context(
	 	p_entity_code			=> 'HEADER_SCREDIT'
  		,p_entity_id         		=> l_header_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_header_Scredit_rec.header_Id
    		,p_line_id           		=> null
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> null );

     else
         IF l_old_header_Scredit_rec.header_id IS NOT NULL AND
            l_old_header_Scredit_rec.header_id <> FND_API.G_MISS_NUM THEN

            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old header_id:'||l_old_header_Scredit_rec.header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_old_header_Scredit_rec.header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;


        OE_MSG_PUB.set_msg_context(
	 	p_entity_code			=> 'HEADER_SCREDIT'
  		,p_entity_id         		=> l_old_header_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_old_header_Scredit_rec.header_Id
    		,p_line_id           		=> null
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
    		,p_source_document_line_id	=> null );

     end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Scredit_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Scredit_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            OE_Header_Scredit_Util.Convert_Miss_To_Null (l_old_Header_Scredit_rec);

        ELSIF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Scredit_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM
			 OR l_old_Header_Scredit_rec.sales_credit_id IS NULL
            THEN

                OE_Header_Scredit_Util.Query_Row
                (   p_sales_credit_id             => l_Header_Scredit_rec.sales_credit_id
			 ,   x_header_scredit_rec          => l_old_Header_Scredit_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

                OE_Header_Scredit_Util.Convert_Miss_To_Null (l_old_Header_Scredit_rec);

            END IF;

            --  Complete new record from old

            OE_Header_Scredit_Util.Complete_Record
            (   p_x_Header_Scredit_rec        => l_Header_Scredit_rec
            ,   p_old_Header_Scredit_rec      => l_old_Header_Scredit_rec
            );

            OE_MSG_PUB.update_msg_context(
	 	p_entity_code			=> 'HEADER_SCREDIT'
  		,p_entity_id         		=> l_header_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_header_Scredit_rec.header_Id);


        END IF;

        IF I = p_x_header_scredit_tbl.FIRST THEN
	       IF NOT Valid_Upgraded_Order(l_header_scredit_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_header_scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_header_scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ATTRIBUTES SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Header_Scredit_Security.Attributes
                (p_header_scredit_rec  	=> l_header_scredit_rec
                , p_old_header_scredit_rec	=> l_old_header_scredit_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Header_Scredit.Attributes
                (   x_return_status               => l_return_status
                ,   p_Header_Scredit_rec          => l_Header_Scredit_rec
                ,   p_old_Header_Scredit_rec      => l_old_Header_Scredit_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;


            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Header_Scredit_Util.Clear_Dependent_Attr
            (   p_x_Header_Scredit_rec        => l_Header_Scredit_rec
            ,   p_old_Header_Scredit_rec      => l_old_Header_Scredit_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        THEN

            OE_Default_Header_Scredit.Attributes
            (   p_x_Header_Scredit_rec        => l_Header_Scredit_rec
            ,   p_old_header_scredit_rec      => l_old_header_scredit_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

            OE_Header_Scredit_Util.Apply_Attribute_Changes
            (   p_x_Header_Scredit_rec          => l_Header_Scredit_rec
            ,   p_old_Header_Scredit_rec      => l_old_Header_Scredit_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Header_Scredit.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Header_Scredit_rec          => l_Header_Scredit_rec
                );

            ELSE

                OE_Validate_Header_Scredit.Entity
                (   x_return_status               => l_return_status
                ,   p_Header_Scredit_rec          => l_Header_Scredit_rec
                ,   p_old_Header_Scredit_rec      => l_old_Header_Scredit_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    -- For UPDATE operations, entity security checks for constraints setup
    -- with a NULL column i.e. the constraint restricts update on ANY of
    -- the columns.
    -- However, this check should NOT be done if user did not try to update
    -- any of the constrainable attributes and also none of the defaulted
    -- attributes was constrainable!. In such a case, the g_check_all_cols
    -- _constraint flag would still be 'Y' as the flag is reset only
    -- when checking for constraints.
    IF NOT (l_header_scredit_rec.operation  = OE_GLOBALS.G_OPR_UPDATE
               AND OE_Header_Scredit_Security.g_check_all_cols_constraint = 'Y')
       AND l_control_rec.check_security
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ENTITY SECURITY' ) ;
        END IF;

           OE_Header_Scredit_Security.Entity
                (p_header_scredit_rec   	=> l_header_scredit_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN
		 /* Start Audit Trail */
      	 Oe_Header_Scredit_Util.Pre_Write_Process
		   (p_x_header_scredit_rec => l_header_scredit_rec,
		    p_old_header_scredit_rec => l_old_header_scredit_rec);
           /* End AuditTrail */

            IF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
               SAVEPOINT DELETE_SCREDIT_FAILED; --bug 5331854
   --bug 5049879
                select quota_flag into l_quota_flag from oe_sales_credit_types where sales_credit_type_id = l_header_scredit_rec.sales_credit_type_id;
                select booked_flag into l_booked_flag from oe_order_headers where header_id = l_header_scredit_rec.header_id;
                OE_Header_Scredit_Util.Delete_Row
                (   p_sales_credit_id             => l_Header_Scredit_rec.sales_credit_id
                );

                IF nvl(l_booked_flag, 'N') = 'Y' and nvl(l_quota_flag, 'N') = 'Y' THEN
                   OE_Validate_Header_Scredit.Validate_HSC_TOTAL_FOR_BK(l_header_scredit_rec.return_status,
                                                                    l_header_scredit_rec.header_id);
                   IF l_debug_level > 0 THEN
                      oe_debug_pub.add('after delete_row and hdr validate_hsc_quota_total rt status : ' || l_header_scredit_rec.return_status);
                   END IF;
                   l_del_ret_status := l_header_scredit_rec.return_status; --bug 5331854

                END IF;
  --bug 5049879
            ELSE

                --  Get Who Information

                l_Header_Scredit_rec.last_update_date := SYSDATE;
                l_Header_Scredit_rec.last_updated_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
                l_Header_Scredit_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Header_Scredit_Util.Update_Row (l_Header_Scredit_rec);

                ELSIF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Scredit_rec.creation_date := SYSDATE;
                    l_Header_Scredit_rec.created_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

                    OE_Header_Scredit_Util.Insert_Row (l_Header_Scredit_rec);

                END IF;

            END IF;

        END IF;

    	OE_Header_Scredit_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

     --  loop exception handler.
	IF l_header_scredit_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 ELSIF l_header_scredit_rec.return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
	END IF;

        --  Load tables.

        l_Header_Scredit_rec.return_status        := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Scredit_tbl(I)        := l_Header_Scredit_rec;
        p_x_old_Header_Scredit_tbl(I)    := l_old_Header_Scredit_rec;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

          l_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
	     x_return_status 				:= FND_API.G_RET_STS_ERROR;
          p_x_Header_Scredit_tbl(I)        := l_Header_Scredit_rec;
          p_x_old_Header_Scredit_tbl(I)    := l_old_Header_Scredit_rec;

    	     OE_Header_Scredit_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

		IF l_control_Rec.Process_Partial THEN
             IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'DELETE REQUEST4' , 2 ) ;
               END IF;
               oe_delayed_requests_pvt.Delete_Reqs_for_Deleted_Entity
                 (p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
                  p_entity_id => l_header_scredit_rec.sales_credit_id,
                  x_return_status => l_return_status);
             END IF;
		   ROLLBACK TO SAVEPOINT Header_Scredits;
		ELSE
                   --bug 5331854
                   IF OE_GLOBALS.G_UI_FLAG AND
                      l_del_ret_status = FND_API.G_RET_STS_ERROR THEN
                      ROLLBACK TO SAVEPOINT DELETE_SCREDIT_FAILED;
                   END IF;
                   --bug 5331854
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Scredit_tbl(I)        := l_Header_Scredit_rec;
            p_x_old_Header_Scredit_tbl(I)    := l_old_Header_Scredit_rec;
    	       OE_Header_Scredit_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Scredit_tbl(I)        := l_Header_Scredit_rec;
            p_x_old_Header_Scredit_tbl(I)    := l_old_Header_Scredit_rec;

    	       OE_Header_Scredit_Security.g_check_all_cols_constraint := 'Y';
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_Scredits'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
     I := p_x_Header_Scredit_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PVT.HEADER_SCREDITS' , 1 ) ;
    END IF;
         OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

    set_recursion_mode(p_Entity_Code => 4,
                                   p_In_out  => 0);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        set_recursion_mode(p_Entity_Code => 4,
                                   p_In_out  => 0);
	   x_return_status 				:= FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST5' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        set_recursion_mode(p_Entity_Code => 4,
                                   p_In_out  => 0);
	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST6' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

    WHEN OTHERS THEN

        set_recursion_mode(p_Entity_Code => 4,
                                   p_In_out  => 0);
	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST7' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Scredits'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');

END Header_Scredits;


/*-------------------------------------------------------------------
PROCEDURE  Header_Payments
-------------------------------------------------------------------*/
PROCEDURE Header_Payments
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Payment_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_x_old_Header_Payment_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Header_Payment_rec          OE_Order_PUB.Header_Payment_Rec_Type;
l_old_Header_Payment_rec      OE_Order_PUB.Header_Payment_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;

I 				    NUMBER; -- Used as index for while loop
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id      number ;
--
BEGIN

    --MOAC changes start
      l_org_id := MO_GLOBAL.get_current_org_id;
      IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    --MOAC changes end

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    IF p_control_rec.Process_Partial THEN
        SAVEPOINT Header_Payments;
    END IF;

    --  Init local table variables.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.HEADER_PAYMENTS' , 1 ) ;
    END IF;

--    FOR I IN 1..p_x_Header_Payment_tbl.COUNT LOOP

    I := p_x_Header_Payment_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Header_Payment_rec := p_x_Header_Payment_tbl(I);

        IF p_x_old_Header_Payment_tbl.EXISTS(I) THEN
            l_old_Header_Payment_rec := p_x_old_Header_Payment_tbl(I);
        ELSE
            l_old_Header_Payment_rec := OE_Order_PUB.G_MISS_HEADER_PAYMENT_REC;
        END IF;

      if l_old_header_Payment_rec.payment_number = FND_API.G_MISS_NUM
	    OR l_old_header_Payment_rec.payment_number IS NULL
	 Then

         IF l_header_Payment_rec.header_id IS NOT NULL AND
            l_header_Payment_rec.header_id <> FND_API.G_MISS_NUM THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_Payment_rec.header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_Payment_rec.header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;

        OE_MSG_PUB.set_msg_context(
	 	p_entity_code			=> 'HEADER_PAYMENT'
  		,p_entity_id         		=> l_header_Payment_rec.payment_number
    		,p_header_id         		=> l_header_Payment_rec.header_Id
    		,p_line_id           		=> null
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> null );

     else
         IF l_old_header_Payment_rec.header_id IS NOT NULL AND
            l_old_header_Payment_rec.header_id <> FND_API.G_MISS_NUM THEN

            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old header_id:'||l_old_header_Payment_rec.header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_old_header_Payment_rec.header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;


        OE_MSG_PUB.set_msg_context(
	 	p_entity_code			=> 'HEADER_PAYMENT'
  		,p_entity_id         		=> l_old_header_Payment_rec.payment_number
    		,p_header_id         		=> l_old_header_Payment_rec.header_Id
    		,p_line_id           		=> null
                ,p_order_source_id              => l_order_source_id
                ,p_orig_sys_document_ref        => l_orig_sys_document_ref
                ,p_orig_sys_document_line_ref   => null
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
                ,p_source_document_id           => l_source_document_id
    		,p_source_document_line_id	=> null );

     end if;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Header_Payment_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Header_Payment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Header_Payment_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Convert_Miss_To_Null', 5);
            END IF;
            OE_Header_Payment_Util.Convert_Miss_To_Null (l_old_Header_Payment_rec);
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Convert_Miss_To_Null', 5);
            END IF;

        ELSIF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Header_Payment_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Header_Payment_rec.payment_number = FND_API.G_MISS_NUM
			 OR l_old_Header_Payment_rec.payment_number IS NULL
            THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Query_Row', 5);
                END IF;
                OE_Header_Payment_Util.Query_Row
                (   p_payment_number             => l_Header_Payment_rec.payment_number
                ,   p_header_id                  => l_Header_Payment_rec.header_id
		,   x_header_payment_rec          => l_old_Header_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Query_Row', 5);
                END IF;

            ELSE

                --  Set missing old record elements to NULL.

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Convert_Miss_To_Null', 5);
                END IF;
                OE_Header_Payment_Util.Convert_Miss_To_Null (l_old_Header_Payment_rec);
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Convert_Miss_To_Null', 5);
                END IF;

            END IF;

            --  Complete new record from old

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Complete_Record', 5);
            END IF;
            OE_Header_Payment_Util.Complete_Record
            (   p_x_Header_Payment_rec        => l_Header_Payment_rec
            ,   p_old_Header_Payment_rec      => l_old_Header_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Complete_Record', 5);
            END IF;

            OE_MSG_PUB.update_msg_context(
	 	p_entity_code			=> 'HEADER_PAYMENT'
  		,p_entity_id         		=> l_header_Payment_rec.payment_number
    		,p_header_id         		=> l_header_Payment_rec.header_Id);


        END IF;

        IF I = p_x_header_Payment_tbl.FIRST THEN
	       IF NOT Valid_Upgraded_Order(l_header_Payment_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_header_payment_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_header_payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ATTRIBUTES SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:before OE_Header_Payment_Security.Attributes', 5);
           END IF;
           OE_Header_Payment_Security.Attributes
                (p_header_payment_rec  	=> l_header_payment_rec
                , p_old_header_payment_rec	=> l_old_header_payment_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:after OE_Header_Payment_Security.Attributes', 5);
           END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Header_Payment.Attributes', 5);
                END IF;

                OE_Validate_Header_Payment.Attributes
                (   x_return_status               => l_return_status
                ,   p_Header_Payment_rec          => l_Header_Payment_rec
                ,   p_old_Header_Payment_rec      => l_old_Header_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Header_Payment.Attributes',5);
                END IF;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;


            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Clear_Dependent_Attr', 5);
            END IF;
            OE_Header_Payment_Util.Clear_Dependent_Attr
            (   p_x_Header_Payment_rec        => l_Header_Payment_rec
            ,   p_old_Header_Payment_rec      => l_old_Header_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Clear_Dependent_Attr', 5);
            END IF;

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Default_Header_Payment.Attributes', 5);
            END IF;

            OE_Default_Header_Payment.Attributes
            (   p_x_Header_Payment_rec        => l_Header_Payment_rec
            ,   p_old_header_payment_rec      => l_old_header_payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Default_Header_Payment.Attributes', 5);
            END IF;

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Header_Payment_Util.Apply_Attribute_Changes', 5);
            END IF;
            OE_Header_Payment_Util.Apply_Attribute_Changes
            (   p_x_Header_Payment_rec          => l_Header_Payment_rec
            ,   p_old_Header_Payment_rec      => l_old_Header_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Header_Payment_Util.Apply_Attribute_Changes', 5);
            END IF;

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Header_Payment.Entity_Delete', 5);
                END IF;
                OE_Validate_Header_Payment.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Header_Payment_rec          => l_Header_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Header_Payment.Entity_Delete', 5);
                END IF;

            ELSE
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Header_Payment.Entity',5);
                END IF;

                OE_Validate_Header_Payment.Entity
                (   x_return_status               => l_return_status
                ,   p_Header_Payment_rec          => l_Header_Payment_rec
                ,   p_old_Header_Payment_rec      => l_old_Header_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Header_Payment.Entity, 5');
                END IF;

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    -- For UPDATE operations, entity security checks for constraints setup
    -- with a NULL column i.e. the constraint restricts update on ANY of
    -- the columns.
    -- However, this check should NOT be done if user did not try to update
    -- any of the constrainable attributes and also none of the defaulted
    -- attributes was constrainable!. In such a case, the g_check_all_cols
    -- _constraint flag would still be 'Y' as the flag is reset only
    -- when checking for constraints.
    IF NOT (l_header_payment_rec.operation  = OE_GLOBALS.G_OPR_UPDATE
               AND OE_Header_Payment_Security.g_check_all_cols_constraint = 'Y')
       AND l_control_rec.check_security
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ENTITY SECURITY' ) ;
        END IF;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:before OE_Header_Payment_Security.Entity', 5);
           END IF;

           OE_Header_Payment_Security.Entity
                (p_header_payment_rec   	=> l_header_payment_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:after OE_Header_Payment_Security.Entity', 5);
           END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

		 /* Start Audit Trail */
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Payment:before Oe_Header_Payment_Util.Pre_Write_Process', 5);
         END IF;
      	 Oe_Header_Payment_Util.Pre_Write_Process
		   (p_x_header_Payment_rec => l_header_payment_rec,
		    p_old_header_payment_rec => l_old_header_payment_rec);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Payment:after Oe_Header_Payment_Util.Pre_Write_Process', 5);
         END IF;
           /* End AuditTrail */

            IF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before Oe_Header_Payment_Util.Delete_Row',5);
                END IF;

                OE_Header_Payment_Util.Delete_Row
                (   p_payment_number     => l_Header_Payment_rec.payment_number
                ,   p_header_id          => l_Header_Payment_rec.header_id
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after Oe_Header_Payment_Util.Delete_Row',5);
                END IF;

            ELSE

                --  Get Who Information

                l_Header_Payment_rec.last_update_date := SYSDATE;
                l_Header_Payment_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Header_Payment_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Header_Payment_Util.Update_Row (l_Header_Payment_rec);

                ELSIF l_Header_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Header_Payment_rec.creation_date := SYSDATE;
                    l_Header_Payment_rec.created_by := FND_GLOBAL.USER_ID;

                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:before Oe_Header_Payment_Util.Insert_Row', 5);
                    END IF;
                    OE_Header_Payment_Util.Insert_Row (l_Header_Payment_rec);
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:after Oe_Header_Payment_Util.Insert_Row', 5);
                    END IF;

                END IF;

            END IF;

        END IF;

    	OE_Header_Payment_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

     --  loop exception handler.
	IF l_header_payment_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 ELSIF l_header_payment_rec.return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
	END IF;

        --  Load tables.

        l_Header_Payment_rec.return_status        := FND_API.G_RET_STS_SUCCESS;
        p_x_Header_Payment_tbl(I)        := l_Header_Payment_rec;
        p_x_old_Header_Payment_tbl(I)    := l_old_Header_Payment_rec;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

          l_Header_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;
	     x_return_status 				:= FND_API.G_RET_STS_ERROR;
          p_x_Header_Payment_tbl(I)        := l_Header_Payment_rec;
          p_x_old_Header_Payment_tbl(I)    := l_old_Header_Payment_rec;

    	     OE_Header_Payment_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');
		IF l_control_Rec.Process_Partial THEN
             IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'DELETE REQUEST4' , 2 ) ;
               END IF;
               oe_delayed_requests_pvt.Delete_Reqs_for_Deleted_Entity
                 (p_entity_code =>OE_GLOBALS.G_ENTITY_HEADER_PAYMENT,
                  p_entity_id => l_header_payment_rec.header_id,
                  x_return_status => l_return_status);
             END IF;
		   ROLLBACK TO SAVEPOINT Header_Payments;
		ELSE
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Header_Payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Payment_tbl(I)        := l_Header_Payment_rec;
            p_x_old_Header_Payment_tbl(I)    := l_old_Header_Payment_rec;
    	       OE_Header_Payment_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Header_Payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Header_Payment_tbl(I)        := l_Header_Payment_rec;
            p_x_old_Header_Payment_tbl(I)    := l_old_Header_Payment_rec;

    	       OE_Header_Payment_Security.g_check_all_cols_constraint := 'Y';
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Header_Payments'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
     I := p_x_Header_Payment_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PVT.HEADER_PAYMENTS' , 1 ) ;
    END IF;
         OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   x_return_status 				:= FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST5' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST6' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

    WHEN OTHERS THEN

	   x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST7' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Payments'
            );
        END IF;


        OE_MSG_PUB.reset_msg_context('HEADER_PAYMENT');

END Header_Payments;


/*---------------------------------------------------------------------
FUNCTION Check_Item_Type

-- LOCAL function called in procedure Lines
-- Return value from this function indicates what should be the order in
-- which this line is processed based on the type of item on
-- this line. The logic is based on whether the top_model_line or
-- service_line identifiers are populated on the record or not.
-- (Item Type is NOT used to derive this information as item_type_code
-- is available only after defaulting)
-- Possible Return Values:
-- 1:	Standard/ Model Line
-- 2:	Option/Class Line
-- 3:	Service Line
----------------------------------------------------------------------*/
FUNCTION Check_Item_Type
(   p_line_rec              		IN  OE_Order_PUB.Line_Rec_Type
,   p_line_index				IN  NUMBER
)
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	-- SERVICE line if service line identifiers are populated
	IF (	NVL(p_line_rec.service_reference_line_id,FND_API.G_MISS_NUM)
					<> FND_API.G_MISS_NUM
     	OR NVL(p_line_rec.service_line_index,FND_API.G_MISS_NUM)
					<>  FND_API.G_MISS_NUM )
	THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SERVICE LINE' , 1 ) ;
			END IF;
			RETURN 3;

	-- Top model line identifiers are populated
	ELSIF ( NVL(p_line_rec.top_model_line_id,FND_API.G_MISS_NUM)
					<> FND_API.G_MISS_NUM
     	OR NVL(p_line_rec.top_model_line_index,FND_API.G_MISS_NUM)
					<>  FND_API.G_MISS_NUM )
	THEN

		-- MODEL line if top model line is same as the current line
		IF ( p_line_rec.top_model_line_id <> FND_API.G_MISS_NUM
		     AND p_line_rec.top_model_line_id = p_line_rec.line_id )
	         OR ( p_line_rec.top_model_line_index <> FND_API.G_MISS_NUM
			AND p_line_rec.top_model_line_index = p_line_index )
		THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOP MODEL LINE' , 1 ) ;
			END IF;
			RETURN 1;
		-- OPTION/CLASS line if line is NOT the model line
		ELSE
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'OPTION/CLASS LINE' , 1 ) ;
			END IF;
		     RETURN 2;
		END IF;

	ELSE

		-- STANDARD line if neither the top model line identifiers
		-- nor the service line identifiers are populated
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'STANDARD LINE' , 1 ) ;
			END IF;
			RETURN 1;

	END IF;


END Check_Item_Type;



/*----------------------------------------------------------------------
PROCEDURE Lines

changes to get ato_line_id in case of pto + ato case, bug 1654987.

WHEN:

1) Almost all the additional code should never get called if the
   configuration is created using options window or configurator,
   since we already do all the work in respective code.

2) Some of the additional stuff happens for copy order and split.
3) All the additionsl work happens for order import and any other
   batch api callers.


WHY:
1) We need to process all the top level parents
   (MODEL, KIT, STANDARD) before we start processing any of the
   child lines. This is because all the child lines refer to the
   parent lines using top_model_line_index,
   service_reference_line_index etc.  and the child lines
   processing assumes that all the parents are saved in database
   and now it can convert all the indexes to proper values.
   e.g. top_model_line_index to top_model_line_id.

2) Thus we process
     all the models and standrds lines first,
     then all the classes, options
     then all service lines.
     This is irrespective of the operation on the lines.

2) New stuff:
   For various reasons (2 bugs till now), we need to process
   the class lines before the option lines for the operation
   of create. The single most imp. reason is that in case pto+ato
   case, we can make sure that all the option lines
   will have ato_line_id correclty populated in defaulting code
   itself. This is necessary for schedluing and shipping to
   behave correctly.



HOW:
  Instead of coming up with another mode of CLASS, we now have
  a peudo mode of CLASS within the mode of OPTIONS. This means
  that we will loop twice within the mode of OPTIONS, in certain
  cases as explained below.
  The reason for pseudo mode,
  1) The check_item_type procedure can not distinguish between a
     class and option. We need the (new) complete_config_line
     procedure for that.
  2) most of the code in the 2 modes(CLASS and OPTION) is common,
     the uncommon portion is tightly bound to each other.
  3) I also have modified the lines loop to goto the end_of_lines_loop
     instead of beging_of_line_loop. This makes sure that switch mode
     happens at one place and my extra login will also go at that point.
  4) There is no change if the operation is UPDATE or DELETE on
     class/options lines.
  5) If the call is made from configurator code or options window
     code, on all the classl lines, item_type_code is passed.


LOGIC:
 only the new stuff is explained here(at a high level), rest is same.
 ***: indiactes previous code.

 if boolean COMPLETE_AND_CLASS_SAVE_MODE is TRUE, we create CLASSES
 if it is fales, we create OPTIONS.


MODE = standard_and_models and check_item_type = 1
  l_process_this_line = TRUE;
  ***
  IF top model,
    IF not called by config UI,
      explode the model
      fill in bom related stuff
    END IF
  END IF;


MODE = OPTIONS and check_item_type = 2
  IF the line is processed
    go to end_of_lines (e.g class during option create, or update of option)
  END IF;

  ***

  IF operation = create

    IF COMPLETE_AND_CLASS_SAVE_MODE = TRUE and no config UI used.
      fill in bom related stuff(indicates IF class when you are done)
    END IF;

      IF this is not a CLASS line
        note the index, go to end_of_lines(will process, when the mode is false)
      END IF
    END IF
  END IF;


MODE = SERVICE and check_item_type = 3
  l_process_this_line = TRUE;
  ***


IF l_process_this_line = FALSE
  go to end_of_line_loop
END IF;

<<end_of_line_loop>> SWITCHING modes.

 IF MODE = 'MODELS_AND_STANDARD' AND END of lines table(only models,std done)
   l_mode := 'OPTIONS';
   COMPLETE_AND_CLASS_SAVE_MODE := TRUE;
   start from the first record again.

 IF mode = 'OPTIONS' AND END of lines table (classes create, upd/del done)

   IF COMPLETE_AND_CLASS_SAVE_MODE

      COMPLETE_AND_CLASS_SAVE_MODE = FALSE;
      -- false means, create OPTIONS, mode is still OPTIONS

     IF not config UI Used  AND
        some of the options were skipped in creation

        fill in all missing classes, use componenet_code and the fact
        that all the classes are saved now.

        IF some new classes added,
          set the mode back to classes, save all of them.
          thus set the COMPLETE_AND_CLASS_SAVE_MODE = TRUE
        END IF;

     END IF;

   ELSE
     MODE = 'SERVICE';
   END IF;

 END IF;

    -- Fixed bug# 1362872: Removed code to set return_status to SUCCESS on
    -- the records as it was overwriting error statuses.
    -- The return_status is set at the end of the loop and in the case
    -- of errors, it is set in the exception handlers.

Change Record:

1828866: to not raise error if some of the option/class items
are not available in bom_explosions. Populate message and continue.
related changes in : OEXUCFGB.pls, OEXUCPYB.pls

We will not call the complete_config_line for splits. This is
because split already passes all the columns to be filled
in the complete_config. Also the call the get_missing_classes
is not required for the splits. The assumption is split code
already populates/copies all the config related attributes.

2027611: call to complete_config_line when the mode is OPTION,
will be done only if top_model_line_index is present.
In future we should remove check for config_ui_used global
and also top_model_line_id not null, not miss_num check
while calling  complete_config_line.
-----------------------------------------------------------------------*/

PROCEDURE Lines
(p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,p_validation_level              IN  NUMBER
,p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,p_x_line_tbl                    IN  OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
,p_x_old_line_tbl                IN  OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
,x_return_status OUT NOCOPY VARCHAR2)

IS
  l_return_status         VARCHAR2(1);
  l_control_rec           OE_GLOBALS.Control_Rec_Type;
  l_line_rec              OE_Order_PUB.Line_Rec_Type;
  l_old_line_rec          OE_Order_PUB.Line_Rec_Type;
  l_mode                  VARCHAR2(20);
  I                       NUMBER;
  l_top_model_line_index  NUMBER;
  l_service_line_index    NUMBER;
  l_user_id               NUMBER;
  l_resp_id               NUMBER;
  l_application_id        NUMBER;
  l_line_process_name     VARCHAR2(30);

  -- local variables to store OUT parameters from security check procedures
  l_sec_result                  NUMBER;
  l_on_operation_action         NUMBER;
  l_result                      Varchar2(30);
  l_request_ind                 NUMBER;
  l_check_item_type             NUMBER;
  l_daemon_type                 VARCHAR2(1);
  l_is_ota_line                 BOOLEAN;
  l_order_quantity_uom          VARCHAR2(3);
  l_header_locked               VARCHAR2(1) := FND_API.G_MISS_CHAR;
  l_locked_header_rec           OE_Order_PUB.Header_Rec_Type;
  l_process_this_line           BOOLEAN;
  COMPLETE_AND_CLASS_SAVE_MODE  BOOLEAN := TRUE;
  l_options_index_tbl           OE_OPTION_INDEX_TBL_TYPE;
  l_class_index                 NUMBER;
  l_class_count                 NUMBER;
  J                             NUMBER := 0;
  l_num_lines                   NUMBER;
  l_bom_item_type               NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_org_id number ;
  --
BEGIN

--SUN OIP ER
L_event_tbl.DELETE;
--End of SUN OIP ER

    --Moac changes start
    l_org_id := MO_GLOBAL.get_current_org_id;
    IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
    --Moac changes end
  set_recursion_mode(p_Entity_Code => 5,
                                   p_In_out  => 1);

  l_num_lines := p_x_line_tbl.COUNT;

  Print_Time('Entering OE_ORDER_PVT.LINES ' || l_num_lines);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF OE_GLOBALS.G_RECURSION_MODE <> 'Y' THEN
           SAVEPOINT Lines_Non_Partial;
  END IF;

  --  Initialize message list.

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    OE_MSG_PUB.initialize;
  END IF;

  -- Looping through the table to first process all the models and
  -- standard lines in the table. When models and options are processed in
  -- one Process Order Call (like in Copy Order)  options do not have
  -- top_model_line_id
  -- and link_to_line_id populated. Thus the Parent line has to be
  -- processed before the
  -- options so that we can populate the option's top_model_line_id and
  -- link_to_line_id.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'G_CONFIG_UI_USED '|| OE_CONFIG_UTIL.G_CONFIG_UI_USED , 5 ) ;
  END IF;

  l_mode  :=  'MODELS_AND_STANDARD' ;

  I := p_x_line_tbl.FIRST;

  WHILE I IS NOT NULL AND l_num_lines > 0
  LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '---------LOOPING FOR NTH TIME N= '|| I , 1 ) ;
    END IF;

    IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_NONE THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPERATION IS NONE ' , 1 ) ;
      END IF;

      IF nvl(p_x_line_tbl(I).semi_processed_flag, FALSE) = FALSE THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ALREADY CAME IN , OPR = NONE' , 5 ) ;
        END IF;
        p_x_line_tbl(I).semi_processed_flag := TRUE;
        l_num_lines := l_num_lines - 1;
      END IF;

      GOTO end_of_lines_loop;
    END IF;

    l_process_this_line := FALSE;

    BEGIN

      -- Added following logic to identify the RMA lines if user has sent in the
      -- ordered_quantity as negative. (bug2620749)

      IF p_x_line_tbl(I).ordered_quantity < 0 AND
         ( p_x_line_tbl(I).line_category_code IS NULL OR
           p_x_line_tbl(I).line_category_code = FND_API.G_MISS_CHAR OR
           p_x_line_tbl(I).line_category_code = 'RETURN')
      THEN
          p_x_line_tbl(I).line_category_code := 'RETURN';
          p_x_line_tbl(I).ordered_quantity := (-1) *
                                           p_x_line_tbl(I).ordered_quantity;
      END IF;

      -- Change the same on the OLD record.
      IF p_x_old_line_tbl.EXISTS(I) THEN
          IF p_x_old_line_tbl(I).ordered_quantity < 0 AND
           ( p_x_old_line_tbl(I).line_category_code IS NULL OR
             p_x_old_line_tbl(I).line_category_code = FND_API.G_MISS_CHAR OR
             p_x_old_line_tbl(I).line_category_code = 'RETURN')
          THEN
              p_x_old_line_tbl(I).line_category_code := 'RETURN';
              p_x_old_line_tbl(I).ordered_quantity := (-1) *
                                           p_x_old_line_tbl(I).ordered_quantity;
          END IF;

      END IF;

      --Added for bug 4937633 source type for Internal orders will be Internal
      IF  p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE THEN

		IF p_x_line_tbl(I).source_document_type_id = 10
                OR oe_order_cache.g_header_rec.source_document_type_id = 10 THEN
	           p_x_line_tbl(I).source_type_code := OE_GLOBALS.G_SOURCE_INTERNAL;
		END IF;
      END IF;
      --Added for bug 4937633 end

      l_line_rec := p_x_line_tbl(I);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH ARR DATE='||L_LINE_REC.SCHEDULE_ARRIVAL_DATE ) ;
      END IF;

      -- Load old records
      IF p_x_old_line_tbl.EXISTS(I) THEN
        l_old_line_rec := p_x_old_line_tbl(I);
      ELSE
        l_old_line_rec := OE_Order_PUB.G_MISS_LINE_REC;
      END IF;

      IF l_old_line_rec.line_id = FND_API.G_MISS_NUM OR
         l_old_line_rec.line_id IS NULL
      THEN

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       => l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          => l_line_rec.source_document_id
         ,p_source_document_line_id     => l_line_rec.source_document_line_id
         ,p_order_source_id             => l_line_rec.order_source_id
         ,p_source_document_type_id     => l_line_rec.source_document_type_id);

      ELSE

        OE_MSG_PUB.set_msg_context
        ( p_entity_code             => 'LINE'
         ,p_entity_id               => l_old_line_rec.line_id
         ,p_header_id               => l_old_line_rec.header_id
         ,p_line_id                 => l_old_line_rec.line_id
         ,p_orig_sys_document_ref   => l_old_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_old_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_old_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             => l_old_line_rec.change_sequence
         ,p_source_document_id      => l_old_line_rec.source_document_id
         ,p_source_document_line_id => l_old_line_rec.source_document_line_id
         ,p_order_source_id         => l_old_line_rec.order_source_id
         ,p_source_document_type_id => l_old_line_rec.source_document_type_id);

      END IF;


      --  Set Save Point
      IF p_control_rec.Process_Partial THEN
        SAVEPOINT Lines;
      END IF;

      -- Fixed bug# 1362872: Removed code to set return_status to SUCCESS on
      -- the records as it was overwriting error statuses.
      -- The return_status is set at the end of the loop and in the case
      -- of errors, it is set in the exception handlers.

      --  Prepare record.

      IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OPERATION = CREATE SO SETTING OLD TO NULL' , 2 ) ;
        END IF;

        l_line_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        OE_Line_Util.Convert_Miss_To_Null (l_old_line_rec);

        -- Lock the order header for unbooked orders: This would prevent order
        -- lines from being inserted on an order when it is being booked
        -- as the booking process also locks the order header.

/*******
        IF l_header_locked = FND_API.G_MISS_CHAR THEN
          oe_debug_pub.add('locking the header record');

          SAVEPOINT Header_Lock;

          OE_Header_Util.Lock_Row
               ( p_header_id      => l_line_rec.header_id
               , x_return_status  => l_return_status
               , p_x_header_rec   => l_locked_header_rec);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_locked_header_rec.booked_flag = 'N' THEN
            l_header_locked := 'Y';
          ELSE
            l_header_locked := 'N';
            ROLLBACK TO Header_Lock;
          END IF;

        END IF;
*******/

      ELSIF l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE OR
            l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE
      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OPERATION = UPDATE SO QUERY OLD' , 1 ) ;
        END IF;

        l_line_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_line_rec.line_id = FND_API.G_MISS_NUM OR
            l_old_line_rec.line_id IS NULL
        THEN

          OE_Line_Util.Query_Row
          (   p_line_id                     => l_line_rec.line_id
          ,   x_line_rec                    => l_old_line_rec );

          -- Only for lines we are reassiging queried line into old tbl
          -- to avoid requery.
          p_x_old_line_tbl(I) := l_old_line_rec;

        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Before convert_miss_to_null'||l_old_line_rec.reserved_quantity , 1 ) ;
          END IF;
          --  Set missing old record elements to NULL.
          OE_Line_Util.Convert_Miss_To_Null (l_old_line_rec);

        END IF;
-- Reverting Changes(done for bug9654935) For bug 10207400
        /*Starting changes for bug 9654935 */
  --        IF l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
  --            l_old_line_rec.reserved_quantity := NULL;
  --        END IF;
        /*Ending changes for bug 9654935 */
        --  Complete new record from old

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPLETE NEW RECORD FROM OLD' , 1 ) ;
        END IF;

        OE_Line_Util.Complete_Record
        (   p_x_line_rec                  => l_line_rec
           ,p_old_line_rec                => l_old_line_rec);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER COMPLETE NEW RECORD FROM OLD' , 2 ) ;
        END IF;

        OE_MSG_PUB.update_msg_context
        ( p_entity_code             => 'LINE'
         ,p_entity_id               => l_line_rec.line_id
         ,p_header_id               => l_line_rec.header_id
         ,p_line_id                 => l_line_rec.line_id
         ,p_order_source_id         => l_line_rec.order_source_id
         ,p_orig_sys_document_ref   => l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_line_rec.orig_sys_line_ref
         ,p_source_document_type_id     => l_line_rec.source_document_type_id
         ,p_source_document_id      => l_line_rec.source_document_id
         ,p_source_document_line_id => l_line_rec.source_document_line_id );

        IF OE_Code_Control.code_release_level >= '110510'
           AND  NVL(FND_PROFILE.VALUE('ONT_3A7_RESPONSE_REQUIRED'), 'N') = 'Y'
           -- Added this check because, holds will be applied only when this profile is set to 'YES'.
           AND  l_line_rec.order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
           AND nvl(l_line_rec.xml_transaction_type_code, FND_API.G_MISS_CHAR)
                 IN (OE_Acknowledgment_Pub.G_TRANSACTION_CHO,OE_Acknowledgment_Pub.G_TRANSACTION_CPO) THEN -- 3A8/3A9

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Calling OE_Acknowledgment_PUB.Process_3A8 for transaction type: '|| l_line_rec.xml_transaction_type_code, 2 ) ;
           END IF;
           OE_Acknowledgment_PUB.Process_3A8
                      (  p_x_line_rec           => l_line_rec
                      ,  p_old_line_rec         => l_old_line_rec
                      ,  x_return_status        => l_return_status
                      );
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Return status after call to Process_3A8:' || l_return_status, 2 ) ;
           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

      END IF; -- if operation is create.

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AT LINE LEVEL HEADER_ID' || L_LINE_REC.HEADER_ID , 2 ) ;
      END IF;
      IF I = p_x_line_tbl.FIRST THEN
        IF NOT Valid_Upgraded_Order(l_line_rec.header_id) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- Lock the order header for unbooked orders: This would prevent order
      -- lines from being inserted on an order when it is being booked
      -- as the booking process also locks the order header.
      -- The g_booked_flag should have been set by the call to
      -- Valid_Upgraded_Order before.

      IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
         -- QUOTING changes
         -- Comment out booked flag check, move header locked
         -- check inside this IF statement.
        IF l_header_locked = FND_API.G_MISS_CHAR THEN -- AND g_booked_flag = 'N' THEN #2940426

        -- Lock only if the po is called by UI or
        -- with write_to_db flag , this way for validate_only
        -- don't lock.

        IF (OE_GLOBALS.G_UI_FLAG  AND
          NOT (OE_GLOBALS.G_HTML_FLAG))  OR
          p_control_rec.write_to_db THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOCKING THE HEADER RECORD' ) ;
          END IF;

          OE_Header_Util.Lock_Row
          ( p_header_id          => l_line_rec.header_id
           ,x_return_status      => l_return_status
           ,p_x_header_rec       => l_locked_header_rec);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_header_locked := 'Y';
        END IF; -- UI flag

        END IF; -- if header locked check

        -- QUOTING changes
        -- Initialize line transaction phase from locked header rec
        l_line_rec.transaction_phase_code :=
               l_locked_header_rec.transaction_phase_code;

      END IF; -- opr = create and hdr locked etc.


      ------------- lines loop starts ------------------------------

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM TYPE :'||P_X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
      END IF;

      l_check_item_type := Check_Item_Type(l_line_rec,I);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECK_ITEM_TYPE RETURNS :'||L_CHECK_ITEM_TYPE ) ;
      END IF;



      IF (l_mode = 'MODELS_AND_STANDARD') AND
          l_check_item_type = 1 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_MODE IS MODELS_AND_STANDARD' , 1 ) ;
        END IF;

        IF OE_Config_Util.G_Config_UI_Used = 'N' AND
           l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           ((l_line_rec.top_model_line_index is NOT NULL AND
             l_line_rec.top_model_line_index <> FND_API.G_MISS_NUM) OR
            (l_line_rec.top_model_line_id is NOT NULL AND
             l_line_rec.top_model_line_id <> FND_API.G_MISS_NUM)) AND
             (l_line_rec.split_from_line_id is NULL OR
              l_line_rec.split_from_line_id = FND_API.G_MISS_NUM)
        THEN
           -- bug 3286378
           IF l_line_rec.inventory_item_id IS NULL THEN
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'No Item at the line' , 1 ) ;
              END IF;
              p_x_line_tbl(I).component_code := null;
              p_x_line_tbl(I).component_sequence_id := null;
              p_x_line_tbl(I).sort_order     := null;
           ELSIF NOT OE_GLOBALS.EQUAL(l_line_rec.inventory_item_id,
                                      l_old_line_rec.inventory_item_id) THEN
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Line Item is Changed '
                                   ||l_line_rec.inventory_item_id , 1 ) ;
              END IF;

              BEGIN
                IF l_old_line_rec.inventory_item_id is NOT NULL THEN
                   SELECT bom_item_type
                   INTO   l_bom_item_type
                   FROM   mtl_system_items
                   WHERE  inventory_item_id = l_line_rec.inventory_item_id
                   AND    organization_id
                   = OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

                   IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('old Line Item exists '
                                     ||l_bom_item_type, 1);
                   END IF;

                ELSE
                   l_bom_item_type := 1;
                END IF;
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('BOM ITEM TYPE : '||l_bom_item_type, 1);
                 END IF;

                 IF l_bom_item_type = 1 THEN
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'CALLING Complete_Config_Line' ,1);
                       oe_debug_pub.add
                       ('comp seq id '||l_line_rec.component_sequence_id,1);
                    END IF;

                    l_line_rec.component_code := null;
                    l_line_rec.component_sequence_id := null;
                    l_line_rec.sort_order     := null;

                    Complete_Config_Line
                      ( p_x_line_rec     =>  l_line_rec
                       ,p_item_type      =>  1
                       ,p_x_line_tbl     =>  p_x_line_tbl);

                    p_x_line_tbl(I).component_code
                         := l_line_rec.component_code;
                    p_x_line_tbl(I).component_sequence_id
                         := l_line_rec.component_sequence_id;
                    p_x_line_tbl(I).sort_order     := l_line_rec.sort_order;
                 ELSE
                    IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'Setting Component code to Null',1);
                    END IF;
                    p_x_line_tbl(I).component_code := null;
                    p_x_line_tbl(I).component_sequence_id := null;
                    p_x_line_tbl(I).sort_order     := null;
                 END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Did not get any bom item type',1);
                    END IF;
                    --RAISE FND_API.G_EXC_ERROR;
                    RAISE;
              END;
           END IF;
        END IF;

        l_process_this_line := TRUE;

      END IF; -- mode is standard.


      ----------------------  mode is options ----------------------
      IF (l_mode = 'OPTIONS') AND
          l_check_item_type = 2 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_MODE IS OPTIONS' , 1 ) ;
        END IF;

        IF nvl(l_line_rec.semi_processed_flag, FALSE) = TRUE THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS ALREADY PROCESSED , GOTO END..' , 1 ) ;
          END IF;
          GOTO end_of_lines_loop;
        END IF;

        l_process_this_line := TRUE;

        -- If the line has top_model_line_index, populate it's
        -- top_model_line_id from p_x_line_tbl(top_model_line_index).line_id
        -- note that the top most model line will get its top_model_line_id in
        -- hardcoded defaulting and since we process models before options,
        -- model should already have the top model line id.

        IF ((l_line_rec.top_model_line_index <> FND_API.G_MISS_NUM) AND
            (l_line_rec.top_model_line_index IS NOT NULL))
        THEN
          l_top_model_line_index := l_line_rec.top_model_line_index;

          IF p_x_line_tbl.EXISTS(l_top_model_line_index) THEN

            IF (l_line_rec.top_model_line_id = FND_API.G_MISS_NUM) OR
               (l_line_rec.top_model_line_id IS NULL) THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'MODEL:'||P_X_LINE_TBL ( L_TOP_MODEL_LINE_INDEX ) .RETURN_STATUS ) ;
              END IF;


              IF p_x_line_tbl(l_top_model_line_index).return_status =
                           FND_API.G_RET_STS_SUCCESS THEN

                l_line_rec.top_model_line_id :=
                           p_x_line_tbl(l_top_model_line_index).line_id;

                p_x_line_tbl(I).top_model_line_id := l_line_rec.top_model_line_id;

              ELSE
                IF p_x_line_tbl(l_top_model_line_index).return_status IS NULL
                THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'TOP MODEL RETURN STATUS IS NULL' , 1 ) ;
                  END IF;
                END IF;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'TOP MODEL LINE PROCESSED WITH ERRORS' , 1 ) ;
                END IF;

                GOTO end_of_lines_loop;
              END IF; -- ret sts success

            END IF;


          ELSE -- Invalid Index
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INVALID LINE INDEX ' , 2 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;  -- if valid index, top model is not at the index

        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'MODE IS OPTIONS BUT NO TOP MODEL LINE INDEX??' , 1 ) ;
          END IF;
        END IF; -- if top model line index is populated

        -- if it comes here, everything was OK. ---------

        IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           (nvl(l_line_rec.item_type_code, 'A') <> OE_GLOBALS.G_ITEM_INCLUDED
            AND
            nvl(l_line_rec.item_type_code, 'A') <> OE_GLOBALS.G_ITEM_CONFIG)
        THEN

          IF COMPLETE_AND_CLASS_SAVE_MODE THEN

            IF OE_Config_Util.G_Config_UI_Used = 'N' AND
               (l_line_rec.split_from_line_id is NULL OR
                l_line_rec.split_from_line_id = FND_API.G_MISS_NUM) AND
               (l_line_rec.top_model_line_index is NOT NULL AND
                l_line_rec.top_model_line_index <> FND_API.G_MISS_NUM)
            THEN

              Complete_Config_Line
              ( p_x_line_rec       =>  l_line_rec
               ,p_item_type        =>  2
               ,p_x_line_tbl       =>  p_x_line_tbl
               ,p_process_partial  =>  p_control_rec.process_partial);

               p_x_line_tbl(I).component_code := l_line_rec.component_code;
               p_x_line_tbl(I).component_sequence_id
                                       := l_line_rec.component_sequence_id;
               p_x_line_tbl(I).sort_order     := l_line_rec.sort_order;
               p_x_line_tbl(I).order_quantity_uom
                                       := l_line_rec.order_quantity_uom;
               p_x_line_tbl(I).operation      := l_line_rec.operation;
               p_x_line_tbl(I).return_status  := l_line_rec.return_status;

            END IF;

            IF nvl(l_line_rec.item_type_code, 'A') <> OE_GLOBALS.G_ITEM_CLASS
            THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NOT A CLASS , SKIP' , 3 ) ;
              END IF;

              IF l_line_rec.split_from_line_id is NULL THEN
                J := J + 1;
                l_options_index_tbl(J) := I;
              END IF;

              l_process_this_line   := FALSE;
            END IF;

          ELSE -- now saving options -- may not req.

            IF nvl(l_line_rec.item_type_code, 'A') = OE_GLOBALS.G_ITEM_CLASS
            THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'THIS CLASS IS ALREADY SAVED' , 3 ) ;
              END IF;
              l_process_this_line   := FALSE;
            END IF;

          END IF; -- complete mode check

        END IF; -- operation = create

        -- this is important in case of the recursive calls.

        IF l_line_rec.top_model_line_id is NOT NULL THEN
          l_line_rec.top_model_line_index       := NULL;
          p_x_line_tbl(I).top_model_line_index  := NULL;
        END IF;
      END IF; -- if mode is option


      ----------------------  mode is service ----------------------

      IF (l_mode = 'SERVICE') AND
          l_check_item_type = 3 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JPN: MODE IS SERVICE' ) ;
        END IF;
        l_process_this_line := TRUE;

        IF  ((l_line_rec.service_line_index <> FND_API.G_MISS_NUM) AND
             (l_line_rec.service_line_index IS NOT NULL))
        THEN
          l_service_line_index := l_line_rec.service_line_index;

          -- If the line has service_line_index, populate it's
          -- service_reference_line_id from the
          -- p_x_line_tbl(service_line_index).line_id

          IF p_x_line_tbl.EXISTS(l_service_line_index) THEN
            IF (l_line_rec.service_reference_line_id = FND_API.G_MISS_NUM)
                OR (l_line_rec.service_reference_line_id IS NULL) THEN

              IF p_x_line_tbl(l_service_line_index).return_status =
                FND_API.G_RET_STS_SUCCESS THEN
            -- lchen added to check parent line operation to fix bug 2017271
                 IF p_x_line_tbl(l_service_line_index).operation = OE_GLOBALS.G_OPR_NONE
                 THEN
                   GOTO end_of_lines_loop;
                 ELSE
                l_line_rec.service_reference_line_id :=
                               p_x_line_tbl(l_service_line_index).line_id;
                  END IF; /* operation = none */

              ELSE
                GOTO end_of_lines_loop;
              END IF;

            END IF;
          ELSE -- Invalid Index
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INVALID SERVICE LINE INDEX ' , 2 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;  -- If Valid Line Index

        END IF;

      END IF; -- end of service.



      IF l_process_this_line = FALSE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'MODE AND ITEM TYPE DOES NOT MATCH , GO TO END' , 1 ) ;
        END IF;

        l_line_rec.semi_processed_flag      := FALSE;
        p_x_line_tbl(I).semi_processed_flag := FALSE;
        GOTO end_of_lines_loop;

      ELSE

        l_line_rec.semi_processed_flag      := TRUE;
        p_x_line_tbl(I).semi_processed_flag := TRUE;
        l_num_lines                         := l_num_lines - 1;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  L_NUM_LINES|| ' '||L_LINE_REC.ITEM_TYPE_CODE||L_LINE_REC.LINE_ID , 1 ) ;
        END IF;

      END IF; -- to process the line or not



      --  Load old records.

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'STARTING LINE LOOP. HEADER_ID = '|| TO_CHAR ( L_LINE_REC.HEADER_ID ) , 2 ) ;
                        END IF;

      --  Load API control record

      l_control_rec := OE_GLOBALS.Init_Control_Rec
                      ( p_operation     => l_line_rec.operation
                       ,p_control_rec   => p_control_rec);


      OE_LINE_UTIL.Pre_Attribute_Security(p_x_line_rec   => l_line_rec
                                         ,p_old_line_rec => l_old_line_rec
                                         ,p_index        => I  );

      -- CHECK SECURITY

      IF l_control_rec.check_security AND
         (l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
          l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ATTRIBUTES SECURITY' , 1 ) ;
        END IF;
        -- check if this operation is allowed on all the changed attributes
        OE_Line_Security.Attributes
        ( p_line_rec        => l_line_rec
         ,p_old_line_rec    => l_old_line_rec
         ,x_result          => l_sec_result
         ,x_return_status   => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- if operation on any attribute is constrained
        IF l_sec_result = OE_PC_GLOBALS.YES THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- security


      -- ATTRIBUTE LEVEL VALIDATION

      IF NOT (l_line_rec.operation = oe_globals.g_opr_create and
             (l_line_rec.split_from_line_id IS NOT NULL AND
              l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM))
      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ATTRIBUTE VALIDATION' , 1 ) ;
        END IF;

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

          OE_Validate_Line.Attributes
          ( x_return_status               => l_return_status
           ,p_x_line_rec                  => l_line_rec
           ,p_old_line_rec                => l_old_line_rec
           ,p_validation_level            => p_validation_level);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER ATTRIBUTE VALIDATION' , 1 ) ;
          END IF;

          IF p_validation_level <> OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

        END IF; -- end of check to see if validation level > NONE

      END IF; -- validation


      --  CLEAR DEPENDENT ATTRIBUTES

      IF  l_control_rec.clear_dependents AND
      NOT (l_line_rec.operation = oe_globals.g_opr_create and
          (l_line_rec.split_from_line_id IS NOT NULL AND
           l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM))
      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CLEAR DEPENDENT ATTRIBUTES' , 1 ) ;
        END IF;

        OE_Line_Util_Ext.Clear_Dependent_Attr
        ( p_x_line_rec                  => l_line_rec
         ,p_old_line_rec                => l_old_line_rec );

      END IF;


      --  DEFAULT MISSING ATTRIBUTES

      IF (l_control_rec.default_attributes) THEN
        IF NOT (l_line_rec.operation = oe_globals.g_opr_create and
               (l_line_rec.split_from_line_id IS NOT NULL AND
                l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM))
        THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DEFAULT MISSING' , 1 ) ;
          END IF;

          OE_Default_Line.Attributes
          ( p_x_line_rec                  => l_line_rec
           ,p_old_line_rec                => l_old_line_rec);

        ELSE

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SPLIT:DEFAULT ATTRIBUTES ' , 1 ) ;
          END IF;
          OE_Split_Util.Default_Attributes
          ( p_x_line_rec                  => l_line_rec
           ,p_old_line_rec                => l_old_line_rec);

        END IF;

      END IF; -- default missing


      -- APPLY ATTRIBUTE CHANGES

      IF  (l_control_rec.change_attributes)
           -- AND NOT (l_line_rec.operation = oe_globals.g_opr_create and
           --  (l_line_rec.split_from_line_id IS NOT NULL AND
           --  l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM))
      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'APPLY ATTRIBUTE CHANGES' , 2 ) ;
        END IF;

        OE_Line_Util.Apply_Attribute_Changes
        ( p_x_line_rec                  => l_line_rec
         ,p_old_line_rec                => l_old_line_rec );

        IF l_line_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_line_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;


      --  Entity level validation.

      IF l_control_rec.validate_entity
         AND NOT (l_line_rec.operation = oe_globals.g_opr_create and
                 (l_line_rec.split_from_line_id IS NOT NULL AND
                  l_line_rec.split_from_line_id <> FND_API.G_MISS_NUM))
         and( nvl(l_line_rec.ordered_quantity,-1)<>0
             OR Nvl(l_line_rec.cancelled_flag,'N')='N' ) -- added for bug 6494347
/*Added the cancelled flag check for bug 7691604*/

      /*Added nvl condition in the above check for ordered_quantity for bug 7475111.
      If there is no nvl, if the ordered quantity is null, even then validation will not
      be performed on the line. */

      THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'VALIDATE ENTITY' , 2 ) ;
        END IF;

        IF l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

          OE_Validate_Line.Entity_Delete
          ( x_return_status               => l_return_status
           ,p_line_rec                    => l_line_rec );

        ELSE

          OE_Validate_Line.Entity
          ( x_return_status               => l_return_status
           ,p_line_rec                    => l_line_rec
           ,p_old_line_rec                => l_old_line_rec
           ,p_validation_level            => p_validation_level);

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- entity validation


      -- Fixed bug 1647143: Entity security check should be before
      -- pre_write_process. This is important for DELETEs as the
      -- constraints check should fire before other events like
      -- unscheduling are fired in pre_write_process

      -- Check entity level security as some attributes may have
      -- changed due to defaulting or scheduling
      -- For UPDATE operations, entity security checks for constraints setup
      -- with a NULL column i.e. the constraint restricts update on ANY of
      -- the columns.
      -- However, this check should NOT be done if user did not try to update
      -- any of the constrainable attributes and also none of the defaulted
      -- attributes was constrainable!. In such a case, the g_check_all_cols
      -- _constraint flag would still be 'Y' as the flag is reset only
      -- when checking for constraints.

      IF NOT (l_line_rec.operation  = OE_GLOBALS.G_OPR_UPDATE AND
         OE_Line_Security.g_check_all_cols_constraint = 'Y') AND
         l_control_rec.check_security THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ENTITY SECURITY' , 2 ) ;
        END IF;

        OE_Line_Security.Entity
        ( p_line_rec        => l_line_rec
         ,x_result          => l_sec_result
         ,x_return_status   => l_return_status );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- if operation on any attribute is constrained
        IF l_sec_result = OE_PC_GLOBALS.YES THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'STATUS' || L_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
      END IF;

      --  Step 3.5. Perform action which need to be performed before
      --            writing to the DB (like Scheduling).

      IF l_control_rec.write_to_db THEN

        OE_LINE_UTIL.PRE_WRITE_PROCESS
        ( p_x_line_rec      => l_line_rec
         , p_old_line_rec    => l_old_line_rec);
      END IF;

      --  Step 4. Write to DB

      IF l_control_rec.write_to_db THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'WRITE TO DB' , 1 ) ;
         END IF;

        IF l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
           OE_Line_Util.Delete_Row
          ( p_line_id   => l_line_rec.line_id);

          -- If an OTA line has been deleted, then call the OTA API
          -- to delete the event in the OTA tables

          l_order_quantity_uom := l_line_rec.order_quantity_uom;
          l_is_ota_line     := OE_OTA_UTIL.Is_OTA_Line(l_order_quantity_uom);

          If (l_is_ota_line) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE IS OF OTA TYPE' , 1 ) ;
            END IF;
            OE_OTA_UTIL.Notify_OTA
            ( p_line_id            => l_line_rec.line_id
             ,p_org_id             => l_line_rec.org_id
             ,p_order_quantity_uom => l_order_quantity_uom
             ,p_daemon_type        => 'D'
             ,x_return_status      => l_return_status );

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER NOTIFY_OTA API' , 1 ) ;
            END IF;
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF; --End of OTA processing

        ELSE -- operation is update or create

          --  Get Who Information

          l_line_rec.last_update_date    := SYSDATE;
          l_line_rec.last_updated_by     :=  NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
          l_line_rec.last_update_login   := FND_GLOBAL.LOGIN_ID;
          l_user_id                      := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
          l_resp_id                      := FND_GLOBAL.RESP_ID;
          l_application_id               := FND_GLOBAL.RESP_APPL_ID;

          IF l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CALLING UPDATE ROW' , 1 ) ;
            END IF;

            OE_Line_Util.Update_Row (l_line_rec);

          ELSIF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_line_rec.creation_date       := SYSDATE;
            l_line_rec.created_by          := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  '3.STATUS '||L_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
            END IF;

            OE_Line_Util.Insert_Row (l_line_rec);

          END IF;

        END IF; -- operation = delete

        -- Post Db Processes
        Oe_Line_Util.Post_Write_Process
        (p_x_line_rec      => l_line_rec,
         p_old_line_rec    => l_old_line_rec );

      END IF; -- write to db true

      --  loop exception handler.
      IF l_line_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_line_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --  Load tables.

      l_line_rec.return_status            := FND_API.G_RET_STS_SUCCESS;
      p_x_line_tbl(I)                     := l_line_rec;
      p_x_old_line_tbl(I)                 := l_old_line_rec;
      p_x_line_tbl(I).semi_processed_flag := l_process_this_line;

      IF p_x_line_tbl(I).semi_processed_flag THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  I || ' SEMI PROCESSED FLAG SET ' , 1 ) ;
        END IF;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BOTTOM OF LINE LOOP' , 2 ) ;
      END IF;

      OE_Line_Security.g_check_all_cols_constraint := 'Y';
      OE_MSG_PUB.reset_msg_context('LINE');

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCH ARRIVAL_DATE='||L_LINE_REC.SCHEDULE_ARRIVAL_DATE ) ;
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        x_return_status:= FND_API.G_RET_STS_ERROR;
        l_line_rec.return_status            := FND_API.G_RET_STS_ERROR;
        p_x_line_tbl(I)                     := l_line_rec;
        p_x_line_tbl(I).semi_processed_flag := l_process_this_line;
        p_x_old_line_tbl(I)                 := l_old_line_rec;

        OE_Line_Security.g_check_all_cols_constraint := 'Y';

        -- if process partial flag is set to true this would
        -- continue processing else exit out of loop

        IF l_control_rec.Process_Partial THEN

          -- Raise error when one of the lines in a SET fails
          -- while copying.
          IF l_line_rec.source_document_type_id = 2 AND
             l_line_rec.line_set_id IS NOT NULL AND
             l_line_rec.OPERATION = OE_GLOBALS.G_OPR_CREATE
          THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


          IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'DELETE REQUEST8' , 2 ) ;
            END IF;

            oe_delayed_requests_pvt.Delete_Reqs_for_Deleted_Entity
            (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE,
             p_entity_id     => l_line_rec.line_id,
             x_return_status => l_return_status);
          END IF;

          ROLLBACK TO SAVEPOINT Lines;

        ELSE
          RAISE FND_API.G_EXC_ERROR ;
        END IF; -- process partial = true


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
        l_line_rec.return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_line_tbl(I)                     := l_line_rec;
        p_x_line_tbl(I).semi_processed_flag := l_process_this_line;
        p_x_old_line_tbl(I)                 := l_old_line_rec;


        OE_MSG_PUB.reset_msg_context('LINE');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


      WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        l_line_rec.return_status       := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_line_tbl(I)                := l_line_rec;
        p_x_line_tbl(I).semi_processed_flag := l_process_this_line;
        p_x_old_line_tbl(I)            := l_old_line_rec;


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
             ,'Lines' );
        END IF;

        OE_Line_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('LINE');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END; -- of the big BEGIN with the WHILE



    ---------------- switch modes ---------------------------

    <<end_of_lines_loop>>

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO. OF LINES TO PROCESS ' || L_NUM_LINES , 1 ) ;
    END IF;

    I := p_x_line_tbl.NEXT(I);

    IF (l_mode = 'MODELS_AND_STANDARD') AND (I IS NULL)
    THEN
       I := p_x_line_tbl.FIRST;
       l_mode := 'OPTIONS';
       COMPLETE_AND_CLASS_SAVE_MODE := TRUE;

    ELSIF (l_mode = 'OPTIONS')AND (I IS NULL)
    THEN

       I := p_x_line_tbl.FIRST;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO. OF SKIPPED OPTIONS ' || L_OPTIONS_INDEX_TBL.COUNT , 1 ) ;
       END IF;

       IF COMPLETE_AND_CLASS_SAVE_MODE AND l_num_lines > 0 THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'COMPLETE MODE WAS TRUE' , 3 ) ;
         END IF;
         COMPLETE_AND_CLASS_SAVE_MODE := FALSE;

         IF OE_Config_Util.G_Config_UI_Used = 'N' AND
            l_options_index_tbl.COUNT > 0
         THEN

           Get_Missing_Class_Lines
           ( p_x_line_tbl          => p_x_line_tbl
            ,p_options_index_tbl   => l_options_index_tbl
            ,x_class_index         => l_class_index
            ,x_class_count         => l_class_count);

           l_options_index_tbl.DELETE;

           IF l_class_index is NOT NULL THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NEW CLASSES ADDED' , 3 ) ;
              END IF;

              COMPLETE_AND_CLASS_SAVE_MODE := TRUE;

              l_num_lines := l_num_lines + l_class_count;
              I := l_class_index;
           END IF;

         END IF;
       ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'MODE IS SERVICE NOW' , 3 ) ;
         END IF;
         l_mode := 'SERVICE';
       END IF;

    END IF; -- end mode switch

  END LOOP; -- end of the big WHILE LOOP


  -- New event has been created to handle post line loop issues.

  OE_LINE_UTIL.Post_Line_Process
  (p_control_rec   => l_control_rec,
   p_x_line_tbl    => p_x_line_tbl);


  Print_Time('Exiting OE_ORDER_PVT.LINES');

  OE_MSG_PUB.reset_msg_context('LINE');

  set_recursion_mode(p_Entity_Code => 5,
                                   p_In_out  => 0);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
    OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
    x_return_status  := FND_API.G_RET_STS_ERROR;
    set_recursion_mode(p_Entity_Code => 5,
                                   p_In_out  => 0);
    OE_MSG_PUB.reset_msg_context('LINE');


    IF NOT (OE_GLOBALS.G_UI_FLAG) AND line_ctr = 1 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETE REQUEST9' , 2 ) ;
      END IF;
      oe_delayed_requests_pvt.Clear_Request
      (x_return_status => l_return_status);

       IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN --  for the bug 3726337
                OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
                END IF;
       ROLLBACK TO SAVEPOINT Lines_Non_Partial;
	-- Bug 2801876
	-- This condition would be  true only when the process order
        -- is called with proecs partial flag and the error comes out
	-- of the post line process. This is same as an error coming
        -- out of delayed requests and hence we should raise and not continue.

	IF l_control_rec.Process_Partial THEN
	RAISE FND_API.G_EXC_ERROR;
	END IF;

    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
    OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    set_recursion_mode(p_Entity_Code => 5,
                                   p_In_out  => 0);

    OE_MSG_PUB.reset_msg_context('LINE');

    IF NOT (OE_GLOBALS.G_UI_FLAG) and line_ctr = 1 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETE REQUEST10' , 2 ) ;
      END IF;
      oe_delayed_requests_pvt.Clear_Request
      (x_return_status => l_return_status);

       IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN --  for the bug 3726337
                OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
                END IF;
      ROLLBACK TO SAVEPOINT Lines_Non_Partial;

	-- Same as comments give above for exc error
	-- Bug 2801876

	IF l_control_rec.Process_Partial THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;

  WHEN OTHERS THEN
    OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
    OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

    IF NOT (OE_GLOBALS.G_UI_FLAG) and line_ctr = 1 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETE REQUEST11' , 2 ) ;
      END IF;
      oe_delayed_requests_pvt.Clear_Request
      (x_return_status => l_return_status);

      IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN -- for the bug 3726337
	 OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
      END IF;
      ROLLBACK TO SAVEPOINT Lines_Non_Partial;
    END IF;
    set_recursion_mode(p_Entity_Code => 5,
                                   p_In_out  => 0);

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
       ,'Lines');
    END IF;

    OE_MSG_PUB.reset_msg_context('LINE');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lines;


/*----------------------------------------------------------------------
PROCEDURE Line_Scredits
-----------------------------------------------------------------------*/

PROCEDURE Line_Scredits
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_old_Line_Scredit_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_Scredit_rec            OE_Order_PUB.Line_Scredit_Rec_Type;
l_old_Line_Scredit_rec        OE_Order_PUB.Line_Scredit_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I                       NUMBER; -- Used as index.
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id        NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id number ;
BEGIN
    --MOAC changes start
    l_org_id := MO_GLOBAL.get_current_org_id;
    IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
    --MOAC changes end
    set_recursion_mode(p_Entity_Code => 7,
                                   p_In_out  => 1);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    IF p_control_rec.Process_Partial THEN
     	SAVEPOINT Line_Scredits;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.LINE_SCREDITS' , 1 ) ;
    END IF;

    --    FOR I IN 1..p_x_Line_Scredit_tbl.COUNT LOOP

    I := p_x_Line_Scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_Scredit_rec := p_x_Line_Scredit_tbl(I);

        IF p_x_old_Line_Scredit_tbl.EXISTS(I) THEN
            l_old_Line_Scredit_rec := p_x_old_Line_Scredit_tbl(I);
        ELSE
            l_old_Line_Scredit_rec := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
        END IF;
        if l_old_line_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM  Then
           IF l_line_Scredit_rec.line_id IS NOT NULL AND
              l_line_Scredit_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_line_Scredit_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_line_Scredit_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_SCREDIT'
  		,p_entity_id         		=> l_line_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_line_Scredit_rec.header_id
    		,p_line_id           		=> l_line_Scredit_rec.line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        else
           IF l_old_line_Scredit_rec.line_id IS NOT NULL AND
              l_old_line_Scredit_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old line_id:'||l_old_line_Scredit_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_old_line_Scredit_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_SCREDIT'
  		,p_entity_id         		=> l_old_line_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_old_line_Scredit_rec.header_id
    		,p_line_id           		=> l_old_line_Scredit_rec.line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        end if;


        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_Scredit_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_Scredit_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            OE_Line_Scredit_Util.Convert_Miss_To_Null (l_old_Line_Scredit_rec);

        ELSIF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_Scredit_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_Scredit_rec.sales_credit_id = FND_API.G_MISS_NUM
            THEN

                OE_Line_Scredit_Util.Query_Row
                (   p_sales_credit_id        => l_Line_Scredit_rec.sales_credit_id
			 ,   x_line_scredit_rec       => l_old_Line_Scredit_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

                OE_Line_Scredit_Util.Convert_Miss_To_Null (l_old_Line_Scredit_rec);

            END IF;

            --  Complete new record from old

            OE_Line_Scredit_Util.Complete_Record
            (   p_x_Line_Scredit_rec          => l_Line_Scredit_rec
            ,   p_old_Line_Scredit_rec        => l_old_Line_Scredit_rec
            );

           OE_MSG_PUB.update_msg_context(
		 p_entity_code			=> 'LINE_SCREDIT'
  		,p_entity_id         		=> l_line_Scredit_rec.sales_credit_id
    		,p_header_id         		=> l_line_Scredit_rec.header_id
    		,p_line_id           		=> l_line_Scredit_rec.line_id);

        END IF;

        IF I = p_x_line_scredit_tbl.FIRST THEN
	       IF NOT Valid_Upgraded_Order(l_line_scredit_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_line_scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_line_scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ATTRIBUTES SECURITY' ) ;
        END IF;

           OE_Line_Scredit_Security.Attributes
                (p_line_scredit_rec   	=> l_line_scredit_rec
                , p_old_line_scredit_rec	=> l_old_line_scredit_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Line_Scredit.Attributes
                (   x_return_status               => l_return_status
                ,   p_Line_Scredit_rec            => l_Line_Scredit_rec
                ,   p_old_Line_Scredit_rec        => l_old_Line_Scredit_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            --  Clear dependent attributes.
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' CLEAR DEPENDENT' || L_LINE_SCREDIT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.clear_dependents THEN

            OE_Line_Scredit_Util.Clear_Dependent_Attr
            (   p_x_Line_Scredit_rec          => l_Line_Scredit_rec
            ,   p_old_Line_Scredit_rec        => l_old_Line_Scredit_rec
            );

        END IF;

        --  Default missing attributes
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' DEFAULTING' || L_LINE_SCREDIT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.default_attributes
        THEN

            OE_Default_Line_Scredit.Attributes
            (   p_x_Line_Scredit_rec          => l_Line_Scredit_rec
	    ,   p_old_line_scredit_rec        => l_old_line_Scredit_Rec
            );

        END IF;

        --  Apply attribute changes
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' APPLY ATTRIBUTES' || L_LINE_SCREDIT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.change_attributes
        THEN

            OE_Line_Scredit_Util.Apply_Attribute_Changes
            (   p_x_Line_Scredit_rec          => l_Line_Scredit_rec
            ,   p_old_Line_Scredit_rec        => l_old_Line_Scredit_rec
            );

        END IF;

        --  Entity level validation.
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' ENTITY VALIDATION ' || L_LINE_SCREDIT_REC.HEADER_ID ) ;
		 END IF;

        IF l_control_rec.validate_entity THEN

            IF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Line_Scredit.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Line_Scredit_rec            => l_Line_Scredit_rec
                );

            ELSE

                OE_Validate_Line_Scredit.Entity
                (   x_return_status               => l_return_status
                ,   p_Line_Scredit_rec            => l_Line_Scredit_rec
                ,   p_old_Line_Scredit_rec        => l_old_Line_Scredit_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    -- For UPDATE operations, entity security checks for constraints setup
    -- with a NULL column i.e. the constraint restricts update on ANY of
    -- the columns.
    -- However, this check should NOT be done if user did not try to update
    -- any of the constrainable attributes and also none of the defaulted
    -- attributes was constrainable!. In such a case, the g_check_all_cols
    -- _constraint flag would still be 'Y' as the flag is reset only
    -- when checking for constraints.
/* Bug fix 2020390, Removed the changes added for the bug 1696681 */
    IF NOT (l_line_scredit_rec.operation  = OE_GLOBALS.G_OPR_UPDATE
           AND OE_Line_Scredit_Security.g_check_all_cols_constraint = 'Y')
           AND l_control_rec.check_security
    THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK ENTITY SECURITY' ) ;
        END IF;

           OE_Line_Scredit_Security.Entity
                (p_line_scredit_rec   	=> l_line_scredit_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

		 /* Start Audit Trail */
           Oe_line_Scredit_Util.Pre_Write_Process
		 (p_x_line_scredit_rec => l_line_scredit_rec,
		  p_old_line_scredit_rec => l_old_line_scredit_rec);
		 /* End AuditTrail */

            IF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Line_Scredit_Util.Delete_Row
                (   p_sales_credit_id             => l_Line_Scredit_rec.sales_credit_id
                );

            ELSE

                --  Get Who Information

                l_Line_Scredit_rec.last_update_date := SYSDATE;
                l_Line_Scredit_rec.last_updated_by :=  NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
                l_Line_Scredit_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Line_Scredit_Util.Update_Row (l_Line_Scredit_rec);

                ELSIF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Line_Scredit_rec.creation_date := SYSDATE;
                    l_Line_Scredit_rec.created_by  := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

                    OE_Line_Scredit_Util.Insert_Row (l_Line_Scredit_rec);

                END IF;

            END IF;

        END IF;

    	OE_Line_Scredit_Security.g_check_all_cols_constraint := 'Y';
     OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');

     --  loop exception handler.
	IF l_line_scredit_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_line_scredit_rec.return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
	END IF;

        --  Load tables.

        l_Line_Scredit_rec.return_status          := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Scredit_tbl(I)          := l_Line_Scredit_rec;
        p_x_old_Line_Scredit_tbl(I)      := l_old_Line_Scredit_rec;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_ERROR;
            l_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Line_Scredit_tbl(I)          := l_Line_Scredit_rec;
            p_x_old_Line_Scredit_tbl(I)      := l_old_Line_Scredit_rec;

    	    OE_Line_Scredit_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
	    IF l_control_rec.Process_Partial THEN
             IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'DELETE REQUEST12' , 2 ) ;
              END IF;
              oe_delayed_requests_pvt.Delete_Reqs_for_Deleted_Entity
                    (p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
                    p_entity_id => l_line_scredit_rec.sales_credit_id,
                    x_return_status => l_return_status);
             END IF;
		   ROLLBACK TO SAVEPOINT Line_Scredits;
	    ELSE
		   RAISE FND_API.G_EXC_ERROR;
	    END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Line_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Scredit_tbl(I)          := l_Line_Scredit_rec;
            p_x_old_Line_Scredit_tbl(I)      := l_old_Line_Scredit_rec;
    	       OE_Line_Scredit_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Line_Scredit_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Scredit_tbl(I)          := l_Line_Scredit_rec;
            p_x_old_Line_Scredit_tbl(I)      := l_old_Line_Scredit_rec;
    	       OE_Line_Scredit_Security.g_check_all_cols_constraint := 'Y';
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Line_Scredits'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
     I := p_x_Line_Scredit_tbl.NEXT(I);
    END LOOP;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PVT.LINE_SCREDITS' , 1 ) ;
    END IF;
    OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
    set_recursion_mode(p_Entity_Code => 7,
                                   p_In_out  => 0);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        set_recursion_mode(p_Entity_Code => 7,
                                   p_In_out  => 0);
        x_return_status 				:= FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST13' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        set_recursion_mode(p_Entity_Code => 7,
                                   p_In_out  => 0);
        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST14' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');

    WHEN OTHERS THEN

        set_recursion_mode(p_Entity_Code => 7,
                                   p_In_out  => 0);
        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST15' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Scredits'
            );
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');

END Line_Scredits;


/*----------------------------------------------------------------------
PROCEDURE Line_Payments
-----------------------------------------------------------------------*/

PROCEDURE Line_Payments
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Payment_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_x_old_Line_Payment_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Line_Payment_rec            OE_Order_PUB.Line_Payment_Rec_Type;
l_old_Line_Payment_rec        OE_Order_PUB.Line_Payment_Rec_Type;
-- local variables to store OUT parameters from security check procedures
l_sec_result            NUMBER;
l_on_operation_action   NUMBER;
I                       NUMBER; -- Used as index.
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id        NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id number ;
BEGIN
    --MOAC changes start
      l_org_id := MO_GLOBAL.get_current_org_id;
      IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    --MOAC changes end
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    IF p_control_rec.Process_Partial THEN
     	SAVEPOINT Line_Payments;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.LINE_PAYMENTS' , 1 ) ;
    END IF;

    --    FOR I IN 1..p_x_Line_Payment_tbl.COUNT LOOP

    I := p_x_Line_Payment_tbl.FIRST;
    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Line_Payment_rec := p_x_Line_Payment_tbl(I);

        IF p_x_old_Line_Payment_tbl.EXISTS(I) THEN
            l_old_Line_Payment_rec := p_x_old_Line_Payment_tbl(I);
        ELSE
            l_old_Line_Payment_rec := OE_Order_PUB.G_MISS_LINE_PAYMENT_REC;
        END IF;
        if l_old_line_Payment_rec.payment_number = FND_API.G_MISS_NUM  Then
           IF l_line_Payment_rec.line_id IS NOT NULL AND
              l_line_Payment_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_line_Payment_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_line_Payment_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_PAYMENT'
  		,p_entity_id         		=> l_line_Payment_rec.payment_number
    		,p_header_id         		=> l_line_Payment_rec.header_id
    		,p_line_id           		=> l_line_Payment_rec.line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        else
           IF l_old_line_Payment_rec.line_id IS NOT NULL AND
              l_old_line_Payment_rec.line_id <> FND_API.G_MISS_NUM THEN
              BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for old line_id:'||l_old_line_Payment_rec.line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id, orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_old_line_Payment_rec.line_id;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
              END;
           END IF;

           OE_MSG_PUB.set_msg_context(
		 p_entity_code			=> 'LINE_PAYMENT'
  		,p_entity_id         		=> l_old_line_Payment_rec.payment_number
    		,p_header_id         		=> l_old_line_Payment_rec.header_id
    		,p_line_id           		=> l_old_line_Payment_rec.line_id
                ,p_order_source_id              => l_order_source_id
    		,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    		,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
                ,p_orig_sys_shipment_ref        => l_orig_sys_shipment_ref
                ,p_change_sequence              => l_change_sequence
                ,p_source_document_type_id      => l_source_document_type_id
    		,p_source_document_id		=> l_source_document_id
    		,p_source_document_line_id	=> l_source_document_line_id );

        end if;


        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Line_Payment_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Line_Payment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Line_Payment_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Convert_Miss_To_Null', 5);
            END IF;
            OE_Line_Payment_Util.Convert_Miss_To_Null (l_old_Line_Payment_rec);
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Convert_Miss_To_Null', 5);
            END IF;

        ELSIF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Line_Payment_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Line_Payment_rec.payment_number = FND_API.G_MISS_NUM
            THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Query_Row', 5);
                END IF;
                OE_Line_Payment_Util.Query_Row
                (   p_payment_number        => l_Line_Payment_rec.payment_number
                ,   p_line_id               => l_Line_Payment_rec.line_id
                ,   p_header_id             => l_Line_Payment_rec.header_id
		,   x_line_payment_rec       => l_old_Line_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Query_Row', 5);
                END IF;

            ELSE

                --  Set missing old record elements to NULL.

                OE_Line_Payment_Util.Convert_Miss_To_Null (l_old_Line_Payment_rec);

            END IF;

            --  Complete new record from old

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Complete_Record', 5);
            END IF;
            OE_Line_Payment_Util.Complete_Record
            (   p_x_Line_Payment_rec          => l_Line_Payment_rec
            ,   p_old_Line_Payment_rec        => l_old_Line_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Complete_Record', 5);
            END IF;

           OE_MSG_PUB.update_msg_context(
		 p_entity_code			=> 'LINE_PAYMENT'
  		,p_entity_id         		=> l_line_Payment_rec.payment_number
    		,p_header_id         		=> l_line_Payment_rec.header_id
    		,p_line_id           		=> l_line_Payment_rec.line_id);

        END IF;

        IF I = p_x_line_payment_tbl.FIRST THEN
	       IF NOT Valid_Upgraded_Order(l_line_payment_rec.header_id) THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

   -- Check security
   IF l_control_rec.check_security
      AND (l_line_payment_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_line_payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE)
   THEN

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:before OE_Line_Payment_Security.Attributes', 5);
           END IF;
           OE_Line_Payment_Security.Attributes
                (p_line_payment_rec   	=> l_line_payment_rec
                , p_old_line_payment_rec	=> l_old_line_payment_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:after OE_Line_Payment_Security.Attributes', 5);
           END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Line_Payment.Attributes', 5);
                END IF;
                OE_Validate_Line_Payment.Attributes
                (   x_return_status               => l_return_status
                ,   p_Line_Payment_rec            => l_Line_Payment_rec
                ,   p_old_Line_Payment_rec        => l_old_Line_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Line_Payment.Attributes', 5);
                END IF;

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            --  Clear dependent attributes.
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' CLEAR DEPENDENT' || L_LINE_PAYMENT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.clear_dependents THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Clear_Dependent_Attr', 5);
            END IF;
            OE_Line_Payment_Util.Clear_Dependent_Attr
            (   p_x_Line_Payment_rec          => l_Line_Payment_rec
            ,   p_old_Line_Payment_rec        => l_old_Line_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Clear_Dependent_Attr', 5);
            END IF;

        END IF;

        --  Default missing attributes
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' DEFAULTING' || L_LINE_PAYMENT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.default_attributes
        THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Default_Line_Payment.Attributes', 5);
            END IF;
            OE_Default_Line_Payment.Attributes
            (   p_x_Line_Payment_rec          => l_Line_Payment_rec
	    ,   p_old_line_payment_rec        => l_old_line_Payment_Rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Default_Line_Payment.Attributes', 5);
            END IF;

        END IF;

        --  Apply attribute changes
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' APPLY ATTRIBUTES' || L_LINE_PAYMENT_REC.HEADER_ID ) ;
		 END IF;

        IF  l_control_rec.change_attributes
        THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Apply_Attribute_Changes', 5);
            END IF;
            OE_Line_Payment_Util.Apply_Attribute_Changes
            (   p_x_Line_Payment_rec          => l_Line_Payment_rec
            ,   p_old_Line_Payment_rec        => l_old_Line_Payment_rec
            );
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Apply_Attribute_Changes', 5);
            END IF;

        END IF;

        --  Entity level validation.
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  ' ENTITY VALIDATION ' || L_LINE_PAYMENT_REC.HEADER_ID ) ;
		 END IF;

        IF l_control_rec.validate_entity THEN

            IF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Line_Payment.Entity_Delete', 5);
                END IF;
                OE_Validate_Line_Payment.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Line_Payment_rec            => l_Line_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Line_Payment.Entity_Delete', 5);
                END IF;

            ELSE

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Validate_Line_Payment.Entity', 5);
                END IF;
                OE_Validate_Line_Payment.Entity
                (   x_return_status               => l_return_status
                ,   p_Line_Payment_rec            => l_Line_Payment_rec
                ,   p_old_Line_Payment_rec        => l_old_Line_Payment_rec
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Validate_Line_Payment.Entity', 5);
                END IF;

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    -- Check entity level security again as some attributes
    -- may have changed due to defaulting.
    -- For UPDATE operations, entity security checks for constraints setup
    -- with a NULL column i.e. the constraint restricts update on ANY of
    -- the columns.
    -- However, this check should NOT be done if user did not try to update
    -- any of the constrainable attributes and also none of the defaulted
    -- attributes was constrainable!. In such a case, the g_check_all_cols
    -- _constraint flag would still be 'Y' as the flag is reset only
    -- when checking for constraints.
/* Bug fix 2020390, Removed the changes added for the bug 1696681 */
    IF NOT (l_line_payment_rec.operation  = OE_GLOBALS.G_OPR_UPDATE
           AND OE_Line_Payment_Security.g_check_all_cols_constraint = 'Y')
           AND l_control_rec.check_security
    THEN

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:before OE_Line_Payment_Security.Entity', 5);
           END IF;
           OE_Line_Payment_Security.Entity
                (p_line_payment_rec   	=> l_line_payment_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:after OE_Line_Payment_Security.Entity', 5);
           END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

		 /* Start Audit Trail */
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:before Oe_line_Payment_Util.Pre_Write_Process', 5);
           END IF;
           Oe_line_Payment_Util.Pre_Write_Process
		 (p_x_line_payment_rec => l_line_payment_rec,
		  p_old_line_payment_rec => l_old_line_payment_rec);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Payment:after Oe_line_Payment_Util.Pre_Write_Process', 5);
           END IF;
		 /* End AuditTrail */

            IF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Delete_Row', 5);
                END IF;
                OE_Line_Payment_Util.Delete_Row
                (   p_payment_number        => l_Line_Payment_rec.payment_number
                ,   p_line_id               => l_Line_Payment_rec.line_id
                ,   p_header_id             => l_Line_Payment_rec.header_id
                );
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Delete_Row', 5);
                END IF;

            ELSE

                --  Get Who Information

                l_Line_Payment_rec.last_update_date := SYSDATE;
                l_Line_Payment_rec.last_updated_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
                l_Line_Payment_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Update_Row', 5);
                    END IF;
                    OE_Line_Payment_Util.Update_Row (l_Line_Payment_rec);
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Update_Row', 5);
                    END IF;

                ELSIF l_Line_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Line_Payment_rec.creation_date := SYSDATE;
                    l_Line_Payment_rec.created_by  := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:before OE_Line_Payment_Util.Insert_Row', 5);
                    END IF;
                    OE_Line_Payment_Util.Insert_Row (l_Line_Payment_rec);
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Payment:after OE_Line_Payment_Util.Insert_Row', 5);
                    END IF;

                END IF;

            END IF;

        END IF;

    	OE_Line_Payment_Security.g_check_all_cols_constraint := 'Y';
     OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');

     --  loop exception handler.
	IF l_line_payment_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_line_payment_rec.return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
	END IF;

        --  Load tables.

        l_Line_Payment_rec.return_status          := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Payment_tbl(I)          := l_Line_Payment_rec;
        p_x_old_Line_Payment_tbl(I)      := l_old_Line_Payment_rec;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_ERROR;
            l_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;
            p_x_Line_Payment_tbl(I)          := l_Line_Payment_rec;
            p_x_old_Line_Payment_tbl(I)      := l_old_Line_Payment_rec;

    	    OE_Line_Payment_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');
	    IF l_control_rec.Process_Partial THEN
             IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'DELETE REQUEST12' , 2 ) ;
              END IF;
              oe_delayed_requests_pvt.Delete_Reqs_for_Deleted_Entity
                    (p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
                    p_entity_id => l_line_payment_rec.line_id,
                    x_return_status => l_return_status);
             END IF;
		   ROLLBACK TO SAVEPOINT Line_Payments;
	    ELSE
		   RAISE FND_API.G_EXC_ERROR;
	    END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Line_Payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Payment_tbl(I)          := l_Line_Payment_rec;
            p_x_old_Line_Payment_tbl(I)      := l_old_Line_Payment_rec;
    	       OE_Line_Payment_Security.g_check_all_cols_constraint := 'Y';
            OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Line_Payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Line_Payment_tbl(I)          := l_Line_Payment_rec;
            p_x_old_Line_Payment_tbl(I)      := l_old_Line_Payment_rec;
    	       OE_Line_Payment_Security.g_check_all_cols_constraint := 'Y';
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Line_Payments'
                );
            END IF;

            OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
     I := p_x_Line_Payment_tbl.NEXT(I);
    END LOOP;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PVT.LINE_PAYMENTS' , 1 ) ;
    END IF;
    OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status 				:= FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST13' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST14' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');

    WHEN OTHERS THEN

        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST15' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Payments'
            );
        END IF;
        OE_MSG_PUB.reset_msg_context('LINE_PAYMENT');

END Line_Payments;


/*-------------------------------------------------------------------
PROCEDURE Lot_Serials
--------------------------------------------------------------------*/

PROCEDURE Lot_Serials
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_x_old_Lot_Serial_tbl          IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_old_Lot_Serial_rec          OE_Order_PUB.Lot_Serial_Rec_Type;
I					     NUMBER; -- Used as index.
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_org_id number;
BEGIN
    --MOAC changes start
      l_org_id := MO_GLOBAL.get_current_org_id;
      IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
         OE_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    --MOAC changes end
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

--    FOR I IN 1..p_x_Lot_Serial_tbl.COUNT LOOP

    I := p_x_Lot_Serial_tbl.FIRST;

    WHILE I IS NOT NULL LOOP
    BEGIN

        --  Load local records.

        l_Lot_Serial_rec := p_x_Lot_Serial_tbl(I);

        IF p_x_old_Lot_Serial_tbl.EXISTS(I) THEN
            l_old_Lot_Serial_rec := p_x_old_Lot_Serial_tbl(I);
        ELSE
            l_old_Lot_Serial_rec := OE_Order_PUB.G_MISS_LOT_SERIAL_REC;
        END IF;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Lot_Serial_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Lot_Serial_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Lot_Serial_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            OE_Lot_Serial_Util.Convert_Miss_To_Null (l_old_Lot_Serial_rec);

        ELSIF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Lot_Serial_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Lot_Serial_rec.lot_serial_id = FND_API.G_MISS_NUM
            THEN

                OE_Lot_Serial_Util.Query_Row
                (   p_lot_serial_id               => l_Lot_Serial_rec.lot_serial_id
			 ,   x_Lot_Serial_rec              => l_old_Lot_Serial_rec
                );

            ELSE

                --  Set missing old record elements to NULL.

                OE_Lot_Serial_Util.Convert_Miss_To_Null (l_old_Lot_Serial_rec);

            END IF;

            --  Complete new record from old

            OE_Lot_Serial_Util.Complete_Record
            (   p_x_Lot_Serial_rec            => l_Lot_Serial_rec
            ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
            );

        END IF;

        --  Attribute level validation.

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Lot_Serial.Attributes
                (   x_return_status               => l_return_status
                ,   p_Lot_Serial_rec              => l_Lot_Serial_rec
                ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.clear_dependents THEN

            OE_Lot_Serial_Util.Clear_Dependent_Attr
            (   p_x_Lot_Serial_rec            => l_Lot_Serial_rec
            ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        THEN

            OE_Default_Lot_Serial.Attributes
            (   p_x_Lot_Serial_rec            => l_Lot_Serial_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.change_attributes
        THEN

            OE_Lot_Serial_Util.Apply_Attribute_Changes
            (   p_x_Lot_Serial_rec            => l_Lot_Serial_rec
            ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Lot_Serial.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Lot_Serial_rec              => l_Lot_Serial_rec
                );

            ELSE

                OE_Validate_Lot_Serial.Entity
                (   x_return_status               => l_return_status
                ,   p_Lot_Serial_rec              => l_Lot_Serial_rec
                ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Lot_Serial_Util.Delete_Row
                (   p_lot_serial_id               => l_Lot_Serial_rec.lot_serial_id
                );

            ELSE

                --  Get Who Information

                l_Lot_Serial_rec.last_update_date := SYSDATE;
                l_Lot_Serial_rec.last_updated_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637
                l_Lot_Serial_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Lot_Serial_Util.Update_Row (l_Lot_Serial_rec);

                ELSIF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Lot_Serial_rec.creation_date := SYSDATE;
                    l_Lot_Serial_rec.created_by    := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637

                    OE_Lot_Serial_Util.Insert_Row (l_Lot_Serial_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        p_x_Lot_Serial_tbl(I)            := l_Lot_Serial_rec;
        p_x_old_Lot_Serial_tbl(I)        := l_old_Lot_Serial_rec;

       --  loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_ERROR;
            l_Lot_Serial_rec.return_status 	:= FND_API.G_RET_STS_ERROR;
            p_x_Lot_Serial_tbl(I)            := l_Lot_Serial_rec;
            p_x_old_Lot_Serial_tbl(I)        := l_old_Lot_Serial_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Lot_Serial_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Lot_Serial_tbl(I)            := l_Lot_Serial_rec;
            p_x_old_Lot_Serial_tbl(I)        := l_old_Lot_Serial_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
            l_Lot_Serial_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            p_x_Lot_Serial_tbl(I)            := l_Lot_Serial_rec;
            p_x_old_Lot_Serial_tbl(I)        := l_old_Lot_Serial_rec;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Lot_Serials'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
		I := p_x_Lot_Serial_tbl.NEXT(I);
    END LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status 				:= FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST17' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST18' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;

    WHEN OTHERS THEN

        x_return_status 				:= FND_API.G_RET_STS_UNEXP_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DELETE REQUEST19' , 2 ) ;
          END IF;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
        END IF;
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Serials'
            );
        END IF;

END Lot_Serials;


/*-----------------------------------------------------------------
PROCEDURE Process_Requests_And_Notify
------------------------------------------------------------------*/

PROCEDURE Process_Requests_And_Notify
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_process_requests              IN  BOOLEAN := TRUE
,   p_notify                        IN  BOOLEAN := TRUE
,   p_process_ack                   IN  BOOLEAN := TRUE
, x_return_status OUT NOCOPY VARCHAR2

,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
)
IS
l_return_status			VARCHAR2(30);
l_msg_count				NUMBER;
l_msg_data				VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_header_id			NUMBER; -- added for bug 2781468 hashraf
l_index  			NUMBER;
l_line_id			NUMBER;
l_edi_ack_pfile                 Varchar2(3);
l_org_id                        number;            --4241385
l_auto_sch_flag                 VARCHAR2(1) :='Y'; --4241385
--SUN OIP ER
I 	      NUMBER;
j             NUMBER;
--End of SUN OIP ER

BEGIN

 IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_ORDER_PVT.PROCESS_REQUESTS_AND_NOTIFY' , 1 ) ;
    END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT PROCESS_REQUESTS_AND_NOTIFY' , 1 ) ;
      END IF;
      RETURN;
    END IF;
    set_recursion_mode(p_Entity_Code => 8,
                                   p_In_out  => 1);

      fnd_profile.get('ONT_NEW_EDI_ACK_FWK', l_edi_ack_pfile);
    l_edi_ack_pfile := nvl(l_edi_ack_pfile, 'NO');

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

  --4241385
/* querying the org_id here to het the value of the system parameter ONT_AUTO_SCH_SETS*/
    IF p_line_tbl.count>0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'get org id' , 1 ) ;
      END IF;
        l_auto_sch_flag:= Nvl(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_line_tbl(1).org_id),'Y');

    END IF ;

  --4241385

    -- IF p_process_requests, then process all delayed requests

    IF (    OE_GLOBALS.G_RECURSION_MODE = 'N'
	    AND p_process_requests
            AND OE_DELAYED_REQUESTS_PVT.Requests_Count > 0 )
/* --commented for bug 10088102. This condition being worked out with bug  10064449
    OR    --4241385
         (OE_DELAYED_REQUESTS_PVT.Requests_Count > 0
          AND p_process_requests
          AND l_auto_sch_flag='N'
          AND p_line_tbl.count>0)
*/
    THEN

/* added the or condition here to fix a scenario where if we add a new line to a
booked order, by giving the set information, the line is going into awaiting shipping
but it is not getting scheduled. This is becuase, the below code is not getting
executed for group_schedule delayed reuqest, as it is coming in recurision mode, in the
same session. checking for the p_line_tbl.count>0 to ensure that line table is passed.
This is to avoid processing when the API is called for someother entity only*/

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER_PAYMENT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_PAYMENT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Execute all remaining delayed requests. This would execute
	  -- requests logged against entity G_ENTITY_HEADER and G_ENTITY_ALL

       OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
          x_return_status => l_return_status
          );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF; --End of requests processing

    -- Start flows for the Entity.
    IF (p_process_requests AND
        OE_GLOBALS.G_RECURSION_MODE = 'N') THEN

	   OE_ORDER_WF_UTIL.START_ALL_FLOWS;
    END IF;

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508'
  AND oe_order_cache.g_header_rec.booked_flag = 'Y' THEN
    -- If notify, then call service and acknowledgments notify APIs

    IF p_notify THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING NOTIFY_OC API' , 1 ) ;
    END IF;

    OE_SERVICE_UTIL.Notify_OC
    (   p_api_version_number                  =>  1.0
    ,   p_init_msg_list                       =>  FND_API.G_FALSE
    ,   x_return_status                       =>  l_return_status
    ,   x_msg_count                           =>  l_msg_count
    ,   x_msg_data                            =>  l_msg_data
    ,   p_header_rec                          =>  p_header_rec
    ,   p_old_header_rec                      =>  p_old_header_rec
    ,   p_header_adj_tbl                      =>  p_header_adj_tbl
    ,   p_old_header_adj_tbl		           =>  p_old_header_adj_tbl
    ,   p_header_price_att_tbl                =>  p_header_price_att_tbl
    ,   p_old_header_price_att_tbl            =>  p_old_header_price_att_tbl
    ,   p_Header_Adj_Att_tbl                  =>  p_Header_Adj_Att_tbl
    ,   p_old_Header_Adj_Att_tbl              =>  p_old_Header_Adj_Att_tbl
    ,   p_Header_Adj_Assoc_tbl                =>  p_Header_Adj_Assoc_tbl
    ,   p_old_Header_Adj_Assoc_tbl            =>  p_old_Header_Adj_Assoc_tbl
    ,   p_Header_Scredit_tbl                  =>  p_Header_Scredit_tbl
    ,   p_old_Header_Scredit_tbl              =>  p_old_Header_Scredit_tbl
--  ,   p_Header_Payment_tbl                  =>  p_Header_Payment_tbl
--  ,   p_old_Header_Payment_tbl              =>  p_old_Header_Payment_tbl
    ,   p_line_tbl                            =>  p_line_tbl
    ,   p_old_line_tbl                        =>  p_old_line_tbl
    ,   p_Line_Adj_tbl                        =>  p_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl                    =>  p_old_Line_Adj_tbl
    ,   p_Line_Price_Att_tbl                  =>  p_Line_Price_Att_tbl
    ,   p_old_Line_Price_Att_tbl              =>  p_old_Line_Price_Att_tbl
    ,   p_Line_Adj_Att_tbl                    =>  p_Line_Adj_Att_tbl
    ,   p_old_Line_Adj_Att_tbl                =>  p_old_Line_Adj_Att_tbl
    ,   p_Line_Adj_Assoc_tbl                  =>  p_Line_Adj_Assoc_tbl
    ,   p_old_Line_Adj_Assoc_tbl              =>  p_old_Line_Adj_Assoc_tbl
    ,   p_Line_Scredit_tbl                    =>  p_Line_Scredit_tbl
    ,   p_old_Line_Scredit_tbl                =>  p_old_Line_Scredit_tbl
--  ,   p_Line_Payment_tbl                    =>  p_Line_Payment_tbl
--  ,   p_old_Line_Payment_tbl                =>  p_old_Line_Payment_tbl
    ,   p_Lot_Serial_tbl                      =>  p_Lot_Serial_tbl
    ,   p_old_Lot_Serial_tbl                  =>  p_old_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl                  =>  p_Lot_Serial_val_tbl
    ,   p_old_Lot_Serial_val_tbl              =>  p_old_Lot_Serial_val_tbl
    );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER NOTIFY_OC API' , 1 ) ;
       END IF;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF; --p_notify

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING ACKS' , 1 ) ;
    END IF;

    IF p_notify AND p_process_ack THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING ACKS API' , 1 ) ;
      END IF;

     -- ediack changes
     If Oe_Code_Control.Code_Release_level >= '110510' And
        p_header_rec.order_source_id In (0,2,6) And
        l_edi_ack_pfile = 'YES'  Then

        OE_Acknowledgment_Pvt.Process_Acknowledgment
        (p_header_rec           => p_header_rec,
         p_line_tbl             => p_line_tbl,
         p_old_header_rec       => p_old_header_rec,
         p_old_line_tbl         => p_old_line_tbl,
         x_return_status        => l_return_status);

     Elsif l_edi_ack_pfile = 'NO' And
           p_header_rec.order_source_id In (0,2,6,20) Then

      OE_Acknowledgment_Pvt.Process_Acknowledgment
     (p_api_version_number 		=> 1
     ,p_init_msg_list 		        => FND_API.G_FALSE
     ,p_header_rec 			=> p_header_rec
     ,p_header_adj_tbl		        => p_header_adj_tbl
     ,p_header_Scredit_tbl		=> p_header_scredit_tbl
     ,p_line_tbl 			=> p_line_tbl
     ,p_line_adj_tbl			=> p_line_adj_tbl
     ,p_line_scredit_tbl		=> p_line_scredit_tbl
     ,p_lot_serial_tbl		        => p_lot_serial_tbl
     ,p_old_header_rec 		   	=> p_old_header_rec
     ,p_old_header_adj_tbl 		=> p_old_header_adj_tbl
     ,p_old_header_Scredit_tbl 	   	=> p_old_header_scredit_tbl
     ,p_old_line_tbl 		        => p_old_line_tbl
     ,p_old_line_adj_tbl 		=> p_old_line_adj_tbl
     ,p_old_line_scredit_tbl 	   	=> p_old_line_scredit_tbl
     ,p_old_lot_serial_tbl		=> p_old_lot_serial_tbl

     ,p_buyer_seller_flag           	=> 'B'
     ,p_reject_order                	=> 'N'

     ,x_return_status                   => l_return_status
     );

     End If;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
        x_return_status := l_return_status;
     END IF;
    END IF; -- p_notify and p_process_ack

  ELSE  /*post pack H*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'JPN: GLOBAL RECURSION WITHOUT EXCEPTION: ' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION ) ;
          oe_debug_pub.add(  'JPN: GLOBAL CACHE BOOKED FLAG' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add(  'JPN: GLOBAL PICTURE HEADER BOOKED FLAG' || OE_ORDER_UTIL.G_HEADER_REC.BOOKED_FLAG ) ;
         oe_debug_pub.add(  'JPN: COUNT OF NEW LINE TABLE= '|| OE_ORDER_UTIL.G_LINE_TBL.COUNT ) ;
         oe_debug_pub.add(  'JPN: COUNT OF OLD LINE TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_TBL.COUNT ) ;
         oe_debug_pub.add(  'JPN: COUNT OF NEW LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF OLD LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF NEW HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF OLD HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF NEW HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_HEADER_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF OLD HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_SCREDIT_TBL.COUNT ) ;
      oe_debug_pub.add(  'JPN: COUNT OF NEW LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_LINE_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF OLD LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_SCREDIT_TBL.COUNT ) ;
       oe_debug_pub.add(  'JPN: COUNT OF NEW LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_LOT_SERIAL_TBL.COUNT ) ;
        oe_debug_pub.add(  'JPN: COUNT OF OLD LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_OLD_LOT_SERIAL_TBL.COUNT ) ;
    END IF;

  /*check global pictures, to see if there's any record in the seven key entities*/

  IF ( OE_ORDER_UTIL.g_header_rec.header_id is not null
      OR OE_ORDER_UTIL.g_header_rec.header_id <> FND_API.G_MISS_NUM
      OR  OE_ORDER_UTIL.g_header_adj_tbl.count >0
      OR OE_ORDER_UTIL.g_Header_Scredit_tbl.count >0
--    OR OE_ORDER_UTIL.g_Header_Payment_tbl.count >0
      OR OE_ORDER_UTIL.g_line_tbl.count >0
      OR OE_ORDER_UTIL.g_Line_Adj_tbl.count >0
      OR OE_ORDER_UTIL.g_Line_Scredit_tbl.count >0
--    OR OE_ORDER_UTIL.g_Line_Payment_tbl.count >0
      OR  OE_ORDER_UTIL.g_Lot_Serial_tbl.count >0 ) THEN

/* start of bug 2781468 hashraf */

/* need to get the header_id which will then be passed to load_order_header
   to refresh the record in cache
*/

    l_index := 1;

    IF ( OE_ORDER_UTIL.g_header_rec.header_id is not null
         AND OE_ORDER_UTIL.g_header_rec.header_id <> FND_API.G_MISS_NUM) THEN
      l_header_id :=  OE_ORDER_UTIL.g_header_rec.header_id;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('header id in g_header_rec is: ' || l_header_id ) ;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_header_adj_tbl.count >0 ) THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the header_adj_tbl loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_header_adj_tbl.first;
      IF (l_index is not null) THEN
        l_header_id :=  OE_ORDER_UTIL.g_header_adj_tbl(l_index).header_id;
        IF l_debug_level > 0 THEN
        oe_debug_pub.add('header id in g_header_adj_tbl is: ' || l_header_id ) ;
        oe_debug_pub.add('l_index  in g_header_adj_tbl is: ' || l_index ) ;
        END IF;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_Header_Scredit_tbl.count >0 ) THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the header_Scredit_tbl loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_header_Scredit_tbl.first;
      IF (l_index is not null) THEN
        l_header_id :=  OE_ORDER_UTIL.g_header_Scredit_tbl(l_index).header_id;
        IF l_debug_level > 0 THEN
        oe_debug_pub.add('header id in g_header_Scredit_tbl is: ' || l_header_id ) ;
        oe_debug_pub.add('l_index  in g_header_Scredit_tbl is: ' || l_index ) ;
        END IF;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_line_tbl.count >0 ) THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the line loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_line_tbl.first;
      IF (l_index is not null) THEN
        l_header_id :=  OE_ORDER_UTIL.g_line_tbl(l_index).header_id;
        IF l_debug_level > 0 THEN
        oe_debug_pub.add('header id in g_line_tbl is: ' || l_header_id ) ;
        oe_debug_pub.add('l_index  in g_line_tbl is: ' || l_index ) ;
        END IF;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_line_adj_tbl.count >0 ) THEN

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the line_adj loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_line_adj_tbl.first;
      IF (l_index is not null) THEN

        l_header_id := OE_ORDER_UTIL.g_line_adj_tbl(l_index).header_id;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('header id in g_line_adj_tbl is: ' || l_header_id ) ;
          oe_debug_pub.add('l_index  in g_line_adj_tbl is: ' || l_index ) ;
        END IF;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_line_Scredit_tbl.count >0 ) THEN

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the line_Scredit loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_line_Scredit_tbl.first;
      IF (l_index is not null) THEN

        l_header_id := OE_ORDER_UTIL.g_line_Scredit_tbl(l_index).header_id;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('header id in g_line_Scredit_tbl is: ' || l_header_id );
          oe_debug_pub.add('l_index  in g_line_Scredit_tbl is: ' || l_index ) ;
        END IF;
      END IF;

    ELSIF ( OE_ORDER_UTIL.g_Lot_Serial_tbl.count >0 ) THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Inside the group by_lot_serial loop');
      END IF;
      l_index := OE_ORDER_UTIL.g_Lot_Serial_tbl.first;
      IF (l_index is not null) THEN
        l_line_id := OE_ORDER_UTIL.g_Lot_Serial_tbl(l_index).line_id;

        BEGIN
          SELECT header_id
 	  INTO l_header_id
 	  FROM OE_ORDER_LINES_ALL
 	  WHERE line_id = l_line_id;
        EXCEPTION
 	  WHEN NO_DATA_FOUND THEN
    	    null;
        END;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('header id in g_Lot_Serial_tbl is: ' || l_header_id);
          oe_debug_pub.add('line id in g_Lot_Serial_tbl is: ' || l_line_id);
          oe_debug_pub.add('l_index in g_Lot_Serial_tbl is: ' || l_index);
        END IF;
      END IF; -- l_index is not null in g_lot

    END IF;  -- end if-elsif

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'header id is: ' || l_header_id ) ;
    END IF;

    IF (l_header_id is not null AND l_header_id <> FND_API.G_MISS_NUM) THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Just before calling Load_Order_Header');
      END IF;

      Oe_Order_Cache.Load_Order_Header(l_header_id);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Out of Load_Order_Header in PRN');
    END IF;
/* end of bug 2781468*/

    IF (OE_ORDER_UTIL.G_Recursion_Without_Exception = 'N' AND
       OE_ORDER_CACHE.g_header_rec.booked_flag = 'Y') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'POST PACK H. CALLING NOTIFY_OC API' , 1 ) ;
    END IF;

    OE_SERVICE_UTIL.Notify_OC
    (   p_api_version_number                  =>  1.0
    ,   p_init_msg_list                       =>  FND_API.G_FALSE
    ,   x_return_status                       =>  l_return_status
    ,   x_msg_count                           =>  l_msg_count
    ,   x_msg_data                            =>  l_msg_data
    ,   p_header_rec                          =>  OE_ORDER_UTIL.g_header_rec
    ,   p_old_header_rec                      =>  OE_ORDER_UTIL.g_old_header_rec
    ,   p_header_adj_tbl                      =>  OE_ORDER_UTIL.g_header_adj_tbl
    ,   p_old_header_adj_tbl		      =>  OE_ORDER_UTIL.g_old_header_adj_tbl
    ,   p_Header_Scredit_tbl                  =>  OE_ORDER_UTIL.g_Header_Scredit_tbl
    ,   p_old_Header_Scredit_tbl              =>  OE_ORDER_UTIL.g_old_Header_Scredit_tbl
--  ,   p_Header_Payment_tbl                  =>  OE_ORDER_UTIL.g_Header_Payment_tbl
--  ,   p_old_Header_Payment_tbl              =>  OE_ORDER_UTIL.g_old_Header_Payment_tbl
    ,   p_line_tbl                            =>  OE_ORDER_UTIL.g_line_tbl
    ,   p_old_line_tbl                        =>  OE_ORDER_UTIL.g_old_line_tbl
    ,   p_Line_Adj_tbl                        =>  OE_ORDER_UTIL.g_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl                    =>  OE_ORDER_UTIL.g_old_Line_Adj_tbl
    ,   p_Line_Scredit_tbl                    =>  OE_ORDER_UTIL.g_Line_Scredit_tbl
    ,   p_old_Line_Scredit_tbl                =>  OE_ORDER_UTIL.g_old_Line_Scredit_tbl
--  ,   p_Line_Payment_tbl                    =>  OE_ORDER_UTIL.g_Line_Payment_tbl
--  ,   p_old_Line_Payment_tbl                =>  OE_ORDER_UTIL.g_old_Line_Payment_tbl
    ,   p_Lot_Serial_tbl                      =>  OE_ORDER_UTIL.g_Lot_Serial_tbl
    ,   p_old_Lot_Serial_tbl                  =>  OE_ORDER_UTIL.g_old_Lot_Serial_tbl
    );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER NOTIFY_OC API' , 1 ) ;
       END IF;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING ACKS' , 1 ) ;
        oe_debug_pub.add(  'PACKS ' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION , 1 ) ;
        oe_debug_pub.add(  'PACKS' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG , 1 ) ;
    END IF;

    --SUN OIP ER
    If NVL (Fnd_Profile.Value('ONT_RAISE_STATUS_CHANGE_BUSINESS_EVENT'), 'N')='Y' THEN
      i := OE_ORDER_UTIL.g_line_tbl.first;
      while i is not null LOOP
      if OE_ORDER_UTIL.g_line_tbl(i).line_id = OE_ORDER_UTIL.g_old_line_tbl(i).line_id then
                 j := i;
      else
                 j := OE_Acknowledgment_Pub.get_line_index(OE_ORDER_UTIL.g_old_line_tbl, OE_ORDER_UTIL.g_line_tbl(i).line_id);
      end if;

      if j<>0 THEN

       IF NOT  l_event_Tbl.exists(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT))  THEN
	l_event_Tbl(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT)) := FALSE;
       END IF;

       if  OE_ORDER_UTIL.g_old_line_tbl(i).schedule_ship_date IS NULL
       AND OE_ORDER_UTIL.g_line_tbl(i).schedule_ship_date IS NOT NULL AND
       NOT l_event_Tbl(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT)) THEN

           OE_ORDER_UTIL.RAISE_BUSINESS_EVENT(OE_ORDER_UTIL.g_line_tbl(i).header_id,
    	   	    	                      OE_ORDER_UTIL.g_line_tbl(i).line_id,
    	    	                              'SCHEDULED');
    	   l_event_Tbl(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT)) := TRUE;
       ELSE
           IF nvl(OE_ORDER_UTIL.g_line_tbl(i).schedule_ship_date, trunc(sysdate)) <>
              nvl(OE_ORDER_UTIL.g_old_line_tbl(i).schedule_ship_date, trunc(sysdate)) AND
              NOT l_event_Tbl(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT)) THEN

               OE_ORDER_UTIL.RAISE_BUSINESS_EVENT(OE_ORDER_UTIL.g_line_tbl(i).header_id,
    	   	    	                          OE_ORDER_UTIL.g_line_tbl(i).line_id,
    	                                          'SSD Change');
             l_event_Tbl(Mod(OE_ORDER_UTIL.g_line_tbl(i).line_id,G_BINARY_LIMIT)) := TRUE;
           END IF;
        END IF;
       END IF;
       i := OE_ORDER_UTIL.g_line_tbl.Next(i);
      end loop;
    end if;
    --End of SUN OIP ER
    IF (OE_ORDER_UTIL.G_Recursion_Without_Exception = 'N' AND
       OE_ORDER_CACHE.g_header_rec.booked_flag = 'Y' AND p_process_ack) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'POST PACK H.CALLING ACKS API' , 1 ) ;
      END IF;

     -- { Start 3A6 changes, Design will still honor the Booking as
     --   the starting point of the triggering of the Show Sales Order
     --   collaboration. Later some point If we decided (by Cust requirment)
     --   that it should not wait till booking and workflow solution is not
     --   acceptable, we should review this code to removed the booking
     --   condition, i.e. write a new if for 3A6.

     -- { Start of If order_source_id = 20
     --   The below condition will only executed for the the XML Xactions
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PACKS ' || OE_ORDER_CACHE.G_HEADER_REC.ORDER_SOURCE_ID , 1 ) ;
        oe_debug_pub.add(  'PACKS ' || OE_ORDER_CACHE.G_HEADER_REC.SOLD_TO_ORG_ID , 1 ) ;
    END IF;

     If  OE_ORDER_CACHE.g_header_rec.order_source_id in (20) OR
         NVL(Fnd_Profile.Value('ONT_RAISE_STATUS_CHANGE_BUSINESS_EVENT'), 'N')='Y' OR
         (OE_GENESIS_UTIL.source_aia_enabled(OE_ORDER_CACHE.g_header_rec.order_source_id)) THEN -- GENESIS


      OE_Acknowledgment_Pub.Process_SSO
     (p_api_version_number              => 1
     ,p_init_msg_list                   => FND_API.G_FALSE
     ,p_header_rec                      => OE_ORDER_CACHE.g_header_rec
     ,p_line_tbl                        => OE_ORDER_UTIL.g_line_tbl
     ,p_old_header_rec                  => OE_ORDER_UTIL.g_old_header_rec
     ,p_old_line_tbl                    => OE_ORDER_UTIL.g_old_line_tbl

     ,x_return_status                   => l_return_status
     );

     --   The below condition to leave the existing flow to work as it is
     Elsif Oe_Code_Control.Code_Release_Level >= '110510' And
           OE_ORDER_CACHE.g_header_rec.order_source_id in (0,2,6) And
           l_edi_ack_pfile = 'YES' Then
        OE_Acknowledgment_Pvt.Process_Acknowledgment
        (p_header_rec           => OE_ORDER_UTIL.g_header_rec,
         p_line_tbl             => OE_ORDER_UTIL.g_line_tbl,
         p_old_header_rec       => OE_ORDER_UTIL.g_old_header_rec,
         p_old_line_tbl         => OE_ORDER_UTIL.g_old_line_tbl,
         x_return_status        => l_return_status);
     Elsif l_edi_ack_pfile = 'NO' And
           OE_ORDER_CACHE.g_header_rec.order_source_id in (0,2,6) Then
      OE_Acknowledgment_Pvt.Process_Acknowledgment
     (p_api_version_number 		=> 1
     ,p_init_msg_list 		        => FND_API.G_FALSE
     ,p_header_rec 			=> OE_ORDER_UTIL.g_header_rec
     ,p_header_adj_tbl		        => OE_ORDER_UTIL.g_header_adj_tbl
     ,p_header_Scredit_tbl		=> OE_ORDER_UTIL.g_header_scredit_tbl
     ,p_line_tbl 			=> OE_ORDER_UTIL.g_line_tbl
     ,p_line_adj_tbl			=> OE_ORDER_UTIL.g_line_adj_tbl
     ,p_line_scredit_tbl		=> OE_ORDER_UTIL.g_line_scredit_tbl
     ,p_lot_serial_tbl		        => OE_ORDER_UTIL.g_lot_serial_tbl
     ,p_old_header_rec 		   	=> OE_ORDER_UTIL.g_old_header_rec
     ,p_old_header_adj_tbl 		=> OE_ORDER_UTIL.g_old_header_adj_tbl
     ,p_old_header_Scredit_tbl 	   	=> OE_ORDER_UTIL.g_old_header_scredit_tbl
     ,p_old_line_tbl 		        => OE_ORDER_UTIL.g_old_line_tbl
     ,p_old_line_adj_tbl 		=> OE_ORDER_UTIL.g_old_line_adj_tbl
     ,p_old_line_scredit_tbl 	   	=> OE_ORDER_UTIL.g_old_line_scredit_tbl
     ,p_old_lot_serial_tbl		=> OE_ORDER_UTIL.g_old_lot_serial_tbl

     ,p_buyer_seller_flag           	=> 'B'
     ,p_reject_order                	=> 'N'

     ,x_return_status                   => l_return_status
     );

     End If;
     -- End of If order_source_id = 20 }
     -- End 3A6 changes}

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
        x_return_status := l_return_status;
     END IF;

    END IF;

-- DBI project changes start
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING OE_DBI_UTIL' , 1 ) ;
        oe_debug_pub.add(  'CACHED VALUE' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add(  'RECURSION VALUE' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION ) ;
        oe_debug_pub.add(  'PROFILE VALUE' || FND_PROFILE.VALUE ( 'ONT_DBI_INSTALLED' ) ) ;
    END IF;

    IF  NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'), 'N') = 'Y' AND
     oe_order_cache.g_header_rec.booked_flag = 'Y' AND
     OE_ORDER_UTIL.G_Recursion_Without_Exception = 'N'
   -- AND p_header_rec.header_id IS NOT NULL AND
    --p_header_rec.header_id <> FND_API.G_MISS_NUM
   THEN
    OE_DBI_UTIL.Update_DBI_Log( x_return_status  => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
        x_return_status := l_return_status;
     END IF;
    END IF;
   -- DBI project changes end



    /* Now clear the global pl/sql tables */
    /* Also clear for >= 11i10 for versioning */
    IF (OE_ORDER_UTIL.G_Recursion_Without_Exception = 'N' AND
       (OE_ORDER_CACHE.g_header_rec.booked_flag = 'Y' OR
        OE_CODE_CONTROL.Code_Release_Level >= '110510' )) THEN
    OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
    END IF;

   END IF;     /*check for record in key entities*/
 END IF; /*code_release_level*/

 /* Fix Bug # 3241831: Reset Global after all requests have been processed */
 IF OE_GLOBALS.G_RECURSION_MODE = 'N' AND OE_GLOBALS.G_UI_FLAG = FALSE THEN
   IF OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('SET G_ORD_LVL_CAN TO FALSE FOR NON UI ORDER CANCEL');
     END IF;
     OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can := FALSE;
   END IF;
 END IF;

  --resetting g_header_created flag
    IF OE_GLOBALS.G_RECURSION_MODE <> 'Y' AND
       OE_GLOBALS.G_PRICING_RECURSION <> 'Y' THEN
       OE_GLOBALS.G_HEADER_CREATED := FALSE;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_ORDER_PVT.PROCESS_REQUESTS_AND_NOTIFY' , 1 ) ;
    END IF;
    set_recursion_mode(p_Entity_Code => 8,
                                   p_In_out  => 0);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GLOBAL REQUEST TABLE COUNT- PRN'|| OE_DELAYED_REQUESTS_PVT.G_DELAYED_REQUESTS.COUNT , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        set_recursion_mode(p_Entity_Code => 8,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
           OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        set_recursion_mode(p_Entity_Code => 8,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
           OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
        END IF;

    WHEN OTHERS THEN

        set_recursion_mode(p_Entity_Code => 8,
                                   p_In_out  => 0);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PO: EXITING PROCESS_REQUESTS_AND_NOTIFY WITH OTHERS ERROR' , 2 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
           OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
            IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Requests_And_Notify'
            );
        END IF;

END Process_Requests_And_Notify;

PROCEDURE Process_Order_AG
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_x_Header_Payment_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_x_Line_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_x_action_request_tbl	      IN OUT NOCOPY OE_Order_PUB.request_tbl_type
,   p_action_commit				 IN  VARCHAR2 := FND_API.G_FALSE
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_control_rec                 OE_GLOBALS.Control_Rec_Type := p_control_rec;
l_return_status      VARCHAR2(1);
I                    NUMBER;
l_header_id          NUMBER;
l_call_split         BOOLEAN := FALSE;
l_line_index         NUMBER;
l_old_header_rec              OE_Order_PUB.Header_Rec_Type ;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_Old_Header_price_Att_Tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Old_Header_Adj_Att_Tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_Header_Payment_tbl      OE_Order_PUB.Header_Payment_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_Old_Line_price_Att_Tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Line_Payment_tbl        OE_Order_PUB.Line_Payment_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_edi_ack_pfile               Varchar2(3);
l_transaction_phase_code      VARCHAR2(1); -- Added for bug 4758902
l_hdr_flow_status_refresh     VARCHAR2(1); -- Added for bug 8435946
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER PROCESS_ORDER_AG' , 1 ) ;
END IF;

    -- Initialize x_return_status
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    fnd_profile.get('ONT_NEW_EDI_ACK_FWK', l_edi_ack_pfile);
    l_edi_ack_pfile := nvl(l_edi_ack_pfile, 'NO');

    --  Init local table variables for old tables as these are only
    --  IN params.

    l_old_header_Rec               := p_old_header_rec;
    l_old_Header_Adj_tbl           := p_old_Header_Adj_tbl;
    l_old_Header_price_Att_tbl    := p_old_Header_Price_Att_Tbl;
    l_old_Header_Adj_Att_tbl      := p_old_Header_Adj_Att_Tbl;
    l_old_Header_Adj_Assoc_tbl    := P_old_Header_Adj_Assoc_Tbl;
    l_old_Header_Scredit_tbl       := p_old_Header_Scredit_tbl;
    l_old_Header_Payment_tbl       := p_old_Header_Payment_tbl;
    l_old_line_tbl                 := p_old_line_tbl;
    l_old_Line_Adj_tbl             := p_old_Line_Adj_tbl;
    l_old_Line_price_Att_tbl    := p_old_Line_Price_Att_Tbl;
    l_old_Line_Adj_Att_tbl      := p_old_Line_Adj_Att_Tbl;
    l_old_Line_Adj_Assoc_tbl    := P_old_Line_Adj_Assoc_Tbl;
    l_old_Line_Scredit_tbl         := p_old_Line_Scredit_tbl;
    l_old_Line_Payment_tbl         := p_old_Line_Payment_tbl;
    l_old_Lot_Serial_tbl           := p_old_Lot_Serial_tbl;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE HEADER PROCESSING' , 2 ) ;
        oe_debug_pub.add(  'HEADER_ID' || P_X_HEADER_REC.HEADER_ID , 2 ) ;
        oe_debug_pub.add(  'OPERATION' || P_X_HEADER_REC.OPERATION , 2 ) ;
    END IF;

    -------------------------------------------------------
    -- Process Header
    -------------------------------------------------------

    --Bug 2790512: Prevent processing of header if operation is invalid
    --Bug 2878121: Ignore NULL operation code
   IF p_x_header_rec.header_id is NOT NULL AND
	p_x_header_rec.header_id <> FND_API.G_MISS_NUM THEN
    IF  p_x_header_rec.operation IS NOT NULL AND
        p_x_header_rec.operation NOT IN (OE_GLOBALS.G_OPR_CREATE,
              OE_GLOBALS.G_OPR_DELETE, OE_GLOBALS.G_OPR_UPDATE,
              OE_GLOBALS.G_OPR_NONE) THEN
           FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    IF p_x_header_rec.operation IS NOT NULL
	  AND p_x_header_rec.operation <> OE_GLOBALS.G_OPR_NONE
    THEN

    -- This if is add to honor users sales credits if they do not
    -- want the default sales credit for the salesrep on the order

    IF p_x_header_scredit_tbl.COUNT > 0 and
	  p_x_header_rec.operation = oe_globals.g_opr_create THEN
      OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit  := 'N';
    END IF;

      Header
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_header_rec                => p_x_header_rec
      ,   p_x_old_header_rec            => l_old_header_rec
      ,   x_return_status               => l_return_status
      );

      OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit  := 'Y';

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER HEADER PROCESSING HEADER_ID = '|| TO_CHAR ( P_X_HEADER_REC.HEADER_ID ) , 2 ) ;
      END IF;

    --  Perform header group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER)
    THEN

        NULL;

    END IF;


    -------------------------------------------------------
    -- Process Header Adjustments
    -------------------------------------------------------

    -- Set Header Id on Hdr Adjustments

    I := p_x_header_adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

    --    FOR I IN 1..p_x_header_adj_tbl.COUNT LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_ADJ_TBL' , 2 ) ;
        END IF;

        IF p_x_header_adj_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_adj_tbl(I).header_id IS NULL OR
            p_x_header_adj_tbl(I).header_id = FND_API.G_MISS_NUM)
        THEN
          IF p_x_header_rec.header_id IS NULL OR
             p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
               FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
               OE_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          ELSE
            --  Copy parent_id.
            p_x_header_adj_tbl(I).header_id := p_x_header_rec.header_id;
          END IF;
        END IF;

        -- This is added to prevent invalid  upgraded orders
        IF I = p_x_header_adj_tbl.FIRST THEN
           IF  (p_x_header_adj_tbl(I).header_id IS NOT NULL AND
		      p_x_header_adj_tbl(I).header_id <> FND_API.G_MISS_NUM) THEN
	      IF NOT Valid_Upgraded_Order(p_x_header_adj_tbl(I).header_id ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

    END IF;

        I := p_x_header_adj_tbl.NEXT(I);

    END LOOP;

    --  Header_Adjs

    IF p_x_header_adj_tbl.COUNT > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJS PROCESSING' , 2 ) ;
      END IF;
      oe_order_adj_pvt.Header_Adjs
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Header_Adj_tbl            => p_x_header_adj_tbl
      ,   p_x_old_Header_Adj_tbl        => l_old_header_Adj_tbl
      );
    END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_ADJS PROCESSING' , 2 ) ;
        END IF;
    --  Perform Header_Adj group requests.

    IF (p_control_rec.process AND
      OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER_ADJ)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;


    -------------------------------------------------------
    -- Process Header Price Attributes
    -------------------------------------------------------

    -- Set Header Id on Hdr Price Attributes

    I := p_x_header_price_att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_PRICE_ATT_TBL' , 2 ) ;
        END IF;
        IF p_x_header_price_att_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_price_att_tbl(I).header_id IS NULL OR
            p_x_header_price_att_tbl(I).header_id = FND_API.G_MISS_NUM)
        THEN
          IF p_x_header_rec.header_id IS NULL OR
             p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
               FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
               OE_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          ELSE

            --  Copy parent_id.

            p_x_header_price_Att_tbl(I).header_id := p_x_header_rec.header_id;
          END IF;
        END IF;
        I := p_x_header_price_Att_tbl.NEXT(I);
    END LOOP;

    --  Header_Price_Atts

    IF p_x_header_price_Att_tbl.COUNT > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_PRICE_ATTS PROCESSING' , 2 ) ;
      END IF;
      oe_order_adj_pvt.Header_Price_Atts
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Header_Price_Att_tbl      => p_x_header_price_Att_tbl
      ,   p_x_old_Header_Price_Att_tbl  => l_old_header_Price_Att_tbl
      );
    END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_PRICE_ATTS PROCESSING' , 2 ) ;
        END IF;
    --  Perform Header_Price_Att group requests.

    IF (p_control_rec.process AND
      OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
	   OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Header_Price_Att
	   )
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;


    -------------------------------------------------------
    -- Process Header Adj Attributes
    -------------------------------------------------------

    -- Set Header Id on Hdr Adj. Attributes

    I := p_x_header_adj_Att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE ADJUSTMENT ID ON HDR_ADJ_ATTBS' , 2 ) ;
        END IF;
        IF p_x_header_adj_att_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_adj_att_tbl(I).price_adjustment_id IS NULL OR
            p_x_header_adj_att_tbl(I).price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

		  IF p_x_header_adj_Tbl.exists(p_x_header_adj_att_tbl(I).Adj_index)
			Then
            --  Copy parent_id.

              p_x_header_adj_Att_tbl(I).price_adjustment_id :=
				p_x_header_adj_Tbl(p_x_header_adj_att_tbl(I).adj_index).price_adjustment_id;
	  	  ELSE
		     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'INVALID ADJ INDEX '|| TO_CHAR ( P_X_HEADER_ADJ_ATT_TBL ( I ) .ADJ_INDEX ) || 'ON HEADER ADJ ATTRIBUTES' , 2 ) ;
						END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
			     FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Header_Adj_Attribs');
				FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
				FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_header_adj_att_tbl(I).adj_index);
				OE_MSG_PUB.Add;
                END IF;
           END IF;

        END IF;
        I := p_x_header_adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Header_Adj_Atts
    IF p_x_header_adj_Att_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJ_ATTS PROCESSING' , 2 ) ;
    END IF;
    oe_order_adj_pvt.Header_Adj_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Adj_Att_tbl        => p_x_header_adj_Att_tbl
    ,   p_x_old_Header_Adj_Att_tbl    => l_old_header_Adj_Att_tbl
    );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_ADJ_ATTS PROCESSING' , 2 ) ;
        END IF;

    END IF;


    -------------------------------------------------------
    -- Process Header Adjustment Associations
    -------------------------------------------------------

    -- Set Header Id on Hdr Adjustment Associations

    I := p_x_header_adj_Assoc_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_ADJ_ASSOC_TBL' , 2 ) ;
        END IF;
        IF p_x_header_adj_assoc_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_adj_assoc_tbl(I).Price_Adjustment_id IS NULL OR
            p_x_header_adj_assoc_tbl(I).Price_Adjustment_id = FND_API.G_MISS_NUM)
        THEN

		  IF p_x_header_adj_Tbl.exists(p_x_header_adj_assoc_tbl(I).Adj_Index) Then
            --  Copy parent_id.

              p_x_header_adj_Assoc_tbl(I).price_adjustment_id :=
				p_x_header_adj_Tbl(p_x_header_adj_assoc_tbl(I).adj_index).price_adjustment_id;
	  	  ELSE
		     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'INVALID ADJ INDEX '|| TO_CHAR ( P_X_HEADER_ADJ_ASSOC_TBL ( I ) .ADJ_INDEX ) || 'ON HEADER ADJ ATTRIBUTES' , 2 ) ;
						END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
			     FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Header_Adj_Assocs');
				FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
				FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_header_adj_assoc_tbl(I).adj_index);
				OE_MSG_PUB.Add;
                END IF;
            END IF;

        END IF;

        IF p_x_header_adj_assoc_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_adj_assoc_tbl(I).rltd_Price_Adj_Id IS NULL OR
            p_x_header_adj_assoc_tbl(I).rltd_Price_Adj_Id = FND_API.G_MISS_NUM)
        THEN

		  IF p_x_header_adj_Tbl.exists(p_x_header_adj_assoc_tbl(I).Rltd_Adj_Index) Then
            --  Copy parent_id.

              p_x_header_adj_Assoc_tbl(I).rltd_Price_Adj_Id :=
				p_x_header_adj_Tbl(p_x_header_adj_assoc_tbl(I).Rltd_Adj_Index).Price_adjustment_id;
            END IF;

        END IF;
        I := p_x_header_adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Header_Adj_Assocs

    IF p_x_header_adj_Assoc_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJ_ASSOCS PROCESSING' , 2 ) ;
    END IF;
    oe_order_adj_pvt.Header_Adj_Assocs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Adj_Assoc_tbl      => p_x_header_adj_Assoc_tbl
    ,   p_x_old_Header_Adj_Assoc_tbl  => l_old_header_Adj_Assoc_tbl
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER HEADER_ADJ_ASSOCS PROCESSING' , 2 ) ;
    END IF;
    END IF;


    -------------------------------------------------------
    -- Process Header Sales Credits
    -------------------------------------------------------


    -- Set Header Id on Sales Credits

    I := p_x_header_scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER_ID ON HEADER_SCREDIT_TBL' , 2 ) ;
        END IF;
        IF p_x_header_scredit_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_scredit_tbl(I).header_id IS NULL OR
		p_x_header_scredit_tbl(I).header_id = FND_API.G_MISS_NUM)
	   THEN

              IF p_x_header_rec.header_id IS NULL OR
                  p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
                   FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
              ELSE
		--  Copy parent_id.

		  p_x_header_scredit_tbl(I).header_id := p_x_header_rec.header_id;
              END IF;
	   END IF;

	   I := p_x_header_scredit_tbl.NEXT(I);
    END LOOP;

    --  Header_Scredits

    IF p_x_header_scredit_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE HEADER_SCREDITS PROCESSING' , 2 ) ;
    END IF;
    Header_Scredits
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Scredit_tbl        => p_x_header_scredit_tbl
    ,   p_x_old_Header_Scredit_tbl    => l_old_header_Scredit_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF p_control_rec.process_partial THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER HEADER_SCREDITS PROCESSING' , 2 ) ;
    END IF;

    END IF;

    --  Perform Header_Scredit group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -- Get header_id from the header and put it on the line.

-- Kris = decide if
-- Header id may not be passed on the header record if the operation is none
-- I think we should pass header_id on the header rec all the time

/*
	IF p_x_line_tbl.COUNT > 0 THEN

		For k in p_x_line_tbl.first .. p_x_line_tbl.last LOOP

		   IF  (p_x_line_tbl(k).header_id = FND_API.G_MISS_NUM
		   OR   p_x_line_tbl(k).header_id is null ) THEN

-- Kris do not loop through the lines unless they have the right header_id
-- If people pass in a header_id with a bogus value, the record should be ignored

				p_x_line_tbl(k).header_id := p_x_header_rec.header_id;

		   END IF;

		End Loop;

  	END IF;
*/


    -------------------------------------------------------
    -- Process Header Payments
    -------------------------------------------------------

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
    -- Set Header Id on Payments

    I := p_x_header_payment_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER_ID ON HEADER_PAYMENT_TBL' , 2 ) ;
        END IF;
        IF p_x_header_payment_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_header_payment_tbl(I).header_id IS NULL OR
		p_x_header_payment_tbl(I).header_id = FND_API.G_MISS_NUM)
	   THEN

              IF p_x_header_rec.header_id IS NULL OR
                  p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
                   FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
              ELSE
		--  Copy parent_id.

		  p_x_header_payment_tbl(I).header_id := p_x_header_rec.header_id;
              END IF;
	   END IF;

	   I := p_x_header_payment_tbl.NEXT(I);
    END LOOP;

    --  Header_Payments

    IF p_x_header_payment_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE HEADER_PAYMENTS PROCESSING' , 2 ) ;
    END IF;
    Header_Payments
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Payment_tbl        => p_x_header_Payment_tbl
    ,   p_x_old_Header_Payment_tbl    => l_old_header_Payment_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF p_control_rec.process_partial THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER HEADER_PAYMENTS PROCESSING' , 2 ) ;
    END IF;

    END IF;

    --  Perform Header_Payment group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Payment
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
  END IF;
    -------------------------------------------------------
    -- Process Lines
    -------------------------------------------------------

    I := p_x_line_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        --Bug 2790512: Prevent processing of line if operation is invalid
        --Bug 2878121: Ignore NULL operation code
        IF p_x_line_tbl(I).operation IS NOT NULL AND
           p_x_line_tbl(I).operation NOT IN (OE_GLOBALS.G_OPR_CREATE,
                    OE_GLOBALS.G_OPR_DELETE, OE_GLOBALS.G_OPR_UPDATE,
                    OE_GLOBALS.G_OPR_INSERT, OE_GLOBALS.G_OPR_NONE) THEN
           FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF p_x_line_tbl(I).operation = oe_globals.g_opr_update
           AND p_x_line_tbl(I).split_action_code = 'SPLIT' THEN

          -- Negotiation check has been added for bug 4758902
          BEGIN
            SELECT transaction_phase_code
            INTO   l_transaction_phase_code
            FROM   oe_order_lines_all
            WHERE  line_id = p_x_line_tbl(I).line_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              oe_debug_pub.add(' No Transaction Phase Code for parent split line.',1);
              NULL;
            WHEN OTHERS THEN
              oe_debug_pub.add(' OTHERS: No Transaction Phase Code for parent split line.',1);
              NULL;
          END;

          IF NVL(l_transaction_phase_code,'F') = 'N' THEN
            oe_debug_pub.add(' Line  Id : '||p_x_line_tbl(I).line_id||' cannot be split. It is in Negotiation Phase.');
            FND_MESSAGE.SET_NAME('ONT','OE_PC_SPLIT_VIOLATION');
            FND_MESSAGE.SET_TOKEN('OBJECT',p_x_line_tbl(I).line_id);
            FND_MESSAGE.SET_TOKEN('REASON','Line is in Negotiation Phase');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            l_call_split := TRUE;
          END IF;
        END IF;

        -- START: CHECK IF ALL LINES BELONG TO THE SAME ORDER

        -- Retrieve the header ID, either from the header record
        -- or from the first line
        IF (I = p_x_line_tbl.FIRST) THEN
          IF (p_x_header_rec.header_id IS NOT NULL AND
            p_x_header_rec.header_id <> FND_API.G_MISS_NUM) THEN
		  l_header_id := p_x_header_rec.header_id;
          ELSIF (p_x_line_tbl(I).header_id IS NOT NULL AND
            p_x_line_tbl(I).header_id <> FND_API.G_MISS_NUM) THEN
		  l_header_id := p_x_line_tbl(I).header_id;
          END IF;
        END IF;

        IF p_x_line_tbl(I).operation <> OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_tbl(I).header_id IS NULL OR
            p_x_line_tbl(I).header_id = FND_API.G_MISS_NUM)
        THEN
          IF (l_header_id IS NOT NULL AND
              l_header_id <> FND_API.G_MISS_NUM) THEN
		    p_x_line_tbl(I).header_id := l_header_id;
	     ELSE
	         oe_line_util.query_header
				   (p_line_id => p_x_line_tbl(I).line_id,
			         x_header_id => l_header_id);
              p_x_line_tbl(I).header_id := l_header_id;
	     END IF;
        END IF;

        -- Copy the parent ID (header ID), if not passed, on
        -- the record for CREATE operations
        IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE THEN
          IF  (p_x_line_tbl(I).header_id IS NULL OR
            p_x_line_tbl(I).header_id = FND_API.G_MISS_NUM)
          THEN
            --  Copy parent_id.
            p_x_line_tbl(I).header_id := l_header_id;
	  END IF;
        END IF;

        -- Raise error if the header ID for the line is different
        -- from header ID on the header record or other lines
        IF (l_header_id IS NOT NULL AND
            l_header_id <> FND_API.G_MISS_NUM) THEN
            IF p_x_line_tbl(I).header_id <> l_header_id THEN
                fnd_message.set_name('ONT', 'OE_HEADER_MISSING');
                oe_msg_pub.add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- END: CHECK IF ALL LINES BELONG TO THE SAME ORDER

        I := p_x_line_tbl.NEXT(I);

    END LOOP;


    -- Pre Split Process
    IF l_call_split THEN
      OE_Split_Util.Check_Split_Course
	 ( p_x_line_tbl => p_x_line_tbl,
	   p_x_line_adj_tbl => p_x_line_adj_tbl,
	   p_x_line_scredit_tbl => p_x_line_scredit_tbl
	  );
    END IF;

    --  Lines

    IF p_x_line_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE LINES PROCESSING' , 2 ) ;
    END IF;
    Lines
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_line_tbl                  => p_x_line_tbl
    ,   p_x_old_line_tbl              => l_old_line_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF p_control_rec.process_partial THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER LINES PROCESSING' , 2 ) ;
    END IF;

    END IF;


    I := p_x_line_scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE SC TABLE' ) ;
        END IF;
        IF p_x_line_scredit_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_scredit_tbl(I).line_id IS NULL OR
            p_x_line_scredit_tbl(I).line_id = FND_API.G_MISS_NUM)
        THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE SC TABLE' , 2 ) ;
            END IF;

            --  Check If parent exists.

            IF p_x_line_tbl.EXISTS(p_x_line_scredit_tbl(I).line_index) THEN

                --  Copy parent_id.

                p_x_line_scredit_tbl(I).line_id := p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).line_id;
                p_x_line_scredit_tbl(I).header_id := p_x_line_tbl(p_x_line_scredit_tbl(I).line_index).header_id;

                -- Following procedure is called to fix bug 2482365
                -- If sales credit info is passed by the user we will honor it.
                -- Any sales credit record created for this line so far shall be deleted.

                OE_Line_Scredit_Util.Delete_Row(p_line_id =>p_x_line_scredit_tbl(I).line_id);
          ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_INDEX ) ||'ON LINE SALES CREDITS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Scredit');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_scredit_tbl(I).line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
       END IF;

       I := p_x_line_scredit_tbl.NEXT(I);
    END LOOP;


  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
    I := p_x_line_payment_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE SC TABLE' ) ;
        END IF;
        IF p_x_line_payment_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_payment_tbl(I).line_id IS NULL OR
            p_x_line_payment_tbl(I).line_id = FND_API.G_MISS_NUM)
        THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE PAYMENT TABLE' , 2 ) ;
            END IF;

            --  Check If parent exists.

            IF p_x_line_tbl.EXISTS(p_x_line_payment_tbl(I).line_index) THEN

                --  Copy parent_id.

                p_x_line_payment_tbl(I).line_id := p_x_line_tbl(p_x_line_payment_tbl(I).line_index).line_id;
                p_x_line_payment_tbl(I).header_id := p_x_line_tbl(p_x_line_payment_tbl(I).line_index).header_id;

          ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_INDEX ) ||'ON LINE SALES CREDITS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Payment');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_payment_tbl(I).line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
       END IF;

       I := p_x_line_payment_tbl.NEXT(I);
    END LOOP;
  END IF;


    I := p_x_line_adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE ADJ TABLE' , 2 ) ;
        END IF;

        IF p_x_line_adj_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_adj_tbl(I).line_id IS NULL OR
            p_x_line_adj_tbl(I).line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ADJ TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF p_x_line_adj_tbl(I).line_index <> fnd_api.g_miss_num and
			p_x_line_tbl.EXISTS(p_x_line_adj_tbl(I).line_index) THEN

                --  Copy parent_id.

                p_x_line_adj_tbl(I).line_id := p_x_line_tbl(p_x_Line_adj_tbl(I).line_index).line_id;
                p_x_line_adj_tbl(I).header_id := p_x_line_tbl(p_x_Line_adj_tbl(I).line_index).header_id;

            ELSIF p_x_line_adj_tbl(I).header_id is not null and
				p_x_line_adj_tbl(I).header_id <> FND_API.G_MISS_NUM Then
			-- Treat the adjustment record as a header_adjustment record
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TREATING THE RECORD AS HEADER_ADJUSTMENT' ) ;
			END IF;
		  ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_INDEX ) ||'ON PRICE ADJUSTMENTS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_adj_tbl(I).line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;

        I := p_x_line_adj_tbl.NEXT(I);
    END LOOP;

    --  Perform line group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE)
    THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PROCESS LINE REQUESTS' ) ;
            END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Lines Adjustments
    -------------------------------------------------------

    IF p_x_line_adj_tbl.COUNT > 0 THEN

    --  Line_Adjs

    oe_order_adj_pvt.Line_Adjs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_tbl              => p_x_line_adj_tbl
    ,   p_x_old_Line_Adj_tbl          => l_old_line_Adj_tbl
    );

    END IF;

    --  Perform Line_Adj group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE_ADJ)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    -------------------------------------------------------
    -- Process Line Sales Credits
    -------------------------------------------------------

    --  Line_Scredits

    IF p_x_line_scredit_tbl.COUNT > 0 THEN

      Line_Scredits
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Line_Scredit_tbl          => p_x_line_scredit_tbl
      ,   p_x_old_Line_Scredit_tbl      => l_old_line_Scredit_tbl
      ,   x_return_status               => l_return_status
      );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  IF p_control_rec.process_partial THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

    END IF;

    --  Perform Line_Scredit group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE_SCREDIT)
    THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSING DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSED DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Line Payments
    -------------------------------------------------------

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
    --  Line_Payments

    IF p_x_line_payment_tbl.COUNT > 0 THEN

      Line_Payments
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Line_Payment_tbl          => p_x_line_Payment_tbl
      ,   p_x_old_Line_Payment_tbl      => l_old_line_Payment_tbl
      ,   x_return_status               => l_return_status
      );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  IF p_control_rec.process_partial THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

    END IF;

    --  Perform Line_Payment group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE_PAYMENT)
    THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSING DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_PAYMENT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSED DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
  END IF;

    -------------------------------------------------------
    -- Process Lot Serials
    -------------------------------------------------------

    IF p_x_lot_serial_tbl.COUNT > 0 THEN

    --  Load parent key if missing and operation is create.

    I := p_x_lot_serial_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_lot_serial_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_lot_serial_tbl(I).line_id IS NULL OR
            p_x_lot_serial_tbl(I).line_id = FND_API.G_MISS_NUM)
        THEN

            --  Check If parent exists.

            IF p_x_line_tbl.EXISTS(p_x_lot_serial_tbl(I).line_index) THEN

                --  Copy parent_id.

                p_x_lot_serial_tbl(I).line_id := p_x_line_tbl(p_x_Lot_serial_tbl(I).line_index).line_id;

            ELSE

                IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
                THEN

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Lot_Serial');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_lot_serial_tbl(I).line_index);
                    oe_msg_pub.Add;

                END IF;
            END IF;
            END IF;
        I := p_x_lot_serial_tbl.NEXT(I);
    END LOOP;

    --  Lot_Serials

    Lot_Serials
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Lot_Serial_tbl            => p_x_lot_serial_tbl
    ,   p_x_old_Lot_Serial_tbl        => l_old_lot_Serial_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  IF p_control_rec.process_partial THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    END IF;

    --  Perform Lot_Serial group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LOT_SERIAL)
    THEN

        NULL;

    END IF;

    -------------------------------------------------------
    -- Process Line Price Attributes
    -------------------------------------------------------

    -- Process line Price Attributes

    I := p_x_line_price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE ATTRIBUTES TABLE' , 2 ) ;
        END IF;
        IF p_x_line_price_att_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_price_att_tbl(I).line_id IS NULL OR
            p_x_line_price_att_tbl(I).line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ATTRIB TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF p_x_line_tbl.EXISTS(p_x_line_price_att_tbl(I).line_index) THEN

                --  Copy parent_id.

                p_x_line_price_Att_tbl(I).line_id := p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).line_id;
                p_x_line_price_Att_tbl(I).header_id := p_x_line_tbl(p_x_line_price_att_tbl(I).line_index).header_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( P_X_LINE_PRICE_ATT_TBL ( I ) .LINE_INDEX ) ||'ON PRICE ADJUSTMENTS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Price_Att');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_price_att_tbl(I).line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;
        I := p_x_line_price_Att_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF p_x_line_price_Att_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Price_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Price_Att_tbl        => p_x_line_price_Att_tbl
    ,   p_x_old_Line_Price_Att_tbl    => l_old_line_Price_Att_tbl
    );

    END IF;

    --  Perform Line_Price_Att group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Line_Price_Att)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Line Adjustment Attributes
    -------------------------------------------------------

    -- Process line Adj Attributes

    I := p_x_line_adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE_ADJUSTMENT_ID ON LINE ADJ ATTRIB TABLE' , 2 ) ;
        END IF;

        IF p_x_line_adj_att_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_adj_att_tbl(I).price_adjustment_id IS NULL OR
            p_x_line_adj_att_tbl(I).price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING ADJ IDS ON LINE ADJ ATTRIB TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF p_x_line_adj_tbl.EXISTS(p_x_Line_Adj_att_tbl(I).Adj_index) THEN

                --  Copy parent_id.

                p_x_line_adj_Att_tbl(I).price_adjustment_id := p_x_line_Adj_tbl(p_x_Line_Adj_att_tbl(I).Adj_index).price_adjustment_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ADJ INDEX ' ||TO_CHAR ( P_X_LINE_ADJ_ATT_TBL ( I ) .ADJ_INDEX ) ||'ON ADJ ATTRIBS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj_Att');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_adj_att_tbl(I).Adj_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;
        I := p_x_line_adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF p_x_line_adj_Att_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Adj_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_Att_tbl          => p_x_line_adj_Att_tbl
    ,   p_x_old_Line_Adj_Att_tbl      => l_old_line_Adj_Att_tbl
    );

    END IF;

    -------------------------------------------------------
    -- Process Line Adjustment Associations
    -------------------------------------------------------

    -- Process line Adj Associations

    I := p_x_line_adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE_ADJUSTMENT_ID ON LINE ADJ ASSOCS TABLE' , 2 ) ;
        END IF;
        IF p_x_line_adj_assoc_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_adj_assoc_tbl(I).price_adjustment_id IS NULL OR
            p_x_line_adj_assoc_tbl(I).price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING ADJ IDS ON LINE ADJ ASSOCS TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF p_x_line_adj_tbl.EXISTS(p_x_Line_Adj_assoc_tbl(I).Adj_index) THEN

                --  Copy parent_id.

                p_x_line_adj_Assoc_tbl(I).price_adjustment_id := p_x_line_Adj_tbl(p_x_Line_Adj_assoc_tbl(I).Adj_index).price_adjustment_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ADJ INDEX ' ||TO_CHAR ( P_X_LINE_ADJ_ASSOC_TBL ( I ) .ADJ_INDEX ) ||'ON ADJ ASSOCS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj_Assoc');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',p_x_line_adj_assoc_tbl(I).Adj_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;

        IF p_x_line_adj_assoc_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_adj_assoc_tbl(I).Line_id IS NULL OR
            p_x_line_adj_assoc_tbl(I).Line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ADJ ASSOCS TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF p_x_line_tbl.EXISTS(p_x_line_adj_assoc_tbl(I).Line_Index) THEN

                --  Copy parent_id.

                p_x_line_adj_Assoc_tbl(I).Line_Id := p_x_line_tbl(p_x_Line_Adj_assoc_tbl(I).Line_index).Line_id;
            END IF;
        END IF;

        IF p_x_line_adj_assoc_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE
        AND (p_x_line_adj_assoc_tbl(I).rltd_Price_Adj_Id IS NULL OR
            p_x_line_adj_assoc_tbl(I).rltd_Price_Adj_Id = FND_API.G_MISS_NUM)
        THEN

		  IF p_x_line_adj_Tbl.exists(p_x_Line_Adj_assoc_tbl(I).Rltd_Adj_Index) Then
            --  Copy parent_id.

              p_x_line_adj_Assoc_tbl(I).rltd_Price_Adj_Id :=
				p_x_line_adj_Tbl(p_x_Line_Adj_assoc_tbl(I).Rltd_Adj_Index).Price_adjustment_id;
            END IF;

        END IF;
        I := p_x_line_adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF p_x_line_adj_Assoc_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Adj_Assocs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_Assoc_tbl        => p_x_line_adj_Assoc_tbl
    ,   p_x_old_Line_Adj_Assoc_tbl    => l_old_line_Adj_Assoc_tbl
    );

    END IF;


    -- Step 6. Perform Delayed Requests
    --  Set entity_id on request table using the line index.

    I := p_x_action_request_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON REQUEST TABLE' , 2 ) ;
        END IF;

        IF (p_x_action_request_tbl(I).entity_code = OE_GLOBALS.G_ENTITY_HEADER) THEN

            IF (p_x_action_request_tbl(I).entity_id IS NULL OR
                p_x_action_request_tbl(I).entity_id = FND_API.G_MISS_NUM)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SETTING HEADER IDS ON REQUEST TABLE FOR HEADER ENTITY' , 2 ) ;
                END IF;
              IF p_x_header_rec.header_id IS NULL OR
                 p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
                   FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
              ELSE
                p_x_action_request_tbl(I).entity_id := p_x_header_rec.header_id;
                l_hdr_flow_status_refresh := 'Y'; -- Bug 8435946
              END IF;
            END IF;

        ELSIF (p_x_action_request_tbl(I).entity_code = OE_GLOBALS.G_ENTITY_LINE) THEN

            IF (p_x_action_request_tbl(I).entity_id IS NULL OR
                p_x_action_request_tbl(I).entity_id = FND_API.G_MISS_NUM)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SETTING LINE IDS ON REQUEST TABLE FOR LINE ENTITY' , 2 ) ;
                END IF;
            --  Check If entity record exists.

               IF p_x_line_tbl.EXISTS(p_x_action_request_tbl(I).entity_index) THEN

                --  Copy entity_id.

                  p_x_action_request_tbl(I).entity_id := p_x_line_tbl(p_x_action_request_tbl(I).entity_index).line_id;

               ELSE

                  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ENTITY INDEX ' ||TO_CHAR ( p_x_action_request_tbl ( I ) .ENTITY_INDEX ) ||'ON REQUEST TABLE FOR LINE ENTITY' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END IF;
          END IF;

        ELSIF (p_x_action_request_tbl(I).request_type = OE_GLOBALS.G_VERIFY_PAYMENT) THEN

            IF (p_x_action_request_tbl(I).entity_id IS NULL OR
                p_x_action_request_tbl(I).entity_id = FND_API.G_MISS_NUM)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SETTING HEADER IDS ON REQUEST TABLE FOR VERIFY_PAYMENT' , 2 ) ;
                END IF;
              IF p_x_header_rec.header_id IS NULL OR
                 p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
                   FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
              ELSE
                p_x_action_request_tbl(I).entity_id := p_x_header_rec.header_id;
              END IF;
            END IF;
      END IF;
	 I := p_x_action_request_tbl.NEXT(I);
    END LOOP;

-------------------------------------------------------------------------------

    --  Step 7. Perform Object group logic

    --  Perform Delayed Requests for all the the entities
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVORDB: BEFORE CALLING PROCESS_DELAYED_REQUESTS' , 2 ) ;
    END IF;
    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
       p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
          x_return_status => l_return_status
          );
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'OEXVORDB: COMPLETED PROCESS_DELAYED_REQUESTS ' || ' WITH RETURN STATUS' || L_RETURN_STATUS , 2 ) ;
                    END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    -- Only do non-WF requests.
    IF p_x_action_request_tbl.COUNT > 0 THEN

    -- Perform NON-WF Action Requests
    OE_Delayed_Requests_PVT.Process_Order_Actions
           (p_validation_level  => p_validation_level,
               p_x_request_tbl  => p_x_action_request_tbl,
               p_process_WF_Requests => FALSE);

    END IF;
   /* comm rej
    --R12 CVV2
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('after OE_Delayed_Requests_PVT.Process_Order_Actions cvv2');
    END IF;
    i := p_x_action_request_tbl.first;
    while i is not null loop
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('return_status : ' || p_x_action_request_tbl(i).return_status);
         oe_debug_pub.add('request_type : ' || p_x_action_request_tbl(i).request_type);
      END IF;
      IF p_x_action_request_tbl(i).return_status = FND_API.G_RET_STS_ERROR
         AND p_x_action_request_tbl(i).request_type = OE_GLOBALS.G_VERIFY_PAYMENT THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
      END IF;
      i := p_x_action_request_tbl.next(i);
    end loop;
    --R12 CVV2
  comm rej  */

    -- Start flows for the Entity.
    IF (p_control_rec.process AND
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL AND
        OE_GLOBALS.G_RECURSION_MODE = 'N')
    THEN
        OE_ORDER_WF_UTIL.START_ALL_FLOWS;
        -- Process WF Action requests.
        IF p_x_action_request_tbl.COUNT > 0 THEN

          OE_Delayed_Requests_PVT.Process_Order_Actions

           (p_validation_level  => p_validation_level,
               p_x_request_tbl  => p_x_action_request_tbl,
               p_process_WF_Requests => TRUE);

          -- Bug 8435946
          IF ( l_hdr_flow_status_refresh = 'Y' ) THEN
            SELECT flow_status_code into p_x_header_rec.flow_status_code
            FROM   oe_order_headers_all
            WHERE  header_id = p_x_header_rec.header_id;
          END IF;

        END IF;

    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVORDB: AFTER PROCESS_ORDER_ACTIONS' , 2 ) ;
    END IF;


    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN
        NULL;
    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN
        NULL;
    END IF;

    -- Derive return status

    IF p_x_header_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Do not need to loop through header_scredits, lines
    -- line_scredits or lot_serials as the x_return_status is set
    -- based on the x_return_status returned by the entity procedures

    I := p_x_header_adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_header_adj_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_header_adj_tbl.NEXT(I);
    END LOOP;

    I := p_x_header_price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_header_price_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_header_price_Att_tbl.NEXT(I);
    END LOOP;

    I := p_x_header_adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_header_adj_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_header_adj_Att_tbl.NEXT(I);
    END LOOP;

    I := p_x_header_adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_header_adj_Assoc_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_header_adj_Assoc_tbl.NEXT(I);
    END LOOP;

    I := p_x_line_adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_line_adj_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

		 I := p_x_line_adj_tbl.NEXT(I);
    END LOOP;

    I := p_x_line_price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_line_price_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_line_price_Att_tbl.NEXT(I);
    END LOOP;

    I := p_x_line_adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_line_adj_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_line_adj_Att_tbl.NEXT(I);
    END LOOP;

    I := p_x_line_adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_line_adj_Assoc_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := p_x_line_adj_Assoc_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'JPN: BEFORE CALLING NOTIFY , HEADER_ID IS: ' || P_X_HEADER_REC.HEADER_ID ) ;
    END IF;
--  Calling Update Notice API - Provided by OC
--  This API will notify OC about the changes happen in OM side for order

    /* Notification Project changes */
    /* Call Process_Requests_and_Notify to inform all subscribers */

 IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508') then
      /* Call Process Requests and notify */
          IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING PROCESS_REQUESTS_AND_NOTIFY FOR PACK H IN PROCESS_ORDER_AG' );
          END IF;
          Process_Requests_And_Notify(
                      p_process_requests => FALSE,
                      p_notify           => TRUE,
                      x_return_status    => l_return_status,
                      p_header_rec       => p_x_header_rec,
                      p_old_header_rec   => l_old_header_rec,
                      p_Header_Adj_tbl   => p_x_Header_Adj_tbl,
                      p_old_Header_Adj_tbl => l_old_Header_Adj_tbl,
                      p_Header_Scredit_tbl => p_x_header_Scredit_tbl,
                      p_old_Header_Scredit_tbl => l_old_Header_Scredit_tbl,
                      p_Header_Payment_tbl => p_x_header_Payment_tbl,
                      p_old_Header_Payment_tbl => l_old_Header_Payment_tbl,
                      p_line_tbl          =>p_x_line_tbl,
                      p_old_line_tbl      => l_old_line_tbl,
                      p_Line_Adj_tbl      => p_x_line_adj_tbl,
                      p_old_line_adj_tbl  => l_old_line_adj_tbl,
                      p_Line_Scredit_tbl  => p_x_Line_Scredit_tbl,
                      p_old_Line_Scredit_tbl   => l_old_line_Scredit_tbl,
                      p_Line_Payment_tbl  => p_x_Line_Payment_tbl,
                      p_old_Line_Payment_tbl   => l_old_line_Payment_tbl,
                      p_Lot_Serial_tbl    => p_x_lot_Serial_tbl,
                      p_old_Lot_Serial_tbl => l_old_Lot_Serial_tbl);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

    ELSE
        /* Pre Pack H processsing */


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CS BEFORE CALLING NOTIFY_OC API' , 1 ) ;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   p_control_rec.write_to_db = TRUE
      AND oe_order_cache.g_header_rec.booked_flag = 'Y'
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CS CALLING NOTIFY_OC API' , 1 ) ;
      END IF;

    OE_SERVICE_UTIL.Notify_OC
    (   p_api_version_number                  =>  l_api_version_number
    ,   p_init_msg_list                       =>  FND_API.G_FALSE
    ,   p_validation_level                    =>  p_validation_level
    ,   p_control_rec                         =>  p_control_rec
    ,   x_return_status                       =>  l_return_status
    ,   x_msg_count                           =>  x_msg_count
    ,   x_msg_data                            =>  x_msg_data
    ,   p_header_rec                          =>  p_x_header_rec
    ,   p_old_header_rec                      =>  l_old_header_rec
    ,   p_header_adj_tbl                      =>  p_x_header_adj_tbl
    ,   p_old_header_adj_tbl		           =>  l_old_header_adj_tbl
    ,   p_header_price_att_tbl                =>  p_x_header_price_att_tbl
    ,   p_old_header_price_att_tbl            =>  l_old_header_price_att_tbl
    ,   p_Header_Adj_Att_tbl                  =>  p_x_header_adj_Att_tbl
    ,   p_old_Header_Adj_Att_tbl              =>  l_old_header_Adj_Att_tbl
    ,   p_Header_Adj_Assoc_tbl                =>  p_x_header_adj_Assoc_tbl
    ,   p_old_Header_Adj_Assoc_tbl            =>  l_old_header_Adj_Assoc_tbl
    ,   p_Header_Scredit_tbl                  =>  p_x_header_scredit_tbl
    ,   p_old_Header_Scredit_tbl              =>  l_old_header_Scredit_tbl
--  ,   p_Header_Payment_tbl                  =>  p_x_header_Payment_tbl
--  ,   p_old_Header_Payment_tbl              =>  l_old_header_Payment_tbl
    ,   p_line_tbl                            =>  p_x_line_tbl
    ,   p_old_line_tbl                        =>  l_old_line_tbl
    ,   p_Line_Adj_tbl                        =>  p_x_line_adj_tbl
    ,   p_old_Line_Adj_tbl                    =>  l_old_line_Adj_tbl
    ,   p_Line_Price_Att_tbl                  =>  p_x_line_price_Att_tbl
    ,   p_old_Line_Price_Att_tbl              =>  l_old_line_Price_Att_tbl
    ,   p_Line_Adj_Att_tbl                    =>  p_x_line_adj_Att_tbl
    ,   p_old_Line_Adj_Att_tbl                =>  l_old_line_Adj_Att_tbl
    ,   p_Line_Adj_Assoc_tbl                  =>  p_x_line_adj_Assoc_tbl
    ,   p_old_Line_Adj_Assoc_tbl              =>  l_old_line_Adj_Assoc_tbl
    ,   p_Line_Scredit_tbl                    =>  p_x_line_scredit_tbl
    ,   p_old_Line_Scredit_tbl                =>  l_old_line_Scredit_tbl
--  ,   p_Line_Payment_tbl                    =>  p_x_line_Payment_tbl
--  ,   p_old_Line_Payment_tbl                =>  l_old_line_Payment_tbl
    ,   p_Lot_Serial_tbl                      =>  p_x_lot_serial_tbl
    ,   p_old_Lot_Serial_tbl                  =>  l_old_lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl                  =>  p_lot_serial_val_tbl
    ,   p_old_Lot_Serial_val_tbl              =>  l_old_lot_Serial_val_tbl
    ,   p_action_request_tbl	              =>  p_x_action_request_tbl
    );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER NOTIFY_OC API' , 1 ) ;
       END IF;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING ACKS' , 1 ) ;
    END IF;

    IF  OE_Globals.G_RECURSION_MODE <> 'Y' AND
        x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   l_control_rec.write_to_db = TRUE
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING ACKS API' , 1 ) ;
      END IF;

      If Oe_Code_Control.Code_Release_Level >= '110510' And
         p_x_header_rec.order_source_id in (0,2,6) And
         l_edi_ack_pfile = 'YES' Then
        OE_Acknowledgment_Pvt.Process_Acknowledgment
        (p_header_rec           => p_x_header_rec,
         p_line_tbl             => p_x_line_tbl,
         p_old_header_rec       => l_old_header_rec,
         p_old_line_tbl         => l_old_line_tbl,
         x_return_status        => l_return_status);
      Elsif l_edi_ack_pfile = 'NO' And
            p_x_header_rec.order_source_id in (0,2,6,20) Then

      OE_Acknowledgment_Pvt.Process_Acknowledgment
     (p_api_version_number 		=> 1
     ,p_init_msg_list 		        => p_init_msg_list

     ,p_header_rec 			=> p_x_header_rec
     ,p_header_adj_tbl		        => p_x_header_adj_tbl
     ,p_header_Scredit_tbl		=> p_x_header_scredit_tbl
     ,p_line_tbl 			=> p_x_line_tbl
     ,p_line_adj_tbl			=> p_x_line_adj_tbl
     ,p_line_scredit_tbl		=> p_x_line_scredit_tbl
     ,p_lot_serial_tbl		        => p_x_lot_serial_tbl
     ,p_action_request_tbl 		=> p_x_action_request_tbl

     ,p_old_header_rec 		   	=> l_old_header_rec
     ,p_old_header_adj_tbl 		=> l_old_header_adj_tbl
     ,p_old_header_Scredit_tbl 	   	=> l_old_header_scredit_tbl
     ,p_old_line_tbl 		        => l_old_line_tbl
     ,p_old_line_adj_tbl 		=> l_old_line_adj_tbl
     ,p_old_line_scredit_tbl 	   	=> l_old_line_scredit_tbl
     ,p_old_lot_serial_tbl		=> l_old_lot_serial_tbl

     ,p_buyer_seller_flag           	=> 'B'
     ,p_reject_order                	=> 'N'

     ,x_return_status                   => l_return_status
     );

     End If;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
        x_return_status := l_return_status;
     END IF;
    END IF;

END IF; /* Code Level check */

--    Bug 2909598 - do not copy return status back from local
--    variable. For errors, x_return_status is set after call to
--    every procedure. Copying now may result in copying a success
--    value back as the last procedure called returned success but
--    a prior procedure could have returned error - in this case,
--    error should be the overall return status.

--    x_return_status := l_return_status;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT PROCESS_ORDER_AG' , 1 ) ;
END IF;
END Process_Order_AG;

/*----------------------------------------------------------------
--  Start of Comments
--  API name    Process_Order
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
----------------------------------------------------------------*/
PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_x_action_request_tbl	      IN OUT NOCOPY OE_Order_PUB.request_tbl_type
,   p_action_commit				 IN  VARCHAR2 := FND_API.G_FALSE
)
IS
l_x_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
BEGIN

     Process_Order
     (   p_api_version_number            => p_api_version_number
     ,   p_init_msg_list                 => p_init_msg_list
     ,   p_validation_level              => p_validation_level
     ,   p_control_rec                   => p_control_rec
     ,   x_return_status => x_return_status

     ,   x_msg_count => x_msg_count

     ,   x_msg_data => x_msg_data

     ,   p_x_header_rec                  => p_x_header_rec
     ,   p_old_header_rec                => p_old_header_rec
     ,   p_x_Header_Adj_tbl              => p_x_Header_Adj_tbl
     ,   p_old_Header_Adj_tbl            => p_old_Header_Adj_tbl
     ,   p_x_Header_Price_Att_tbl        => p_x_Header_Price_Att_tbl
     ,   p_old_Header_Price_Att_tbl      => p_old_Header_Price_Att_tbl
     ,   p_x_Header_Adj_Att_tbl          => p_x_Header_Adj_Att_tbl
     ,   p_old_Header_Adj_Att_tbl        => p_old_Header_Adj_Att_tbl
     ,   p_x_Header_Adj_Assoc_tbl        => p_x_Header_Adj_Assoc_tbl
     ,   p_old_Header_Adj_Assoc_tbl      => p_old_Header_Adj_Assoc_tbl
     ,   p_x_Header_Scredit_tbl          => p_x_Header_Scredit_tbl
     ,   p_old_Header_Scredit_tbl        => p_old_Header_Scredit_tbl
     ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
     ,   p_x_line_tbl                    => p_x_line_tbl
     ,   p_old_line_tbl                  => p_old_line_tbl
     ,   p_x_Line_Adj_tbl                => p_x_Line_Adj_tbl
     ,   p_old_Line_Adj_tbl              => p_old_Line_Adj_tbl
     ,   p_x_Line_Price_Att_tbl          => p_x_Line_Price_Att_tbl
     ,   p_old_Line_Price_Att_tbl        => p_old_Line_Price_Att_tbl
     ,   p_x_Line_Adj_Att_tbl            => p_x_Line_Adj_Att_tbl
     ,   p_old_Line_Adj_Att_tbl          => p_old_Line_Adj_Att_tbl
     ,   p_x_Line_Adj_Assoc_tbl          => p_x_Line_Adj_Assoc_tbl
     ,   p_old_Line_Adj_Assoc_tbl        => p_old_Line_Adj_Assoc_tbl
     ,   p_x_Line_Scredit_tbl            => p_x_Line_Scredit_tbl
     ,   p_old_Line_Scredit_tbl          => p_old_Line_Scredit_tbl
     ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
     ,   p_x_Lot_Serial_tbl              => p_x_Lot_Serial_tbl
     ,   p_old_Lot_Serial_tbl            => p_old_Lot_Serial_tbl
     ,   p_Lot_Serial_val_tbl            => p_Lot_Serial_val_tbl
     ,   p_old_Lot_Serial_val_tbl        => p_old_Lot_Serial_val_tbl
     ,   p_x_action_request_tbl          => p_x_action_request_tbl
     ,   p_action_commit		 => p_action_commit
     );
END Process_Order;

-- overloaded for payments
PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_x_Header_Payment_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_x_Line_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_x_action_request_tbl	      IN OUT NOCOPY OE_Order_PUB.request_tbl_type
,   p_action_commit				 IN  VARCHAR2 := FND_API.G_FALSE
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Order';
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_header_rec                  OE_Order_PUB.Header_Rec_Type := p_x_header_rec;
l_old_header_rec              OE_Order_PUB.Header_Rec_Type := p_old_header_rec;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_price_Att_rec        OE_Order_PUB.Header_Price_Att_Rec_Type ;
l_old_Header_price_Att_rec    OE_Order_PUB.Header_Price_Att_Rec_Type ;
l_Header_price_Att_Tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Old_Header_price_Att_Tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Att_Rec          OE_Order_PUB.Header_Adj_Att_Rec_Type ;
l_old_Header_Adj_Att_Rec      OE_Order_PUB.Header_Adj_Att_Rec_Type ;
l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_Header_Adj_Assoc_Rec        OE_Order_PUB.Header_Adj_Assoc_Rec_Type ;
l_old_Header_Adj_Assoc_Rec    OE_Order_PUB.Header_Adj_Assoc_Rec_Type ;
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_Header_Scredit_rec      OE_Order_PUB.Header_Scredit_Rec_Type;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_rec                OE_Order_PUB.Line_Rec_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_Adj_rec            OE_Order_PUB.Line_Adj_Rec_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_price_Att_rec          OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_old_Line_price_Att_rec      OE_Order_PUB.Line_Price_Att_Rec_Type ;
l_Line_price_Att_Tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Old_Line_price_Att_Tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Att_Rec            OE_Order_PUB.Line_Adj_Att_Rec_Type ;
l_old_Line_Adj_Att_Rec        OE_Order_PUB.Line_Adj_Att_Rec_Type ;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_Line_Adj_Assoc_Rec          OE_Order_PUB.Line_Adj_Assoc_Rec_Type ;
l_old_Line_Adj_Assoc_Rec      OE_Order_PUB.Line_Adj_Assoc_Rec_Type ;
l_Line_Scredit_rec            OE_Order_PUB.Line_Scredit_Rec_Type;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Line_Scredit_rec        OE_Order_PUB.Line_Scredit_Rec_Type;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_Lot_Serial_rec          OE_Order_PUB.Lot_Serial_Rec_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_request_tbl		      OE_Order_PUB.REQUEST_TBL_TYPE :=
 				 		p_x_action_request_tbl;

l_lot_serial_val_tbl         OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
l_old_lot_serial_val_tbl     OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
l_line_index                  NUMBER;
l_header_id 			NUMBER;
I 					NUMBER; -- Used for as table index.
l_init_msg_list          VARCHAR2(1) := p_init_msg_list;
l_validation_level       NUMBER      := FND_API.G_VALID_LEVEL_FULL;
l_Call_Split             BOOLEAN := FALSE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_edi_ack_pfile          Varchar2(3);

BEGIN

     -- Track the recursion

       set_recursion_mode(p_Entity_Code => 1,
                          p_In_out  => 1);

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        fnd_profile.get('ONT_NEW_EDI_ACK_FWK', l_edi_ack_pfile);
        l_edi_ack_pfile := nvl(l_edi_ack_pfile, 'NO');

	IF OE_GLOBALS.G_RECURSION_MODE <> 'Y' THEN

	   SAVEPOINT Process_Order;
     END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PUB.PROCESS_ORDER' , 1 ) ;
    END IF;
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    -- Set Org Context

    OE_GLOBALS.Set_Context;

    -- Bug 1929163: improving performance by not copying in variables
    -- to local variables. Can directly work on the IN OUT variables
    -- IMPORTANT NOTE:
    -- Please add code both in process_order AND process_order_ag
    -- procedures when making further modifications. At some later point
    -- when QA has completely tested the new code path, process_order
    -- will be replaced with code in process_order_ag.

    -- With OM Family Pack I or 11.5.9 onwards, new performance code
    -- will be activated.

    IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN
       Process_Order_AG
       (   p_api_version_number                  =>  p_api_version_number
        ,   p_init_msg_list                       =>  p_init_msg_list
        ,   p_validation_level                    =>  p_validation_level
        ,   p_control_rec                         =>  p_control_rec
        ,   x_return_status                       =>  x_return_status
        ,   x_msg_count                           =>  x_msg_count
        ,   x_msg_data                            =>  x_msg_data
        ,   p_x_header_rec                        =>  p_x_header_rec
        ,   p_old_header_rec                      =>  p_old_header_rec
        ,   p_x_header_adj_tbl                    =>  p_x_header_adj_tbl
        ,   p_old_header_adj_tbl                  =>  p_old_header_adj_tbl
        ,   p_x_header_price_att_tbl              =>  p_x_header_price_att_tbl
        ,   p_old_header_price_att_tbl            =>  p_old_header_price_att_tbl
        ,   p_x_Header_Adj_Att_tbl                =>  p_x_header_adj_Att_tbl
        ,   p_old_Header_Adj_Att_tbl              =>  p_old_header_Adj_Att_tbl
        ,   p_x_Header_Adj_Assoc_tbl              =>  p_x_header_adj_Assoc_tbl
        ,   p_old_Header_Adj_Assoc_tbl            =>  p_old_header_Adj_Assoc_tbl
        ,   p_x_Header_Scredit_tbl                =>  p_x_header_scredit_tbl
        ,   p_old_Header_Scredit_tbl              =>  p_old_header_Scredit_tbl
        ,   p_x_Header_Payment_tbl                =>  p_x_header_Payment_tbl
        ,   p_old_Header_Payment_tbl              =>  p_old_header_Payment_tbl
        ,   p_x_line_tbl                          =>  p_x_line_tbl
        ,   p_old_line_tbl                        =>  p_old_line_tbl
        ,   p_x_Line_Adj_tbl                      =>  p_x_line_adj_tbl
        ,   p_old_Line_Adj_tbl                    =>  p_old_line_Adj_tbl
        ,   p_x_Line_Price_Att_tbl                =>  p_x_line_price_Att_tbl
        ,   p_old_Line_Price_Att_tbl              =>  p_old_line_Price_Att_tbl
        ,   p_x_Line_Adj_Att_tbl                  =>  p_x_line_adj_Att_tbl
        ,   p_old_Line_Adj_Att_tbl                =>  p_old_line_Adj_Att_tbl
        ,   p_x_Line_Adj_Assoc_tbl                =>  p_x_line_adj_Assoc_tbl
        ,   p_old_Line_Adj_Assoc_tbl              =>  p_old_line_Adj_Assoc_tbl
        ,   p_x_Line_Scredit_tbl                  =>  p_x_line_scredit_tbl
        ,   p_old_Line_Scredit_tbl                =>  p_old_line_Scredit_tbl
        ,   p_x_Line_Payment_tbl                  =>  p_x_line_Payment_tbl
        ,   p_old_Line_Payment_tbl                =>  p_old_line_Payment_tbl
        ,   p_x_Lot_Serial_tbl                    =>  p_x_lot_serial_tbl
        ,   p_old_Lot_Serial_tbl                  =>  p_old_lot_Serial_tbl
        ,   p_Lot_Serial_val_tbl                  =>  p_lot_serial_val_tbl
        ,   p_old_Lot_Serial_val_tbl              =>  p_old_lot_Serial_val_tbl
        ,   p_x_action_request_tbl                =>  p_x_action_request_tbl
        );
       GOTO END_OF_PROCESS_ORDER;
    END IF;

    --  Init local table variables.

    l_Header_Adj_tbl               := p_x_Header_Adj_tbl;
    l_old_Header_Adj_tbl           := p_old_Header_Adj_tbl;

	l_Header_price_Att_tbl        := p_x_Header_Price_Att_Tbl;
	l_old_Header_price_Att_tbl    := p_old_Header_Price_Att_Tbl;

	l_Header_Adj_Att_tbl          := p_x_Header_Adj_Att_Tbl;
	l_old_Header_Adj_Att_tbl      := p_old_Header_Adj_Att_Tbl;

	l_Header_Adj_Assoc_tbl        := P_x_Header_Adj_Assoc_Tbl;
	l_old_Header_Adj_Assoc_tbl    := P_old_Header_Adj_Assoc_Tbl;

    --  Init local table variables.

    l_Header_Scredit_tbl           := p_x_Header_Scredit_tbl;
    l_old_Header_Scredit_tbl       := p_old_Header_Scredit_tbl;

    --  Init local table variables.

    l_line_tbl                     := p_x_line_tbl;
    l_old_line_tbl                 := p_old_line_tbl;

    --  Init local table variables.

    l_Line_Adj_tbl                 := p_x_Line_Adj_tbl;
    l_old_Line_Adj_tbl             := p_old_Line_Adj_tbl;

	l_Line_price_Att_tbl        := p_x_Line_Price_Att_Tbl;
	l_old_Line_price_Att_tbl    := p_old_Line_Price_Att_Tbl;

	l_Line_Adj_Att_tbl          := p_x_Line_Adj_Att_Tbl;
	l_old_Line_Adj_Att_tbl      := p_old_Line_Adj_Att_Tbl;

	l_Line_Adj_Assoc_tbl        := P_x_Line_Adj_Assoc_Tbl;
	l_old_Line_Adj_Assoc_tbl    := P_old_Line_Adj_Assoc_Tbl;

    --  Init local table variables.

    l_Line_Scredit_tbl             := p_x_Line_Scredit_tbl;
    l_old_Line_Scredit_tbl         := p_old_Line_Scredit_tbl;

     --  Init local table variables.

    l_Lot_Serial_tbl               := p_x_Lot_Serial_tbl;
    l_old_Lot_Serial_tbl           := p_old_Lot_Serial_tbl;

    --  Header

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE HEADER PROCESSING' , 2 ) ;
        oe_debug_pub.add(  'HEADER_ID' || L_HEADER_REC.HEADER_ID , 2 ) ;
        oe_debug_pub.add(  'OPERATION' || L_HEADER_REC.OPERATION , 2 ) ;
    END IF;

    -------------------------------------------------------
    -- Process Header
    -------------------------------------------------------

    --Bug 2790512: Prevent processing of header if operation is invalid
    --Bug 2878121: Ignore NULL operation code
   IF l_header_rec.header_id is NOT NULL AND
        l_header_rec.header_id <> FND_API.G_MISS_NUM THEN
    IF  l_header_rec.operation IS NOT NULL AND
        l_header_rec.operation NOT IN (OE_GLOBALS.G_OPR_CREATE,
              OE_GLOBALS.G_OPR_DELETE, OE_GLOBALS.G_OPR_UPDATE,
              OE_GLOBALS.G_OPR_NONE) THEN
           FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   END IF;

    IF l_header_rec.operation IS NOT NULL
	  AND l_header_rec.operation <> OE_GLOBALS.G_OPR_NONE
    THEN

    -- This if is add to honor users sales credits if they do not
    -- want the default sales credit for the salesrep on the order

    IF l_Header_Scredit_tbl.COUNT > 0 and
	  l_header_rec.operation = oe_globals.g_opr_create THEN
      OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit  := 'N';
    END IF;

      Header
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_header_rec                => l_header_rec
      ,   p_x_old_header_rec            => l_old_header_rec
      ,   x_return_status               => l_return_status
      );

      OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit  := 'Y';

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER HEADER PROCESSING HEADER_ID = '|| TO_CHAR ( L_HEADER_REC.HEADER_ID ) , 2 ) ;
      END IF;

    --  Perform header group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER)
    THEN

        NULL;

    END IF;


    -------------------------------------------------------
    -- Process Header Adjustments
    -------------------------------------------------------

    -- Set Header Id on Hdr Adjustments

    I := l_Header_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

    --    FOR I IN 1..l_Header_Adj_tbl.COUNT LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_ADJ_TBL' , 2 ) ;
        END IF;
        l_Header_Adj_rec := l_Header_Adj_tbl(I);

        IF l_Header_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Adj_rec.header_id IS NULL OR
            l_Header_Adj_rec.header_id = FND_API.G_MISS_NUM)
        THEN
          IF l_header_rec.header_id IS NULL OR
             l_header_rec.header_id = FND_API.G_MISS_NUM THEN
            FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            --  Copy parent_id.
            l_Header_Adj_tbl(I).header_id := l_header_rec.header_id;
          END IF;
        END IF;

        -- This is added to prevent invalid  upgraded orders
        IF I = l_Header_Adj_tbl.FIRST THEN
           IF  (l_header_adj_rec.header_id IS NOT NULL AND
		      l_header_adj_rec.header_id <> FND_API.G_MISS_NUM) THEN
	      IF NOT Valid_Upgraded_Order(l_header_adj_rec.header_id ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

    END IF;

        I := l_Header_Adj_tbl.NEXT(I);

    END LOOP;

    --  Header_Adjs

    IF l_Header_Adj_tbl.COUNT > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJS PROCESSING' , 2 ) ;
      END IF;
      oe_order_adj_pvt.Header_Adjs
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Header_Adj_tbl            => l_Header_Adj_tbl
      ,   p_x_old_Header_Adj_tbl        => l_old_Header_Adj_tbl
      );
    END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_ADJS PROCESSING' , 2 ) ;
        END IF;
    --  Perform Header_Adj group requests.

    IF (p_control_rec.process AND
      OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER_ADJ)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;


    -------------------------------------------------------
    -- Process Header Price Attributes
    -------------------------------------------------------

    -- Set Header Id on Hdr Price Attributes

    I := l_Header_Price_att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_PRICE_ATT_TBL' , 2 ) ;
        END IF;
        l_Header_Price_Att_Rec := l_Header_Price_att_tbl(I);

        IF l_Header_Price_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Price_Att_rec.header_id IS NULL OR
            l_Header_Price_Att_rec.header_id = FND_API.G_MISS_NUM)
        THEN
          IF l_header_rec.header_id IS NULL OR
             l_header_rec.header_id = FND_API.G_MISS_NUM THEN
            FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          ELSE

            --  Copy parent_id.

            l_Header_Price_Att_tbl(I).header_id := l_header_rec.header_id;
          END IF;
        END IF;
        I := l_Header_Price_Att_tbl.NEXT(I);
    END LOOP;

    --  Header_Price_Atts

    IF l_Header_Price_Att_tbl.COUNT > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_PRICE_ATTS PROCESSING' , 2 ) ;
      END IF;
      oe_order_adj_pvt.Header_Price_Atts
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Header_Price_Att_tbl      => l_Header_Price_Att_tbl
      ,   p_x_old_Header_Price_Att_tbl  => l_old_Header_Price_Att_tbl
      );
    END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_PRICE_ATTS PROCESSING' , 2 ) ;
        END IF;
    --  Perform Header_Price_Att group requests.

    IF (p_control_rec.process AND
      OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
	   OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Header_Price_Att
	   )
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;


    -------------------------------------------------------
    -- Process Header Adj Attributes
    -------------------------------------------------------

    -- Set Header Id on Hdr Adj. Attributes

    I := l_Header_Adj_Att_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE ADJUSTMENT ID ON HDR_ADJ_ATTBS' , 2 ) ;
        END IF;
        l_Header_Adj_Att_rec := l_Header_Adj_Att_tbl(I);

        IF l_Header_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Adj_Att_rec.price_adjustment_id IS NULL OR
            l_Header_Adj_Att_rec.price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

		  IF l_header_Adj_Tbl.exists(l_Header_Adj_Att_Rec.Adj_index)
			Then
            --  Copy parent_id.

              l_Header_Adj_Att_tbl(I).price_adjustment_id :=
				l_header_Adj_Tbl(l_Header_Adj_Att_Rec.adj_index).price_adjustment_id;
	  	  ELSE
		     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'INVALID ADJ INDEX '|| TO_CHAR ( L_HEADER_ADJ_ATT_REC.ADJ_INDEX ) || 'ON HEADER ADJ ATTRIBUTES' , 2 ) ;
						END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
			     FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Header_Adj_Attribs');
				FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
				FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Header_Adj_Att_Rec.adj_index);
				OE_MSG_PUB.Add;
                END IF;
           END IF;

        END IF;
        I := l_Header_Adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Header_Adj_Atts
    IF l_Header_Adj_Att_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJ_ATTS PROCESSING' , 2 ) ;
    END IF;
    oe_order_adj_pvt.Header_Adj_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Adj_Att_tbl        => l_Header_Adj_Att_tbl
    ,   p_x_old_Header_Adj_Att_tbl    => l_old_Header_Adj_Att_tbl
    );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER HEADER_ADJ_ATTS PROCESSING' , 2 ) ;
        END IF;

    END IF;

    --  Perform Header_Adj_Att group requests.

    /*
    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
	   OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Header_Adj_Att
	   )
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;
    */


    -------------------------------------------------------
    -- Process Header Adjustment Associations
    -------------------------------------------------------

    -- Set Header Id on Hdr Adjustment Associations

    I := l_Header_Adj_Assoc_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER ID ON HDR_ADJ_ASSOC_TBL' , 2 ) ;
        END IF;
        l_Header_Adj_Assoc_rec := l_Header_Adj_Assoc_tbl(I);

        IF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Adj_Assoc_rec.Price_Adjustment_id IS NULL OR
            l_Header_Adj_Assoc_rec.Price_Adjustment_id = FND_API.G_MISS_NUM)
        THEN

		  IF l_header_Adj_Tbl.exists(l_Header_Adj_Assoc_Rec.Adj_Index) Then
            --  Copy parent_id.

              l_Header_Adj_Assoc_tbl(I).price_adjustment_id :=
				l_header_Adj_Tbl(l_Header_Adj_Assoc_Rec.adj_index).price_adjustment_id;
	  	  ELSE
		     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'INVALID ADJ INDEX '|| TO_CHAR ( L_HEADER_ADJ_ASSOC_REC.ADJ_INDEX ) || 'ON HEADER ADJ ATTRIBUTES' , 2 ) ;
						END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
			     FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Header_Adj_Assocs');
				FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
				FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Header_Adj_Assoc_Rec.adj_index);
				OE_MSG_PUB.Add;
                END IF;
            END IF;

        END IF;

        IF l_Header_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Adj_Assoc_rec.rltd_Price_Adj_Id IS NULL OR
            l_Header_Adj_Assoc_rec.rltd_Price_Adj_Id = FND_API.G_MISS_NUM)
        THEN

		  IF l_header_Adj_Tbl.exists(l_Header_Adj_Assoc_Rec.Rltd_Adj_Index) Then
            --  Copy parent_id.

              l_Header_Adj_Assoc_tbl(I).rltd_Price_Adj_Id :=
				l_header_Adj_Tbl(l_Header_Adj_Assoc_Rec.Rltd_Adj_Index).Price_adjustment_id;
            END IF;

        END IF;
        I := l_Header_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Header_Adj_Assocs

    IF l_Header_Adj_Assoc_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE OE_ORDER_ADJ_PVT.HEADER_ADJ_ASSOCS PROCESSING' , 2 ) ;
    END IF;
    oe_order_adj_pvt.Header_Adj_Assocs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl
    ,   p_x_old_Header_Adj_Assoc_tbl  => l_old_Header_Adj_Assoc_tbl
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER HEADER_ADJ_ASSOCS PROCESSING' , 2 ) ;
    END IF;
    END IF;

    --  Perform Header_Adj_Assoc group requests.

    /*
    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
	   OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Header_Adj_Assoc
	   )
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;
    */


    -------------------------------------------------------
    -- Process Header Sales Credits
    -------------------------------------------------------


    -- Set Header Id on Sales Credits

--    FOR I IN 1..l_Header_Scredit_tbl.COUNT LOOP

    I := l_Header_Scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER_ID ON HEADER_SCREDIT_TBL:'||to_char(l_header_rec.header_id)||'.' , 2 ) ;
        END IF;

        l_Header_Scredit_rec := l_Header_Scredit_tbl(I);

        IF l_Header_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Header_Scredit_rec.header_id IS NULL OR
		l_Header_Scredit_rec.header_id = FND_API.G_MISS_NUM)
	   THEN
             IF l_header_rec.header_id IS NULL OR      --  p_x_header_rec replaced with l_header_rec for 2896409
                l_header_rec.header_id = FND_API.G_MISS_NUM THEN
                 FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                 OE_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
             ELSE

		--  Copy parent_id.

		  l_Header_Scredit_tbl(I).header_id := l_header_rec.header_id;
             END IF;
	   END IF;

	   I := l_Header_Scredit_tbl.NEXT(I);
    END LOOP;

    --  Header_Scredits

    IF l_Header_Scredit_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE HEADER_SCREDITS PROCESSING' , 2 ) ;
    END IF;
    Header_Scredits
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Header_Scredit_tbl        => l_Header_Scredit_tbl
    ,   p_x_old_Header_Scredit_tbl    => l_old_Header_Scredit_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF p_control_rec.process_partial THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER HEADER_SCREDITS PROCESSING' , 2 ) ;
    END IF;

    END IF;

    --  Perform Header_Scredit group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -- Get header_id from the header and put it on the line.

-- Kris = decide if
-- Header id may not be passed on the header record if the operation is none
-- I think we should pass header_id on the header rec all the time

/*
	IF l_line_tbl.COUNT > 0 THEN

		For k in l_line_tbl.first .. l_line_tbl.last LOOP

		   IF  (l_line_tbl(k).header_id = FND_API.G_MISS_NUM
		   OR   l_line_tbl(k).header_id is null ) THEN

-- Kris do not loop through the lines unless they have the right header_id
-- If people pass in a header_id with a bogus value, the record should be ignored

				l_line_tbl(k).header_id := l_header_rec.header_id;

		   END IF;

		End Loop;

  	END IF;
*/


    -------------------------------------------------------
    -- Process Lines
    -------------------------------------------------------

--    FOR I IN 1..l_line_tbl.COUNT LOOP

    I := l_line_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        l_line_rec := l_line_tbl(I);

        --Bug 2790512: Prevent processing of line if operation is invalid
        --Bug 2878121: Ignore NULL operation code
        IF l_line_rec.operation IS NOT NULL AND
           l_line_rec.operation NOT IN (OE_GLOBALS.G_OPR_CREATE,
               OE_GLOBALS.G_OPR_DELETE, OE_GLOBALS.G_OPR_UPDATE,
               OE_GLOBALS.G_OPR_INSERT, OE_GLOBALS.G_OPR_NONE) THEN
           FND_MESSAGE.SET_NAME('ONT','OE_OI_OPERATION_CODE');
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_line_rec.operation = oe_globals.g_opr_update
           AND l_line_rec.split_action_code = 'SPLIT' THEN
           l_call_split := TRUE;
        END IF;

        -- START: CHECK IF ALL LINES BELONG TO THE SAME ORDER

        -- Retrieve the header ID, either from the header record
	   -- or from the first line
	   IF (I = l_line_tbl.FIRST) THEN
          IF (l_header_rec.header_id IS NOT NULL AND
            l_header_rec.header_id <> FND_API.G_MISS_NUM) THEN
		  l_header_id := l_header_rec.header_id;
          ELSIF (l_line_rec.header_id IS NOT NULL AND
            l_line_rec.header_id <> FND_API.G_MISS_NUM) THEN
		  l_header_id := l_line_tbl(I).header_id;
	     END IF;
	   END IF;

        IF l_line_rec.operation <> OE_GLOBALS.G_OPR_CREATE
        AND (l_line_rec.header_id IS NULL OR
            l_line_rec.header_id = FND_API.G_MISS_NUM)
        THEN
          IF (l_header_id IS NOT NULL AND
              l_header_id <> FND_API.G_MISS_NUM) THEN
		    l_line_tbl(I).header_id := l_header_id;
	     ELSE
	         oe_line_util.query_header
				   (p_line_id => l_line_rec.line_id,
			         x_header_id => l_header_id);
              l_line_tbl(I).header_id := l_header_id;
	     END IF;
        END IF;

        -- Copy the parent ID (header ID), if not passed, on
	   -- the record for CREATE operations
        IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
	   THEN

          IF  (l_line_rec.header_id IS NULL OR
            l_line_rec.header_id = FND_API.G_MISS_NUM)
          THEN
            --  Copy parent_id.
            l_line_tbl(I).header_id := l_header_id;
	     END IF;

        END IF;

        -- Raise error if the header ID for the line is different
	   -- from header ID on the header record or other lines
        IF (l_header_id IS NOT NULL AND
            l_header_id <> FND_API.G_MISS_NUM) THEN
            IF l_line_tbl(I).header_id <> l_header_id THEN
                fnd_message.set_name('ONT', 'OE_HEADER_MISSING');
                oe_msg_pub.add;
                RAISE FND_API.G_EXC_ERROR;
	       END IF;
        END IF;

        -- END: CHECK IF ALL LINES BELONG TO THE SAME ORDER


	   I := l_line_tbl.NEXT(I);

    END LOOP;


    -- Pre Split Process
    IF l_call_split THEN
      OE_Split_Util.Check_Split_Course
	 ( p_x_line_tbl => l_line_tbl,
	   p_x_line_adj_tbl => l_line_adj_tbl,
	   p_x_line_scredit_tbl => l_line_scredit_tbl
	  );
    END IF;

    --  Lines

    IF l_line_tbl.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE LINES PROCESSING' , 2 ) ;
    END IF;
    Lines
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_x_old_line_tbl              => l_old_line_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 IF p_control_rec.process_partial THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER LINES PROCESSING' , 2 ) ;
    END IF;

    END IF;

    --  Set Header/Line_id on Line Sc and Line Pr Adj tables using the line index.
    --  We do this so that Lines and its children can be inserted in one call.

/*        IF l_line_tbl.COUNT > 0 THEN

                 IF l_Line_Scredit_tbl.COUNT > 0 THEN

                    oe_debug_pub.add('Setting Header/Line Ids on Line SC table', 2);

                    FOR k in l_Line_Scredit_tbl.first .. l_line_Scredit_tbl.last LOOP

                       -- oe_debug_pub.add('Processing Line SC Record ' ||TO_CHAR(k), 2);

                       IF  (l_line_Scredit_tbl(k).line_index <> FND_API.G_MISS_NUM)
                           AND (l_line_Scredit_tbl(k).line_index  IS NOT NULL) THEN

                           l_line_index := l_line_Scredit_tbl(k).line_index;

                           IF l_line_tbl.EXISTS(l_line_index) THEN

                              IF (l_line_Scredit_tbl(k).line_id = FND_API.G_MISS_NUM)
                                  OR (l_line_Scredit_tbl(k).line_id IS NULL) THEN

                                  l_line_Scredit_tbl(k).line_id := l_line_tbl(l_line_index).line_id;

                              END IF; -- Line Id on Child is missing or is null


                              IF (l_line_Scredit_tbl(k).header_id = FND_API.G_MISS_NUM)
                                  OR (l_line_Scredit_tbl(k).header_id IS NULL) THEN

                                  l_line_Scredit_tbl(k).header_id := l_line_tbl(l_line_index).header_id;

                              END IF; -- Header Id on Child is missing or is null


                           ELSE -- Invalid Index

                              oe_debug_pub.add('Invalid Line Index '
                                                ||TO_CHAR(l_line_index)
                                                ||' on Line Sales Credits', 2);
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                           END IF;  -- If Valid Line Index
                        END IF; -- Line Index is not null and not missing

                    END LOOP;
                  END IF; -- If Child table has rows


                 IF l_Line_Adj_tbl.COUNT > 0 THEN

                    oe_debug_pub.add('Setting Header/Line Ids on Line Adj  table', 2);

                    FOR k in l_Line_Adj_tbl.first .. l_line_Adj_tbl.last LOOP

                       -- oe_debug_pub.add('Processing Line Adj Record ' ||TO_CHAR(k), 2);

                       IF  (l_line_Adj_tbl(k).line_index <> FND_API.G_MISS_NUM)
                           AND (l_line_Adj_tbl(k).line_index  IS NOT NULL) THEN

                           l_line_index := l_line_Adj_tbl(k).line_index;
                           oe_debug_pub.add('Line Index is '||TO_CHAR(l_line_index), 2);

                           IF l_line_tbl.EXISTS(l_line_index) THEN

                              IF (l_line_Adj_tbl(k).line_id = FND_API.G_MISS_NUM)
                                  OR (l_line_Adj_tbl(k).line_id IS NULL) THEN

                                  l_line_Adj_tbl(k).line_id := l_line_tbl(l_line_index).line_id;

                              END IF; -- Line Id on Child is missing or is null

                              IF (l_line_Adj_tbl(k).Header_id = FND_API.G_MISS_NUM)
                                  OR (l_line_Adj_tbl(k).Header_id IS NULL) THEN

                                  l_line_Adj_tbl(k).Header_id := l_line_tbl(l_line_index).Header_id;

                              END IF; -- Header Id on Child is missing or is null

                           ELSE -- Invalid Index

                              oe_debug_pub.add('Invalid Line Index '
                                                ||TO_CHAR(l_line_index)
                                                ||'on Line Price Adjustments', 2);
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                           END IF;  -- If Valid Line Index
                        END IF; -- Line Index is not null and not missing

                    END LOOP;
                  END IF; -- If Child table has rows
         END IF; -- If Line Table has rows
*/


--    FOR I IN 1..l_Line_Scredit_tbl.COUNT LOOP

    I := l_Line_Scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE SC TABLE' ) ;
        END IF;
        l_Line_Scredit_rec := l_Line_Scredit_tbl(I);

        IF l_Line_Scredit_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Scredit_rec.line_id IS NULL OR
            l_Line_Scredit_rec.line_id = FND_API.G_MISS_NUM)
        THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE SC TABLE' , 2 ) ;
            END IF;

            --  Check If parent exists.

            IF l_line_tbl.EXISTS(l_Line_Scredit_rec.line_index) THEN

                --  Copy parent_id.

                l_Line_Scredit_tbl(I).line_id := l_line_tbl(l_Line_Scredit_rec.line_index).line_id;
                l_Line_Scredit_tbl(I).header_id := l_line_tbl(l_Line_Scredit_rec.line_index).header_id;

                -- Following procedure is called to fix bug 2482365
                -- If sales credit info is passed by the user we will honor it.
                -- Any sales credit record created for this line so far shall be deleted.

                OE_Line_Scredit_Util.Delete_Row(p_line_id =>l_Line_Scredit_tbl(I).line_id);
          ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_INDEX ) ||'ON LINE SALES CREDITS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Scredit');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Line_Scredit_rec.line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
       END IF;

       I := l_Line_Scredit_tbl.NEXT(I);
    END LOOP;


--    FOR I IN 1..l_Line_Adj_tbl.COUNT LOOP

    I := l_Line_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE ADJ TABLE' , 2 ) ;
        END IF;
        l_Line_Adj_rec := l_Line_Adj_tbl(I);

        IF l_Line_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Adj_rec.line_id IS NULL OR
            l_Line_Adj_rec.line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ADJ TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF l_Line_Adj_rec.line_index <> fnd_api.g_miss_num and
			l_line_tbl.EXISTS(l_Line_Adj_rec.line_index) THEN

                --  Copy parent_id.

                l_Line_Adj_tbl(I).line_id := l_line_tbl(l_Line_Adj_rec.line_index).line_id;
                l_Line_Adj_tbl(I).header_id := l_line_tbl(l_Line_Adj_rec.line_index).header_id;

            ELSIF l_Line_Adj_tbl(I).header_id is not null and
				l_Line_Adj_tbl(I).header_id <> FND_API.G_MISS_NUM Then
			-- Treat the adjustment record as a header_adjustment record
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TREATING THE RECORD AS HEADER_ADJUSTMENT' ) ;
			END IF;
		  ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_INDEX ) ||'ON PRICE ADJUSTMENTS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Line_Adj_rec.line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;

        I := l_Line_Adj_tbl.NEXT(I);
    END LOOP;

    --  Perform line group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE)
    THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PROCESS LINE REQUESTS' ) ;
            END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Lines Adjustments
    -------------------------------------------------------

    IF l_Line_Adj_tbl.COUNT > 0 THEN

    --  Line_Adjs

    oe_order_adj_pvt.Line_Adjs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_x_old_Line_Adj_tbl          => l_old_Line_Adj_tbl
    );

    END IF;

    --  Perform Line_Adj group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE_ADJ)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    -------------------------------------------------------
    -- Process Line Sales Credits
    -------------------------------------------------------

    --  Line_Scredits

    IF l_Line_Scredit_tbl.COUNT > 0 THEN

      Line_Scredits
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_x_Line_Scredit_tbl          => l_Line_Scredit_tbl
      ,   p_x_old_Line_Scredit_tbl      => l_old_Line_Scredit_tbl
      ,   x_return_status               => l_return_status
      );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  IF p_control_rec.process_partial THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

    END IF;

    --  Perform Line_Scredit group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LINE_SCREDIT)
    THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSING DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSED DELAYED REQUESTS FOR LINES' , 2 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Lot Serials
    -------------------------------------------------------

    IF l_Lot_Serial_tbl.COUNT > 0 THEN

    --  Load parent key if missing and operation is create.

--    FOR I IN 1..l_Lot_Serial_tbl.COUNT LOOP

    I := l_Lot_Serial_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        l_Lot_Serial_rec := l_Lot_Serial_tbl(I);

        IF l_Lot_Serial_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Lot_Serial_rec.line_id IS NULL OR
            l_Lot_Serial_rec.line_id = FND_API.G_MISS_NUM)
        THEN

            --  Check If parent exists.

            IF l_line_tbl.EXISTS(l_Lot_Serial_rec.line_index) THEN

                --  Copy parent_id.

                l_Lot_Serial_tbl(I).line_id := l_line_tbl(l_Lot_Serial_rec.line_index).line_id;

            ELSE

                IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
                THEN

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Lot_Serial');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Lot_Serial_rec.line_index);
                    oe_msg_pub.Add;

                END IF;
            END IF;
            END IF;
        I := l_Lot_Serial_tbl.NEXT(I);
    END LOOP;

    --  Lot_Serials

    Lot_Serials
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Lot_Serial_tbl            => l_Lot_Serial_tbl
    ,   p_x_old_Lot_Serial_tbl        => l_old_Lot_Serial_tbl
    ,   x_return_status               => l_return_status
    );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  IF p_control_rec.process_partial THEN
	     x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    END IF;

    --  Perform Lot_Serial group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_LOT_SERIAL)
    THEN

        NULL;

    END IF;

    -------------------------------------------------------
    -- Process Line Price Attributes
    -------------------------------------------------------

    -- Process line Price Attributes

    I := l_Line_Price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON LINE ATTRIBUTES TABLE' , 2 ) ;
        END IF;
        l_Line_Price_Att_rec := l_Line_Price_Att_tbl(I);

        IF l_Line_Price_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Price_Att_rec.line_id IS NULL OR
            l_Line_Price_Att_rec.line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ATTRIB TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF l_line_tbl.EXISTS(l_Line_Price_Att_rec.line_index) THEN

                --  Copy parent_id.

                l_Line_Price_Att_tbl(I).line_id := l_line_tbl(l_Line_Price_Att_rec.line_index).line_id;
                l_Line_Price_Att_tbl(I).header_id := l_line_tbl(l_Line_Price_Att_rec.line_index).header_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID LINE INDEX ' ||TO_CHAR ( L_LINE_PRICE_ATT_REC.LINE_INDEX ) ||'ON PRICE ADJUSTMENTS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Price_Att');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Line_Price_Att_rec.line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;
        I := l_Line_Price_Att_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF l_Line_Price_Att_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Price_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Price_Att_tbl        => l_Line_Price_Att_tbl
    ,   p_x_old_Line_Price_Att_tbl    => l_old_Line_Price_Att_tbl
    );

    END IF;

    --  Perform Line_Price_Att group requests.

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Line_Price_Att)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;


    -------------------------------------------------------
    -- Process Line Adjustment Attributes
    -------------------------------------------------------

    -- Process line Adj Attributes

    I := l_Line_Adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE_ADJUSTMENT_ID ON LINE ADJ ATTRIB TABLE' , 2 ) ;
        END IF;
        l_Line_Adj_Att_rec := l_Line_Adj_Att_tbl(I);

        IF l_Line_Adj_Att_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Adj_Att_rec.price_adjustment_id IS NULL OR
            l_Line_Adj_Att_rec.price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING ADJ IDS ON LINE ADJ ATTRIB TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF l_line_Adj_tbl.EXISTS(l_Line_Adj_Att_rec.Adj_index) THEN

                --  Copy parent_id.

                l_Line_Adj_Att_tbl(I).price_adjustment_id := l_line_Adj_tbl(l_Line_Adj_Att_rec.Adj_index).price_adjustment_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ADJ INDEX ' ||TO_CHAR ( L_LINE_ADJ_ATT_REC.ADJ_INDEX ) ||'ON ADJ ATTRIBS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj_Att');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Line_Adj_Att_rec.Adj_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;
        I := l_Line_Adj_Att_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF l_Line_Adj_Att_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Adj_Atts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl
    ,   p_x_old_Line_Adj_Att_tbl      => l_old_Line_Adj_Att_tbl
    );

    END IF;

    --  Perform Line_Adj_Att group requests.
/*

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Line_Adj_Att)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
*/

    -------------------------------------------------------
    -- Process Line Adjustment Associations
    -------------------------------------------------------

    -- Process line Adj Associations

    I := l_Line_Adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING PRICE_ADJUSTMENT_ID ON LINE ADJ ASSOCS TABLE' , 2 ) ;
        END IF;
        l_Line_Adj_Assoc_rec := l_Line_Adj_Assoc_tbl(I);

        IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Adj_Assoc_rec.price_adjustment_id IS NULL OR
            l_Line_Adj_Assoc_rec.price_adjustment_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING ADJ IDS ON LINE ADJ ASSOCS TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF l_line_Adj_tbl.EXISTS(l_Line_Adj_Assoc_rec.Adj_index) THEN

                --  Copy parent_id.

                l_Line_Adj_Assoc_tbl(I).price_adjustment_id := l_line_Adj_tbl(l_Line_Adj_Assoc_rec.Adj_index).price_adjustment_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ADJ INDEX ' ||TO_CHAR ( L_LINE_ADJ_ASSOC_REC.ADJ_INDEX ) ||'ON ADJ ASSOCS' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    fnd_message.set_name('ONT','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Line_Adj_Assoc');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Line_Adj_Assoc_rec.Adj_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;

        IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Adj_Assoc_rec.Line_id IS NULL OR
            l_Line_Adj_Assoc_rec.Line_id = FND_API.G_MISS_NUM)
        THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING LINE IDS ON LINE ADJ ASSOCS TABLE' , 2 ) ;
            END IF;
            --  Check If parent exists.

            IF l_line_tbl.EXISTS(l_Line_Adj_Assoc_rec.Line_Index) THEN

                --  Copy parent_id.

                l_Line_Adj_Assoc_tbl(I).Line_Id := l_line_tbl(l_Line_Adj_Assoc_rec.Line_index).Line_id;
            END IF;
        END IF;

        IF l_Line_Adj_Assoc_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Line_Adj_Assoc_rec.rltd_Price_Adj_Id IS NULL OR
            l_Line_Adj_Assoc_rec.rltd_Price_Adj_Id = FND_API.G_MISS_NUM)
        THEN

		  IF l_Line_Adj_Tbl.exists(l_Line_Adj_Assoc_Rec.Rltd_Adj_Index) Then
            --  Copy parent_id.

              l_Line_Adj_Assoc_tbl(I).rltd_Price_Adj_Id :=
				l_Line_Adj_Tbl(l_Line_Adj_Assoc_Rec.Rltd_Adj_Index).Price_adjustment_id;
            END IF;

        END IF;
        I := l_Line_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

    --  Line_Attribs

    IF l_Line_Adj_Assoc_tbl.COUNT > 0 THEN

    oe_order_adj_pvt.Line_Adj_Assocs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl
    ,   p_x_old_Line_Adj_Assoc_tbl    => l_old_Line_Adj_Assoc_tbl
    );

    END IF;

    --  Perform Line_Adj_Assoc group requests.
/*

    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_Line_Adj_Assoc)
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
*/

    -- Step 6. Perform Delayed Requests
    --  Set entity_id on request table using the line index.
/*
    IF l_request_tbl.COUNT > 0 THEN

       oe_debug_pub.add('Setting Header/Line Ids on Line Adj  table', 2);

       FOR k in l_request_tbl.first .. l_request_tbl.last LOOP

          -- oe_debug_pub.add('Processing Line Requests ' ||TO_CHAR(k), 2);
          IF  (l_request_tbl(k).entity_code IS NULL OR
				l_request_tbl(k).entity_code = Oe_Globals.G_ENTITY_HEADER) THEN

             IF  (l_request_tbl(k).entity_id = FND_API.G_MISS_NUM
                   OR   l_request_tbl(k).entity_id is null ) THEN
               IF l_header_rec.header_id IS NULL OR
                  l_header_rec.header_id = FND_API.G_MISS_NUM THEN
                FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                OE_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
               ELSE

                l_request_tbl(k).entity_id := l_header_rec.header_id;

               END IF;
             END IF;
          ELSIF  (l_request_tbl(k).entity_code = Oe_Globals.G_ENTITY_LINE) THEN

             IF  (to_number(l_request_tbl(k).param1) <> FND_API.G_MISS_NUM)
                    AND (l_request_tbl(k).param1 IS NOT NULL) THEN

                l_line_index := to_number(l_request_tbl(k).param1)  ;
                oe_debug_pub.add('Line Index is '||TO_CHAR(l_line_index), 2);

                IF l_line_tbl.EXISTS(l_line_index) THEN

                   IF (l_request_tbl(k).entity_id = FND_API.G_MISS_NUM)
                                  OR (l_request_tbl(k).entity_id IS NULL) THEN

                      l_request_tbl(k).entity_id := l_line_tbl(l_line_index).line_id;

                   END IF; -- Line Id on Child is missing or is null

                ELSE -- Invalid Index

                    oe_debug_pub.add('Invalid Line Index '
                                      ||TO_CHAR(l_line_index)
                                      ||'on Action Request', 2);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;  -- If Valid Line Index
             END IF; -- Line Index is not null and not missing
          END IF;
       END LOOP;
    END IF; -- If Child table has rows
*/
-------------------------------------------------------------------------------

--    FOR I IN 1..l_request_tbl.COUNT LOOP

    I := l_request_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING HEADER/LINE IDS ON REQUEST TABLE' , 2 ) ;
        END IF;

        IF (l_request_tbl(I).entity_code = OE_GLOBALS.G_ENTITY_HEADER) THEN

            IF (l_request_tbl(I).entity_id IS NULL OR
                l_request_tbl(I).entity_id = FND_API.G_MISS_NUM)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SETTING HEADER IDS ON REQUEST TABLE FOR HEADER ENTITY' , 2 ) ;
                END IF;
              IF l_header_rec.header_id IS NULL OR
                 l_header_rec.header_id = FND_API.G_MISS_NUM THEN
                FND_MESSAGE.SET_NAME('ONT','OE_HEADER_MISSING');
                OE_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
              ELSE
                l_request_tbl(I).entity_id := l_header_rec.header_id;
              END IF;
            END IF;

        ELSIF (l_request_tbl(I).entity_code = OE_GLOBALS.G_ENTITY_LINE) THEN

            IF (l_request_tbl(I).entity_id IS NULL OR
                l_request_tbl(I).entity_id = FND_API.G_MISS_NUM)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SETTING LINE IDS ON REQUEST TABLE FOR LINE ENTITY' , 2 ) ;
                END IF;
            --  Check If entity record exists.

               IF l_line_tbl.EXISTS(l_request_tbl(I).entity_index) THEN

                --  Copy entity_id.

                  l_request_tbl(I).entity_id := l_line_tbl(l_request_tbl(I).entity_index).line_id;

               ELSE

                  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                                                IF l_debug_level  > 0 THEN
                                                    oe_debug_pub.add(  'INVALID ENTITY INDEX ' ||TO_CHAR ( L_REQUEST_TBL ( I ) .ENTITY_INDEX ) ||'ON REQUEST TABLE FOR LINE ENTITY' , 2 ) ;
                                                END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END IF;
          END IF;
      END IF;
	 I := l_request_tbl.NEXT(I);
    END LOOP;

-------------------------------------------------------------------------------

    --  Step 7. Perform Object group logic

    --  Perform Delayed Requests for all the the entities
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVORDB: BEFORE CALLING PROCESS_DELAYED_REQUESTS' , 2 ) ;
    END IF;
    IF (p_control_rec.process AND
    OE_GLOBALS.G_RECURSION_MODE <> 'Y') AND
       p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
          x_return_status => l_return_status
          );
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'OEXVORDB: COMPLETED PROCESS_DELAYED_REQUESTS ' || ' WITH RETURN STATUS' || L_RETURN_STATUS , 2 ) ;
                    END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    -- Only do non-WF requests.
    IF p_x_action_request_tbl.COUNT > 0 THEN

    -- Perform NON-WF Action Requests
    OE_Delayed_Requests_PVT.Process_Order_Actions
           (p_validation_level	=> p_validation_level,
	       p_x_request_tbl	=> l_request_tbl,
	       p_process_WF_Requests => FALSE);

    END IF;


    -- Start flows for the Entity.
    IF (p_control_rec.process AND
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL AND
        OE_GLOBALS.G_RECURSION_MODE = 'N')
    THEN
        OE_ORDER_WF_UTIL.START_ALL_FLOWS;
        -- Process WF Action requests.
        IF p_x_action_request_tbl.COUNT > 0 THEN

          OE_Delayed_Requests_PVT.Process_Order_Actions

           (p_validation_level	=> p_validation_level,
	       p_x_request_tbl	=> l_request_tbl,
	       p_process_WF_Requests => TRUE);

        END IF;

    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVORDB: AFTER PROCESS_ORDER_ACTIONS' , 2 ) ;
    END IF;


    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN
        NULL;
    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN
        NULL;
    END IF;

    -- Derive return status

    IF l_header_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Do not need to loop through header_scredits, lines
    -- line_scredits or lot_serials as the x_return_status is set
    -- based on the x_return_status returned by the entity procedures

--    FOR I IN 1..l_Header_Adj_tbl.COUNT LOOP
    I := l_Header_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Header_Adj_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Header_Adj_tbl.NEXT(I);
    END LOOP;

    I := l_Header_Price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Header_Price_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Header_Price_Att_tbl.NEXT(I);
    END LOOP;

    I := l_Header_Adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Header_Adj_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Header_Adj_Att_tbl.NEXT(I);
    END LOOP;

    I := l_Header_Adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Header_Adj_Assoc_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Header_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

--    FOR I IN 1..l_Line_Adj_tbl.COUNT LOOP

    I := l_Line_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Line_Adj_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

		 I := l_Line_Adj_tbl.NEXT(I);
    END LOOP;

    I := l_Line_Price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Line_Price_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Line_Price_Att_tbl.NEXT(I);
    END LOOP;

    I := l_Line_Adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Line_Adj_Att_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Line_Adj_Att_tbl.NEXT(I);
    END LOOP;

    I := l_Line_Adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF l_Line_Adj_Assoc_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	      I := l_Line_Adj_Assoc_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'JPN: BEFORE CALLING NOTIFY , HEADER_ID IS: ' || L_HEADER_REC.HEADER_ID ) ;
    END IF;
--  Calling Update Notice API - Provided by OC
--  This API will notify OC about the changes happen in OM side for order

    /* Notification Project changes */
    /* Call Process_Requests_and_Notify to inform all subscribers */

 IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508') then
      /* Call Process Requests and notify */
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING PROCESS_REQUESTS_AND_NOTIFY FOR PACK H' ) ;
          END IF;
          Process_Requests_And_Notify(
                      p_process_requests => FALSE,
                      p_notify           => TRUE,
                      x_return_status    => l_return_status,
                      p_header_rec       => l_header_rec,
                      p_old_header_rec   => l_old_header_rec,
                      p_Header_Adj_tbl   => l_Header_Adj_tbl,
                      p_old_Header_Adj_tbl => l_old_Header_Adj_tbl,
                      p_Header_Scredit_tbl => l_header_Scredit_tbl,
                      p_old_Header_Scredit_tbl => l_old_Header_Scredit_tbl,
                      p_line_tbl          => l_line_tbl,
                      p_old_line_tbl      => l_old_line_tbl,
                      p_Line_Adj_tbl      => l_line_adj_tbl,
                      p_old_line_adj_tbl  => l_old_line_adj_tbl,
                      p_Line_Scredit_tbl  => l_Line_Scredit_tbl,
                      p_old_Line_Scredit_tbl   => l_old_line_Scredit_tbl,
                      p_Lot_Serial_tbl    => l_lot_Serial_tbl,
                      p_old_Lot_Serial_tbl => l_old_Lot_Serial_tbl);

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

    ELSE
      /* Pre Pack H processsing */

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CS BEFORE CALLING NOTIFY_OC API' , 1 ) ;
       END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   p_control_rec.write_to_db = TRUE
    AND oe_order_cache.g_header_rec.booked_flag = 'Y'
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CS CALLING NOTIFY_OC API' , 1 ) ;
      END IF;

    OE_SERVICE_UTIL.Notify_OC
    (   p_api_version_number                  =>  l_api_version_number
    ,   p_init_msg_list                       =>  l_init_msg_list
    ,   p_validation_level                    =>  l_validation_level
    ,   p_control_rec                         =>  p_control_rec
    ,   x_return_status                       =>  l_return_status
    ,   x_msg_count                           =>  x_msg_count
    ,   x_msg_data                            =>  x_msg_data
    ,   p_header_rec                          =>  l_header_rec
    ,   p_old_header_rec                      =>  l_old_header_rec
    ,   p_header_adj_tbl                      =>  l_header_adj_tbl
    ,   p_old_header_adj_tbl		           =>  l_old_header_adj_tbl
    ,   p_header_price_att_tbl                =>  l_header_price_att_tbl
    ,   p_old_header_price_att_tbl            =>  l_old_header_price_att_tbl
    ,   p_Header_Adj_Att_tbl                  =>  l_Header_Adj_Att_tbl
    ,   p_old_Header_Adj_Att_tbl              =>  l_old_Header_Adj_Att_tbl
    ,   p_Header_Adj_Assoc_tbl                =>  l_Header_Adj_Assoc_tbl
    ,   p_old_Header_Adj_Assoc_tbl            =>  l_old_Header_Adj_Assoc_tbl
    ,   p_Header_Scredit_tbl                  =>  l_Header_Scredit_tbl
    ,   p_old_Header_Scredit_tbl              =>  l_old_Header_Scredit_tbl
    ,   p_line_tbl                            =>  l_line_tbl
    ,   p_old_line_tbl                        =>  l_old_line_tbl
    ,   p_Line_Adj_tbl                        =>  l_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl                    =>  l_old_Line_Adj_tbl
    ,   p_Line_Price_Att_tbl                  =>  l_Line_Price_Att_tbl
    ,   p_old_Line_Price_Att_tbl              =>  l_old_Line_Price_Att_tbl
    ,   p_Line_Adj_Att_tbl                    =>  l_Line_Adj_Att_tbl
    ,   p_old_Line_Adj_Att_tbl                =>  l_old_Line_Adj_Att_tbl
    ,   p_Line_Adj_Assoc_tbl                  =>  l_Line_Adj_Assoc_tbl
    ,   p_old_Line_Adj_Assoc_tbl              =>  l_old_Line_Adj_Assoc_tbl
    ,   p_Line_Scredit_tbl                    =>  l_Line_Scredit_tbl
    ,   p_old_Line_Scredit_tbl                =>  l_old_Line_Scredit_tbl
    ,   p_Lot_Serial_tbl                      =>  l_Lot_Serial_tbl
    ,   p_old_Lot_Serial_tbl                  =>  l_old_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl                  =>  l_Lot_Serial_val_tbl
    ,   p_old_Lot_Serial_val_tbl              =>  l_old_Lot_Serial_val_tbl
    ,   p_action_request_tbl	                 =>  l_request_tbl
    );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER NOTIFY_OC API' , 1 ) ;
       END IF;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING ACKS' , 1 ) ;
    END IF;
      -- Following check is commented to fix 2380911
    IF -- OE_Globals.G_RECURSION_MODE <> 'Y' AND
        x_return_status = FND_API.G_RET_STS_SUCCESS AND
	   l_control_rec.write_to_db = TRUE
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING ACKS API' , 1 ) ;
      END IF;

      If Oe_Code_Control.Code_Release_Level >= '110510' And
           l_header_rec.order_source_id in (0,2,6) And
           l_edi_ack_pfile = 'YES' Then
        OE_Acknowledgment_Pvt.Process_Acknowledgment
        (p_header_rec           => l_header_rec,
         p_line_tbl             => l_line_tbl,
         p_old_header_rec       => l_old_header_rec,
         p_old_line_tbl         => l_old_line_tbl,
         x_return_status        => l_return_status);
     Elsif l_edi_ack_pfile = 'NO'  And
         p_x_header_rec.order_source_id in (0,2,6,20) Then
      OE_Acknowledgment_Pvt.Process_Acknowledgment
     (p_api_version_number 		=> 1
     ,p_init_msg_list 		        => p_init_msg_list

     ,p_header_rec 			=> l_header_rec
     ,p_header_adj_tbl		        => l_header_adj_tbl
     ,p_header_Scredit_tbl		=> l_header_scredit_tbl
     ,p_line_tbl 			=> l_line_tbl
     ,p_line_adj_tbl			=> l_line_adj_tbl
     ,p_line_scredit_tbl		=> l_line_scredit_tbl
     ,p_lot_serial_tbl		        => l_lot_serial_tbl
     ,p_action_request_tbl 		=> l_request_tbl

     ,p_old_header_rec 		   	=> l_old_header_rec
     ,p_old_header_adj_tbl 		=> l_old_header_adj_tbl
     ,p_old_header_Scredit_tbl 	   	=> l_old_header_scredit_tbl
     ,p_old_line_tbl 		        => l_old_line_tbl
     ,p_old_line_adj_tbl 		=> l_old_line_adj_tbl
     ,p_old_line_scredit_tbl 	   	=> l_old_line_scredit_tbl
     ,p_old_lot_serial_tbl		=> l_old_lot_serial_tbl

     ,p_buyer_seller_flag           	=> 'B'
     ,p_reject_order                	=> 'N'

     ,x_return_status                   => l_return_status
     );
     End If;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
        x_return_status := l_return_status;
     END IF;
    END IF;

  END IF; /* Code Level check */

    --  Done processing, load OUT parameters.

    p_x_header_rec                   := l_header_rec;
    p_x_Header_Adj_tbl               := l_Header_Adj_tbl;
    p_x_Header_Price_Att_tbl         := l_Header_Price_Att_tbl;
    p_x_Header_Adj_Att_tbl           := l_Header_Adj_Att_tbl;
    p_x_Header_Adj_Assoc_tbl         := l_Header_Adj_Assoc_tbl;
    p_x_Header_Scredit_tbl           := l_Header_Scredit_tbl;
    p_x_line_tbl                     := l_line_tbl;
    p_x_Line_Adj_tbl                 := l_Line_Adj_tbl;
    p_x_Line_Price_Att_tbl           := l_Line_Price_Att_tbl;
    p_x_Line_Adj_Att_tbl             := l_Line_Adj_Att_tbl;
    p_x_Line_Adj_Assoc_tbl           := l_Line_Adj_Assoc_tbl;
    p_x_Line_Scredit_tbl             := l_Line_Scredit_tbl;
    p_x_Lot_Serial_tbl               := l_Lot_Serial_tbl;
    p_x_action_request_tbl           := l_request_tbl;

    <<END_OF_PROCESS_ORDER>>
    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    set_recursion_mode(p_Entity_Code => 1,
                                   p_In_out  => 0);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'GLOBAL REQUEST TABLE COUNT- PO'|| OE_DELAYED_REQUESTS_PVT.G_DELAYED_REQUESTS.COUNT , 1 ) ;
       oe_debug_pub.add(  'EXITING OE_ORDER_PUB.PROCESS_ORDER' , 1 ) ;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PO: EXITING PROCESS ORDER WITH ERROR' , 2 ) ;
        END IF;
        set_recursion_mode(p_Entity_Code => 1,
                                   p_In_out  => 0);
        OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
        OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
        x_return_status := FND_API.G_RET_STS_ERROR;

	   IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
		    IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  'DELETE REQUEST11' , 2 ) ;
		    END IF;

           OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
           OE_ORDER_WF_UTIL.CLEAR_FLOWSTART_GLOBALS;
  	      ROLLBACK TO SAVEPOINT Process_Order;

	   END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PO: EXITING PROCESS ORDER WITH UNEXPECTED ERROR' , 2 ) ;
        END IF;
        set_recursion_mode(p_Entity_Code => 1,
                                   p_In_out  => 0);
        OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
        OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	   IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
		    IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  'DELETE REQUEST12' , 2 ) ;
		    END IF;

           OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
           OE_ORDER_WF_UTIL.CLEAR_FLOWSTART_GLOBALS;
	      ROLLBACK TO SAVEPOINT Process_Order;


	   END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PO: EXITING PROCESS ORDER WITH OTHERS ERROR' , 2 ) ;
        END IF;
        set_recursion_mode(p_Entity_Code => 1,
                                   p_In_out  => 0);
        OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
        OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	   IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
		    IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  'DELETE REQUEST13' , 2 ) ;
		    END IF;

          OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
                 OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
           END IF;
        OE_ORDER_WF_UTIL.CLEAR_FLOWSTART_GLOBALS;
     	ROLLBACK TO SAVEPOINT Process_Order;

        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Order;


/*---------------------------------------------------------------
--  Start of Comments
--  API name    Lock_Order
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
---------------------------------------------------------------*/
PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
) IS
l_x_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
BEGIN
   Lock_Order
    (  p_api_version_number            => p_api_version_number
   ,   p_init_msg_list                 => p_init_msg_list
   ,   x_return_status                 => x_return_status
   ,   x_msg_count                     => x_msg_count
   ,   x_msg_data                      => x_msg_data
   ,   p_x_header_rec                  => p_x_header_rec
   ,   p_x_Header_Adj_tbl              => p_x_Header_Adj_tbl
   ,   p_x_Header_Price_Att_tbl        => p_x_Header_Price_Att_tbl
   ,   p_x_Header_Adj_Att_tbl          => p_x_Header_Adj_Att_tbl
   ,   p_x_Header_Adj_Assoc_tbl        => p_x_Header_Adj_Assoc_tbl
   ,   p_x_Header_Scredit_tbl          => p_x_Header_Scredit_tbl
   ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
   ,   p_x_line_tbl                    => p_x_line_tbl
   ,   p_x_Line_Adj_tbl                => p_x_Line_Adj_tbl
   ,   p_x_Line_Price_Att_tbl          => p_x_Line_Price_Att_tbl
   ,   p_x_Line_Adj_Att_tbl            => p_x_Line_Adj_Att_tbl
   ,   p_x_Line_Adj_Assoc_tbl          => p_x_Line_Adj_Assoc_tbl
   ,   p_x_Line_Scredit_tbl            => p_x_Line_Scredit_tbl
   ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
   ,   p_x_Lot_Serial_tbl              => p_x_Lot_Serial_tbl
   );
END Lock_Order;

-- overloaded for payments parameters
PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_Header_Payment_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_Line_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Order';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
I                             NUMBER; -- Used for index.
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PVT.LOCK_ORDER' , 1 ) ;
    END IF;
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Order_PVT;

    --  Lock header

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Header_Util.Lock_Row
        (   p_x_header_rec                => p_x_header_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock Header_Adj

--    FOR I IN 1..p_Header_Adj_tbl.COUNT LOOP

    I := p_x_Header_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Header_Adj_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_Adj_Util.Lock_Row
            (   p_x_Header_Adj_rec            => p_x_Header_Adj_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Adj_tbl.NEXT(I);

    END LOOP;

    --  Lock Header_Attribs

    I := p_x_Header_Price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Header_Price_Att_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_PAttr_Util.Lock_Row
            (   p_x_Header_Price_Att_rec      => p_x_Header_Price_Att_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Price_Att_tbl.NEXT(I);

    END LOOP;

    --  Lock Header_Adj_Attribs

    I := p_x_Header_Adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Header_Adj_Att_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_Price_Aattr_Util.Lock_Row
            (   p_x_Header_Adj_Att_rec        => p_x_Header_Adj_Att_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Adj_Att_tbl.NEXT(I);

    END LOOP;

    --  Lock Header_Adj_Associations

    I := p_x_Header_Adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Header_Adj_Assoc_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_Adj_Assocs_Util.Lock_Row
            (   p_x_Header_Adj_Assoc_rec      => p_x_Header_Adj_Assoc_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Adj_Assoc_tbl.NEXT(I);

    END LOOP;

    --  Lock Header_Scredit

--    FOR I IN 1..p_Header_Scredit_tbl.COUNT LOOP

	  I := p_x_Header_Scredit_tbl.FIRST;
	  WHILE I IS NOT NULL LOOP

        IF p_x_Header_Scredit_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_Scredit_Util.Lock_Row
            (   p_x_Header_Scredit_rec        => p_x_Header_Scredit_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Scredit_tbl.NEXT(I);

    END LOOP;

    --  Lock Header_Payment

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
	  I := p_x_Header_Payment_tbl.FIRST;
	  WHILE I IS NOT NULL LOOP

        IF p_x_Header_Payment_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Header_Payment_Util.Lock_Row
            (   p_x_Header_Payment_rec        => p_x_Header_Payment_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Header_Payment_tbl.NEXT(I);

    END LOOP;
  END IF;

    --  Lock line

--    FOR I IN 1..p_line_tbl.COUNT LOOP

	  I := p_x_line_tbl.FIRST;
	  WHILE I IS NOT NULL LOOP

        IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Util.Lock_Row
            (   p_x_line_rec                  => p_x_line_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_line_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Adj

--    FOR I IN 1..p_Line_Adj_tbl.COUNT LOOP

	  I := p_x_Line_Adj_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Adj_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Adj_Util.Lock_Row
            (   p_x_Line_Adj_rec              => p_x_Line_Adj_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Adj_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Attribs

    I := p_x_Line_Price_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Price_Att_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_PAttr_Util.Lock_Row
            (   p_x_Line_Price_Att_rec            => p_x_Line_Price_Att_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Price_Att_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Adj_Attribs

    I := p_x_Line_Adj_Att_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Adj_Att_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Price_Aattr_Util.Lock_Row
            (   p_x_Line_Adj_Att_rec            => p_x_Line_Adj_Att_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Adj_Att_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Adj_Associations

    I := p_x_Line_Adj_Assoc_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Adj_Assoc_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Adj_Assocs_Util.Lock_Row
            (   p_x_Line_Adj_Assoc_rec        => p_x_Line_Adj_Assoc_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Adj_Assoc_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Scredit

--    FOR I IN 1..p_Line_Scredit_tbl.COUNT LOOP
    I := p_x_Line_Scredit_tbl.FIRST;
    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Scredit_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Scredit_Util.Lock_Row
            (   p_x_Line_Scredit_rec          => p_x_Line_Scredit_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Scredit_tbl.NEXT(I);

    END LOOP;

    --  Lock Line_Payment

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
    I := p_x_Line_Payment_tbl.FIRST;

    WHILE I IS NOT NULL LOOP

        IF p_x_Line_Payment_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Line_Payment_Util.Lock_Row
            (   p_x_Line_Payment_rec          => p_x_Line_Payment_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Line_Payment_tbl.NEXT(I);

    END LOOP;
  END IF;

    --  Lock Lot_Serial

--    FOR I IN 1..p_Lot_Serial_tbl.COUNT LOOP

	  I := p_x_Lot_Serial_tbl.FIRST;
	  WHILE I IS NOT NULL LOOP

        IF p_x_Lot_Serial_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Lot_Serial_Util.Lock_Row
            (   p_x_Lot_Serial_rec            => p_x_Lot_Serial_tbl(I)
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		 I := p_x_Lot_Serial_tbl.NEXT(I);

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

   if p_x_line_tbl.count > 0 then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'LINE ID:'||P_X_LINE_TBL ( 1 ) .LINE_ID ) ;
	END IF;
   end if;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_ORDER_PUB.LOCK_ORDER' , 1 ) ;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Order_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Order_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Order_PVT;

END Lock_Order;


/*---------------------------------------------------------------
--  Start of Comments
--  API name    Get_Order
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

--------------------------------------------------------------*/
PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_price_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
) IS
x_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
x_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
BEGIN
   Get_Order
   (   p_api_version_number            => p_api_version_number
   ,   p_init_msg_list                 => p_init_msg_list
   ,   x_return_status                 => x_return_status
   ,   x_msg_count                     => x_msg_count
   ,   x_msg_data                      => x_msg_data
   ,   p_header_id                     => p_header_id
   ,   x_header_rec                    => x_header_rec
   ,   x_Header_Adj_tbl                => x_Header_Adj_tbl
   ,   x_Header_price_Att_tbl          => x_Header_price_Att_tbl
   ,   x_Header_Adj_Att_tbl            => x_Header_Adj_Att_tbl
   ,   x_Header_Adj_Assoc_tbl          => x_Header_Adj_Assoc_tbl
   ,   x_Header_Scredit_tbl            => x_Header_Scredit_tbl
   ,   x_Header_Payment_tbl            => x_Header_Payment_tbl
   ,   x_line_tbl                      => x_line_tbl
   ,   x_Line_Adj_tbl                  => x_Line_Adj_tbl
   ,   x_Line_price_Att_tbl            => x_Line_price_Att_tbl
   ,   x_Line_Adj_Att_tbl              => x_Line_Adj_Att_tbl
   ,   x_Line_Adj_Assoc_tbl            => x_Line_Adj_Assoc_tbl
   ,   x_Line_Scredit_tbl              => x_Line_Scredit_tbl
   ,   x_Line_Payment_tbl              => x_Line_Payment_tbl
   ,   x_Lot_Serial_tbl                => x_Lot_Serial_tbl
   );
END Get_Order;

-- overloaded for payments parameters
PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_price_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order';
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
I2					   NUMBER; --Used as index.
I3					   NUMBER; --Used as index.
I4					   NUMBER; --Used as index.
I5					   NUMBER; --Used as index.
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Get header ( parent = header )

    OE_Header_Util.Query_Row
    (   p_header_id           => p_header_id
    ,   x_header_rec          => x_header_rec
    );

        --  Get Header_Adj ( parent = header )

        OE_Header_Adj_Util.Query_Rows
        (   p_header_id             => p_header_id
	   ,   x_Header_Adj_Tbl        => x_Header_Adj_Tbl
        );

        --  Get Header_Attribs ( parent = header )

        OE_Header_PAttr_Util.Query_Rows
        (   p_header_id             => p_header_id
	   ,   x_Header_Price_Att_tbl  => x_Header_Price_Att_tbl
        );


	   I2 := l_Header_Adj_tbl.FIRST;
        WHILE I2 IS NOT NULL LOOP
        --  Get Header_adj_attribs ( parent = Adjustments )

           l_Header_Adj_Att_tbl.delete;   --6052770
           Oe_Header_Price_Aattr_util.Query_Rows
           (   p_price_adjustment_id             =>
						l_Header_Adj_tbl(I2).price_adjustment_id
		 ,  x_Header_Adj_Att_tbl        => l_Header_Adj_Att_tbl
            );

	      I3 := l_Header_Adj_Att_tbl.first;

	      While I3 is not Null Loop

			l_Header_Adj_Att_tbl(I3).Adj_Index := I2;
			x_Header_Adj_Att_tbl(x_Header_Adj_Att_tbl.count+1) :=
				l_Header_Adj_Att_tbl(I3);
			I3 := l_Header_Adj_Att_tbl.Next(I3);

		 end loop;

        --  Get Header_adj_Assocs ( parent = Adjutments )

           l_Header_Adj_Assoc_Tbl.delete;  --6052770
           Oe_Header_Adj_Assocs_util.Query_Rows
           (   p_price_adjustment_id             =>
						l_header_Adj_tbl(I2).Price_Adjustment_id
           ,  x_Header_Adj_Assoc_Tbl            => l_Header_Adj_Assoc_Tbl
           );

	      I3 := l_Header_Adj_Assoc_tbl.first;

	      While I3 is not Null Loop

			l_Header_Adj_Assoc_tbl(I3).Adj_Index := I2;
			x_Header_Adj_Assoc_tbl(x_Header_Adj_Assoc_tbl.count+1) :=
				l_Header_Adj_Assoc_tbl(I3);
			I3 := l_Header_Adj_Assoc_tbl.Next(I3);

		 end loop;
	   I2 := l_header_Adj_tbl.next(I2);
	   end loop;

        --  Get Header_Scredit ( parent = header )

        OE_Header_Scredit_Util.Query_Rows
        (   p_header_id             => p_header_id
	   ,   x_Header_Scredit_tbl    => x_Header_Scredit_tbl
        );

        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
           --  Get Header_Payment ( parent = header )

           OE_Header_Payment_Util.Query_Rows
           (   p_header_id             => p_header_id
   	   ,   x_Header_Payment_tbl    => x_Header_Payment_tbl
           );
        END IF;

        --  Get line ( parent = header )

        OE_Line_Util.Query_Rows
        (   p_header_id             => p_header_id
	   ,   x_line_tbl              => x_line_tbl
        );


        --  Loop over line's children

--        FOR I2 IN 1..x_line_tbl.COUNT LOOP
		I2 := x_line_tbl.FIRST;
		WHILE I2 IS NOT NULL LOOP

            --  Get Line_Adj ( parent = line )

            l_Line_Adj_tbl.delete;  --6052770
            OE_Line_Adj_Util.Query_Rows
            (   p_line_id                 => x_line_tbl(I2).line_id
		  ,   x_Line_Adj_tbl            => l_Line_Adj_tbl
            );

			I3 := l_Line_Adj_tbl.FIRST;
			WHILE I3 IS NOT NULL LOOP

                l_Line_Adj_tbl(I3).line_Index  := I2;
                x_Line_Adj_tbl
                (x_Line_Adj_tbl.COUNT + 1)   := l_Line_Adj_tbl(I3);
			    I3 := l_Line_Adj_tbl.NEXT(I3);

               END LOOP;


            --  Get Line_Attibs ( parent = Line )

                l_Line_Price_Att_tbl.delete;  --6052770
            	OE_Line_Pattr_Util.Query_Rows
            	(   P_Line_Id  => x_line_tbl(I2).Line_id
			,   x_Line_Price_Att_tbl         => l_Line_Price_Att_tbl
            	);

			I3 := l_Line_Price_Att_tbl.FIRST;
			WHILE I3 IS NOT NULL LOOP

                l_Line_Price_Att_tbl(I3).line_Index  := I2;
                x_Line_Price_Att_tbl
                (x_Line_Price_Att_tbl.COUNT + 1)   := l_Line_Price_Att_tbl(I3);
			    I3 := l_Line_Price_Att_tbl.NEXT(I3);

               END LOOP;

            --  Get Line_Adj_Attribs ( parent = Adj )

			I4 := l_line_Adj_tbl.FIRST;
			WHILE I4 IS NOT NULL LOOP

                  l_Line_Adj_Att_tbl.delete;  --6052770
            	  Oe_Line_Price_Aattr_util.Query_Rows
            	  (   p_price_adjustment_id  =>
						l_line_Adj_tbl(I4).price_Adjustment_id
                 ,   x_Line_Adj_Att_tbl     => l_Line_Adj_Att_tbl
            	  );

			  I5 := l_Line_Adj_Att_tbl.FIRST;
			  WHILE I5 IS NOT NULL LOOP

                	l_Line_Adj_Att_tbl(I5).Adj_Index  := I4;
                	x_Line_Adj_Att_tbl
                	(x_Line_Adj_Att_tbl.COUNT + 1)   := l_Line_Adj_Att_tbl(I5);
			    	I5 := l_Line_Adj_Att_tbl.NEXT(I5);

            	  END LOOP;

            --  Get Line_Adj_Assocs ( parent = Adj )

                 l_Line_Adj_Assoc_tbl.delete;   --6052770
                 Oe_Line_Adj_Assocs_util.Query_Rows
                 (   p_price_Adjustment_id  =>
						l_line_Adj_tbl(I4).price_Adjustment_id
                 ,   x_Line_Adj_Assoc_tbl   => l_Line_Adj_Assoc_tbl
                 );

			     I5 := l_Line_Adj_Assoc_tbl.FIRST;
			     WHILE I5 IS NOT NULL LOOP

                     l_Line_Adj_Assoc_tbl(I5).Adj_Index  := I4;
                     x_Line_Adj_Assoc_tbl
                     (x_Line_Adj_Assoc_tbl.COUNT + 1)   :=
								l_Line_Adj_Assoc_tbl(I5);
			         I5 := l_Line_Adj_Assoc_tbl.NEXT(I5);

                      END LOOP;
				I4 := l_line_Adj_tbl.next(I4);
			end loop;

            --  Get Line_Scredit ( parent = line )

            l_Line_Scredit_tbl.delete;  --6052770
            OE_Line_Scredit_Util.Query_Rows
            (   p_line_id                 => x_line_tbl(I2).line_id
		  ,   x_Line_Scredit_tbl        => l_Line_Scredit_tbl
            );

--            FOR I3 IN 1..l_Line_Scredit_tbl.COUNT LOOP

			I3 := l_Line_Scredit_tbl.FIRST;
			WHILE I3 IS NOT NULL LOOP

                l_Line_Scredit_tbl(I3).line_Index := I2;
                x_Line_Scredit_tbl
                (x_Line_Scredit_tbl.COUNT + 1) := l_Line_Scredit_tbl(I3);
			    I3 := l_Line_Scredit_tbl.NEXT(I3);

            END LOOP;

            IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
               --  Get Line_Payment ( parent = line )

               l_Line_Payment_tbl.delete;  --6052770
               OE_Line_Payment_Util.Query_Rows
               (   p_line_id                 => x_line_tbl(I2).line_id
               ,   p_header_id		     => x_line_tbl(I2).header_id
   	       ,   x_Line_Payment_tbl        => l_Line_Payment_tbl
               );

			I3 := l_Line_Payment_tbl.FIRST;
			WHILE I3 IS NOT NULL LOOP

                   l_Line_Payment_tbl(I3).line_Index := I2;
                   x_Line_Payment_tbl
                   (x_Line_Payment_tbl.COUNT + 1) := l_Line_Payment_tbl(I3);
			    I3 := l_Line_Payment_tbl.NEXT(I3);

               END LOOP;
            END IF;

            --  Get Lot_Serial ( parent = line )

            l_Lot_Serial_tbl.delete;  --6052770
            OE_Lot_Serial_Util.Query_Rows
            (   p_line_id                 => x_line_tbl(I2).line_id
		  ,   x_Lot_Serial_tbl          => l_Lot_Serial_tbl
            );

--            FOR I3 IN 1..l_Lot_Serial_tbl.COUNT LOOP
			I3 := l_Lot_Serial_tbl.FIRST;
			WHILE I3 IS NOT NULL LOOP

                l_Lot_Serial_tbl(I3).line_Index := I2;
                x_Lot_Serial_tbl
                (x_Lot_Serial_tbl.COUNT + 1) := l_Lot_Serial_tbl(I3);
			    I3 := l_Lot_Serial_tbl.NEXT(I3);

            END LOOP;

			I2 := x_line_tbl.NEXT(I2);

        END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Order;


/*---------------------------------------------------------------
Procedure Cancel_Order
--------------------------------------------------------------*/

Procedure Cancel_Order
(    p_api_version_number            IN  NUMBER
,    p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,    x_can_req                       IN OUT
                                        OE_ORDER_PUB.Cancel_Line_Tbl_Type
) IS
l_api_version_number       number := 1.0;
l_api_name                 Varchar2(30) := 'CANCEL_ORDER';
l_return_status            Varchar2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin
    --  Standard call to check for call compatibility

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_PUB.CANCEL_ORDER' , 1 ) ;
    END IF;

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING OE_SALES_CAN_UTIL.CANCEL_LINE' , 2 ) ;
    END IF;
  /*  OE_SALES_CAN_UTIL.Cancel_Line
                     ( x_return_status => l_return_status
                     ,x_msg_count      => x_msg_count
                     ,x_msg_data       => x_msg_data
                     ,x_can_req         => x_can_req
                     );*/
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'COMPLETED OE_SALES_CAN_UTIL.CANCEL_LINE WITH STATUS ' || L_RETURN_STATUS , 2 ) ;
                            END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_PUB.CANCEL_ORDER' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg
             (G_PKG_NAME
              ,'Cancel_Order');
          END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
            OE_MSG_PUB.Add_Exc_Msg
	      (   G_PKG_NAME
		  ,   'Cancel_Order'
		  );
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cancel_Order;


/*------------------------------------------------------------------------
PROCEDURE Print_Time

-------------------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_MSG || ': '|| L_TIME , 1 ) ;
  END IF;
END Print_Time;



/*------------------------------------------------------------------------
PROCEDURE Complete_Config_Line

This procedure should never get called f the configuration is
created using options window or configurator, since we already
do all the work in respective code.

if p_item_type = 1, we do work related to models
if p_item_type = 2, we do work related to classes and options.

In all cases, we have a common work of loading the
in rec with BOM values, viz.
component_code
component_sequence_id
order_quantity_uom
sort_order

For p_item_type = 2,
When we come out nocopy of this procedure, all the class lines will have

item_type_code set and this plays imp role in the lines loop, when
the mode = OPTIONS.
Since any batch api caller can send in junk item_type_code, until
this procedure is executed, the item_type_code on the line_rec
should not be considered as a valid one.


I do not have to handle return status of explode_bill api.
It raises a exception if error by BOM api, check code in OEXVCFGB.pls

I guess we do not need oe_config_util.complete_configuration anymore.

Explode_Bill api will take care of the model line.

ASSUMPTION is classes are not shippable, hence we will not try to order
the way class under a class is saved.

1828866: Even if all the required fields are populated on the line,
we have to always do a select from bom_explosions. This is so that
we can figure out nocopy if all the items are currenlty part of the Bill.


Should not come here for split lines.

2221666 : order import sends option in already create model.
2299910 : copy order, sort_order for MI.
-------------------------------------------------------------------------*/
PROCEDURE Complete_Config_Line
( p_x_line_rec       IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
 ,p_item_type        IN     NUMBER
 ,p_x_line_tbl       IN     OE_ORDER_PUB.Line_Tbl_Type
 ,p_process_partial  IN     BOOLEAN := FALSE)
IS
  l_model_seq_id              NUMBER;
  l_rev_date                  DATE;
  l_validation_org            NUMBER := OE_SYS_PARAMETERS.VALUE
                                        ('MASTER_ORGANIZATION_ID');
  l_model_ordered_item        VARCHAR2(2000);
  l_bom_item_type             NUMBER;
  l_line_rec                  OE_Order_Pub.Line_Rec_Type;
  l_return_status             VARCHAR2(1);
  l_frozen_model_bill         VARCHAR2(1);
  l_old_behavior              VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --bug4015696
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_item_identifier_type      VARCHAR2(25);
BEGIN

  Print_Time('entering Complete_Config_Line');

  IF p_item_type = 1 THEN

    oe_config_pvt.Explode_Bill
    ( p_model_line_rec        => p_x_line_rec
     ,p_do_update             => FALSE
     ,p_check_effective_date  => 'N'
     ,x_config_effective_date => l_rev_date
     ,x_frozen_model_bill     => l_frozen_model_bill
     ,x_return_status         => l_return_status);

    RETURN;
  END IF;

  l_model_seq_id       :=
     p_x_line_tbl(p_x_line_rec.top_model_line_index).component_sequence_id;

  l_model_ordered_item :=
     p_x_line_tbl(p_x_line_rec.top_model_line_index).ordered_item;

  OE_Config_Util.Get_Config_Effective_Date
  ( p_model_line_rec        => p_x_line_tbl(p_x_line_rec.top_model_line_index)
   ,x_old_behavior          => l_old_behavior
   ,x_config_effective_date => l_rev_date
   ,x_frozen_model_bill     => l_frozen_model_bill);

  -- if only a class/options is created in exiting model,
  -- you need to explode the model, rare case.

  IF p_x_line_rec.top_model_line_index is NOT NULL AND
     p_x_line_rec.top_model_line_index <> FND_API.G_MISS_NUM AND
     nvl(p_x_line_tbl(p_x_line_rec.top_model_line_index).operation, 'A') <>
     OE_GLOBALS.G_OPR_CREATE
  THEN
    l_line_rec := p_x_line_tbl(p_x_line_rec.top_model_line_index);

    oe_config_pvt.Explode_Bill
    ( p_model_line_rec        => l_line_rec
     ,p_do_update             => FALSE
     ,x_config_effective_date => l_rev_date
     ,x_frozen_model_bill     => l_frozen_model_bill
     ,x_return_status         => l_return_status);

    l_model_seq_id       := l_line_rec.component_sequence_id;
    l_model_ordered_item := l_line_rec.ordered_item;
  END IF;


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('COMP_SEQ_ID OF MODEL: ' || L_MODEL_SEQ_ID , 2 ) ;
    oe_debug_pub.add('COMPLETE ITEM: '|| P_X_LINE_REC.INVENTORY_ITEM_ID ,1);
  END IF;


  BEGIN

    IF p_x_line_rec.config_header_id is not NULL AND
       p_x_line_rec.configuration_id is not NULL AND
       p_x_line_rec.config_header_id <> FND_API.G_MISS_NUM AND
       p_x_line_rec.configuration_id <> FND_API.G_MISS_NUM AND
       OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COMP_CONFIG VORDB: PACK H NEW LOGIC MI' , 1 ) ;
          oe_debug_pub.add(  'CFG_HDR '||P_X_LINE_REC.CONFIG_HEADER_ID , 3 ) ;
          oe_debug_pub.add(  'CFG_REV '||P_X_LINE_REC.CONFIG_REV_NBR , 3 ) ;
          oe_debug_pub.add(  'CFG_ID '||P_X_LINE_REC.CONFIGURATION_ID , 3 ) ;
      END IF;

      SELECT component_code, component_sequence_id, bom_sort_order,
             uom_code, bom_item_type
      INTO   p_x_line_rec.component_code, p_x_line_rec.component_sequence_id,
             p_x_line_rec.sort_order, p_x_line_rec.order_quantity_uom,
             l_bom_item_type
      FROM   cz_config_details_v
      WHERE  config_hdr_id  = p_x_line_rec.config_header_id
      AND    config_rev_nbr = p_x_line_rec.config_rev_nbr
      AND    config_item_id = p_x_line_rec.configuration_id;

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COMP_CONFIG VORDB: USING BOM_EXPLOSION' , 1 ) ;
      END IF;

      IF p_x_line_rec.component_code is not NULL AND
         p_x_line_rec.component_code <> FND_API.G_MISS_CHAR
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPONENT CODE PASSED , SOMETHING ELSE NULL' , 3 ) ;
        END IF;

        SELECT component_code, component_sequence_id, sort_order,
               primary_uom_code, bom_item_type
        INTO   p_x_line_rec.component_code, p_x_line_rec.component_sequence_id,
               p_x_line_rec.sort_order, p_x_line_rec.order_quantity_uom,
               l_bom_item_type
        FROM   bom_explosions
        WHERE  component_item_id    = p_x_line_rec.inventory_item_id
        AND    explosion_type       = Oe_Config_Util.OE_BMX_OPTION_COMPS
        AND    top_bill_sequence_id = l_model_seq_id
        AND    effectivity_date     <= l_rev_date
        AND    disable_date         >  l_rev_date
        AND    organization_id      =  l_validation_org
        AND    component_code       =  p_x_line_rec.component_code;

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPONENT CODE NOT PASSED' , 3 ) ;
        END IF;

        SELECT component_code, component_sequence_id, sort_order,
               primary_uom_code, bom_item_type
        INTO   p_x_line_rec.component_code, p_x_line_rec.component_sequence_id,
               p_x_line_rec.sort_order, p_x_line_rec.order_quantity_uom,
               l_bom_item_type
        FROM   bom_explosions
        WHERE  component_item_id    = p_x_line_rec.inventory_item_id
        AND    explosion_type       = Oe_Config_Util.OE_BMX_OPTION_COMPS
        AND    top_bill_sequence_id = l_model_seq_id
        AND    effectivity_date     <= l_rev_date
        AND    disable_date         > l_rev_date
        AND    organization_id      =  l_validation_org;
      END IF;
    END IF; -- if configuration_id is passed.

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SELECT COMP_CODE FAILED , NO DATA FOUND ' , 1 ) ;
          oe_debug_pub.add(  'ITEM: '|| P_X_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
      END IF;
      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_ITEM_NOT_IN_BILL');
      --bug4015696
      IF p_x_line_rec.ordered_item IS NULL OR
         p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR THEN
	 IF p_x_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN
	    l_item_identifier_type := NULL;
	 ELSE
	    l_item_identifier_type := p_x_line_rec.item_identifier_type;
	 END IF;
	 OE_OE_FORM_LINE.Get_Ordered_Item
	 (  x_return_status        => l_return_status
	   ,x_msg_count            => l_msg_count
	   ,x_msg_data             => l_msg_data
	   ,p_item_identifier_type => l_item_identifier_type
	   ,p_inventory_item_id    => p_x_line_rec.inventory_item_id
	   ,p_ordered_item_id      => p_x_line_rec.ordered_item_id
	   ,p_sold_to_org_id       => p_x_line_rec.sold_to_org_id
	   ,x_ordered_item         => p_x_line_rec.ordered_item   );
	 IF p_x_line_rec.ordered_item IS NULL OR
	    p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR THEN
	    FND_MESSAGE.Set_Token('ITEM',p_x_line_rec.inventory_item_id);
	 ELSE
	    FND_MESSAGE.Set_Token('ITEM',p_x_line_rec.ordered_item);
	 END IF;
      ELSE
         FND_MESSAGE.Set_Token('ITEM', p_x_line_rec.ordered_item);
      END IF;
      FND_MESSAGE.Set_Token('MODEL', nvl(l_model_ordered_item,l_line_rec.inventory_item_id));
      oe_msg_pub.add;

      IF p_process_partial THEN
        IF l_debug_level  > 0 THEN /* Bug # 4036765 */
            oe_debug_pub.add(  'PROCESS PARTIAL IS TRUE' , 3 ) ;
        END IF;
        p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
        p_x_line_rec.operation     := OE_GLOBALS.G_OPR_NONE;
        OE_GLOBALS.G_FAIL_ORDER_IMPORT := TRUE; /* Bug # 4036765 */
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS PARTIAL IS NOT TRUE' , 3 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    WHEN TOO_MANY_ROWS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SELECT COMP_CODE FAILED , TOO_MANY ROWS ' , 1 ) ;
          oe_debug_pub.add(  'ITEM: '|| P_X_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
      END IF;

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_AMBIGUITY');
      FND_MESSAGE.Set_Token('COMPONENT', p_x_line_rec.ordered_item);
      FND_MESSAGE.Set_Token('MODEL', nvl(l_model_ordered_item,l_line_rec.inventory_item_id));
      oe_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SELECT COMP_CODE FAILED , OTHERS ' , 1 ) ;
          oe_debug_pub.add(  'ITEM: '|| P_X_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;


  IF l_bom_item_type = 2 OR
     l_bom_item_type = 1 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'THIS IS A CLASS' , 5 ) ;
    END IF;
    p_x_line_rec.item_type_code := OE_GLOBALS.G_ITEM_CLASS;

  ELSIF l_bom_item_type = 4 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'THIS IS A OPTION/KIT' , 1 ) ;
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID ITEM TYPE' , 1 ) ;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'HDR/REV/ID '|| P_X_LINE_REC.CONFIG_HEADER_ID
    || P_X_LINE_REC.CONFIG_REV_NBR || P_X_LINE_REC.CONFIGURATION_ID ,1);
  END IF;

  Print_Time('leaving Complete_Config_Line');

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPLETE_CONFIG_LINE EXCEPTIION '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Complete_Config_Line;


/*-------------------------------------------------------------------------
PRODEDURE Get_Missing_Class_Lines

Do not call if p_option_lines does not have any lines.
just put index in the p_options_tbl, get a rec at a time.
p_options_tbl.line_id is actually the index of option lines.

In this procedure we will get all the missing classes, for all the
options in one call.
We decided to loop over the p_options_index_tbl instead of calling
this procedure per option line because,
  1) v.imp: switching modes back and forth between the class save vs
     option save is complicated to code, debug and maintain.
  2) p_options_index_tbl is table of numbers, not expensive, also

we are making use of the fact that the class lines are already
saved. This fact and the component_code field is used to decide
if some of the parents are missing and add them to the lines table.

when we get out nocopy of the procedure, the x_class_index contains

the index of the first newly added class, we start looping through
the lines table at thei index. if x_class_index is null, it means
no new classes were added.

-------------------------------------------------------------------------*/

PROCEDURE Get_Missing_Class_Lines
( p_x_line_tbl         IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
 ,p_options_index_tbl  IN  OE_OPTION_INDEX_TBL_TYPE
,x_class_index OUT NOCOPY NUMBER

,x_class_count OUT NOCOPY NUMBER)

IS
  I                      NUMBER;
  J                      NUMBER;
  l_add_parent           BOOLEAN;
  l_index                NUMBER;
  l_component_code       VARCHAR2(1000);
  l_model_quantity       NUMBER;
  l_model_seq_id         NUMBER;
  l_rev_date             DATE;
  l_validation_org       NUMBER := OE_SYS_PARAMETERS.VALUE
                                 ('MASTER_ORGANIZATION_ID');
  l_ato_line_id          NUMBER;
  l_option_index         NUMBER;
  l_remember_index       NUMBER;
  l_top_model_line_index NUMBER;
  l_bom_item_type        NUMBER;
  l_frozen_model_bill    VARCHAR2(1);
  l_old_behavior         VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  Print_Time('entering Get_Missing_Class_Lines');


  IF OE_Config_Util.G_Config_UI_Used = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CONFIGURATOR/OW USED , SHOULD NOT COME HERE' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  l_index          := p_x_line_tbl.LAST;
  l_remember_index := l_index;
  I                := p_options_index_tbl.FIRST;
  J                := l_index;

  WHILE I is not NULL
  LOOP
    l_option_index := p_options_index_tbl(I);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'I '|| I || ' '
      || P_X_LINE_TBL ( L_OPTION_INDEX ) .TOP_MODEL_LINE_ID , 3 ) ;
      oe_debug_pub.add(  L_OPTION_INDEX || ' '
      || P_X_LINE_TBL ( L_OPTION_INDEX ) .COMPONENT_CODE , 3 ) ;
    END IF;

    l_component_code := SUBSTR(p_x_line_tbl(l_option_index).component_code, 1,
             (INSTR(p_x_line_tbl(l_option_index).component_code, '-', -1) -1));

    WHILE l_component_code is not NULL
    LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECK IF EXIST: ' || L_COMPONENT_CODE , 1 ) ;
      END IF;

      BEGIN

        SELECT ato_line_id
        INTO   l_ato_line_id
        FROM   oe_order_lines
        WHERE  top_model_line_id
               = p_x_line_tbl(l_option_index).top_model_line_id
        AND    component_code = l_component_code
        AND    open_flag = 'Y';

      EXCEPTION
        WHEN no_data_found THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NO DATA FOUND' , 3 ) ;
          END IF;

          l_add_parent := TRUE;

          IF l_remember_index <> l_index THEN
            J            := l_remember_index + 1;
            WHILE J is NOT NULL
            LOOP
             IF p_x_line_tbl(J).component_code = l_component_code THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'DO NOT ADD' , 3 ) ;
               END IF;
               l_add_parent := FALSE;
             END IF;
             J := p_x_line_tbl.NEXT(J);
            END LOOP;

          END IF;

          IF l_add_parent THEN
            l_index := l_index + 1;

            p_x_line_tbl(l_index) := OE_Order_Pub.G_Miss_Line_Rec;

            p_x_line_tbl(l_index).operation      := OE_GLOBALS.G_OPR_CREATE;
            p_x_line_tbl(l_index).component_code := l_component_code;
            p_x_line_tbl(l_index).top_model_line_id
                  := p_x_line_tbl(l_option_index).top_model_line_id;
            p_x_line_tbl(l_index).header_id
                  :=  p_x_line_tbl(l_option_index).header_id;


            IF p_x_line_tbl(l_option_index).config_header_id is not NULL AND
               p_x_line_tbl(l_option_index).configuration_id is not NULL AND
               p_x_line_tbl(l_option_index).config_header_id <>
                                            FND_API.G_MISS_NUM AND
               p_x_line_tbl(l_option_index).configuration_id <>
                                            FND_API.G_MISS_NUM AND
               OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'VORDB: PACK H NEW LOGIC MI' , 1 ) ;
              END IF;

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('CFG_HDR '
                ||P_X_LINE_TBL ( L_OPTION_INDEX ) .CONFIG_HEADER_ID , 3 ) ;
                oe_debug_pub.add('CFG_REV '
                ||P_X_LINE_TBL ( L_OPTION_INDEX ) .CONFIG_REV_NBR , 3 ) ;
                oe_debug_pub.add('CFG_ID '
                ||P_X_LINE_TBL ( L_OPTION_INDEX ) .CONFIGURATION_ID , 3 ) ;
              END IF;

              BEGIN
                SELECT component_sequence_id, inventory_item_id,
                       bom_sort_order, uom_code, quantity, bom_item_type
                INTO  p_x_line_tbl(l_index).component_sequence_id,
                      p_x_line_tbl(l_index).inventory_item_id,
                      p_x_line_tbl(l_index).sort_order,
                      p_x_line_tbl(l_index).order_quantity_uom,
                      p_x_line_tbl(l_index).ordered_quantity,
                      l_bom_item_type
                FROM  cz_config_details_v
                WHERE component_code = l_component_code
                AND   config_hdr_id
                        = p_x_line_tbl(l_option_index).config_header_id
                AND   config_rev_nbr
                        = p_x_line_tbl(l_option_index).config_rev_nbr
                AND   config_item_id
                        = p_x_line_tbl(l_option_index).configuration_id;
              EXCEPTION
                WHEN TOO_MANY_ROWS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'CZ TOO_MANY_ROWS ' , 1 ) ;
                  END IF;
                  RAISE;
                WHEN NO_DATA_FOUND THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'CZ NO_DATA_FOUND' , 1 ) ;
                  END IF;
                  RAISE;
                WHEN OTHERS THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'CZ OTHERS' , 1 ) ;
                  END IF;
                  RAISE;
              END;
            ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'VORDB: USE BOX_EXPLOSINS' , 3 ) ;
              END IF;

              IF l_rev_date is NULL THEN

                l_top_model_line_index
                   := p_x_line_tbl(l_option_index).top_model_line_index;

                IF l_top_model_line_index is NOT NULL THEN
                  l_model_quantity
                   := p_x_line_tbl(l_top_model_line_index).ordered_quantity;
                  l_model_seq_id
                := p_x_line_tbl(l_top_model_line_index).component_sequence_id;

                  OE_Config_Util.Get_Config_Effective_Date
                  ( p_model_line_rec    => p_x_line_tbl(l_top_model_line_index)
                   ,x_old_behavior          => l_old_behavior
                   ,x_config_effective_date => l_rev_date
                   ,x_frozen_model_bill     => l_frozen_model_bill);

                ELSE

                  SELECT ordered_quantity, component_sequence_id
                  INTO   l_model_quantity, l_model_seq_id
                  FROM   oe_order_lines
                  WHERE  line_id =
                          p_x_line_tbl(l_option_index).top_model_line_id;


                  OE_Config_Util.Get_Config_Effective_Date
                  ( p_model_line_id         =>
                    p_x_line_tbl(l_option_index).top_model_line_id
                   ,x_old_behavior          => l_old_behavior
                   ,x_config_effective_date => l_rev_date
                   ,x_frozen_model_bill     => l_frozen_model_bill);

                END IF;

              END IF; -- if rev date null

                SELECT component_sequence_id, component_item_id, sort_order,
                       primary_uom_code, EXTENDED_QUANTITY * l_model_quantity,
                       bom_item_type
                INTO  p_x_line_tbl(l_index).component_sequence_id,
                      p_x_line_tbl(l_index).inventory_item_id,
                      p_x_line_tbl(l_index).sort_order,
                      p_x_line_tbl(l_index).order_quantity_uom,
                      p_x_line_tbl(l_index).ordered_quantity,
                      l_bom_item_type
                FROM  bom_explosions be
                WHERE be.explosion_type  = OE_Config_Util.OE_BMX_OPTION_COMPS
                AND   be.top_bill_sequence_id = l_model_seq_id
                AND   be.plan_level > 0
                AND   be.effectivity_date <= l_rev_date
                AND   be.disable_date > l_rev_date
                AND   be.component_code = l_component_code
                AND   rownum = 1;

            END IF; -- if pack H

            IF l_bom_item_type = 2 OR
               l_bom_item_type = 1 THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'THIS IS A CLASS' , 5 ) ;
               END IF;
               p_x_line_tbl(l_index).item_type_code
                         := OE_GLOBALS.G_ITEM_CLASS;
            END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'GET ORDERED ITEM NAME' , 3 ) ;
            END IF;

            BEGIN
              SELECT concatenated_segments
              INTO   p_x_line_tbl(l_index).ordered_item
              FROM   MTL_SYSTEM_ITEMS_KFV
              WHERE  inventory_item_id = p_x_line_tbl(I).inventory_item_id
              AND    organization_id = l_validation_org;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'NAME OF THE ITEM NOT FOUND' , 1 ) ;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END;

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add
              ('ADDED'||P_X_LINE_TBL(L_INDEX).INVENTORY_ITEM_ID,3);
            END IF;

          END IF; -- if add_parent = true

        WHEN TOO_MANY_ROWS THEN
          IF p_x_line_tbl(l_option_index).config_header_id is not NULL AND
             p_x_line_tbl(l_option_index).configuration_id is not NULL AND
             OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add
                 ('TOO MANY ROWS IN MISSING_CLASSES: PACK H NEW MI',1);
               END IF;
          ELSE
            FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MI_NOT_ALLOWED');
            FND_MESSAGE.SET_TOKEN
            ('MODEL', nvl(p_x_line_tbl(l_top_model_line_index).ordered_item,
                              p_x_line_tbl(l_top_model_line_index).inventory_item_id));
            FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
                       p_x_line_tbl(l_top_model_line_index).line_number ||
                       p_x_line_tbl(l_top_model_line_index).shipment_number);
            OE_MSG_PUB.Add;
            RAISE;
          END IF;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OTHERS IN MISSING_CLASSES '|| SQLERRM , 1 ) ;
          END IF;
          RAISE;
      END; -- to check if this comp exists

      l_component_code := SUBSTR(l_component_code, 1,
                                (INSTR(l_component_code, '-', -1) -1));

    END LOOP;

    I  := p_options_index_tbl.NEXT(I);

  END LOOP;

  IF l_index <> l_remember_index THEN
    x_class_index  := l_remember_index + 1;
  END IF;

  x_class_count := l_index - l_remember_index;

  Print_Time('leaving Get_Missing_Class_Lines '||  x_class_count);

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN GET_MISSING_CLASS_LINES '|| SQLERRM,1);
    END IF;
    RAISE;
END Get_Missing_Class_Lines;


END OE_Order_PVT;

/
