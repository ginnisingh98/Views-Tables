--------------------------------------------------------
--  DDL for Package Body OE_BULK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_ORDER_PVT" AS
/* $Header: OEBVORDB.pls 120.2.12010000.6 2010/03/05 13:00:43 srsunkar ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_ORDER_PVT';


---------------------------------------------------------------
-- LOCAL PROCEDURES
---------------------------------------------------------------

PROCEDURE Delete_Error_Records(p_batch_id NUMBER,
                               p_adjustments_exist IN VARCHAR2,
                               p_process_tax       IN VARCHAR2,
                               p_process_configurations IN VARCHAR2)
IS
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF G_ERROR_REC.order_source_id.COUNT > 0 THEN

        for i in 1..G_ERROR_REC.order_source_id.COUNT loop

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDER SOURCE :'||G_ERROR_REC.ORDER_SOURCE_ID ( I ) ) ;
                oe_debug_pub.add(  'ORIG SYS REF :'||G_ERROR_REC.ORIG_SYS_DOCUMENT_REF ( I ) ) ;
                oe_debug_pub.add(  'Header_Id  :'||G_ERROR_REC.HEADER_ID(I));
            END IF;

        end loop;

        -- Delete Holds Records
        FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
        DELETE from OE_ORDER_HOLDS
        WHERE header_id = G_ERROR_REC.header_id(i);

        -- Delete Sales Credits Records
        FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
        DELETE from OE_SALES_CREDITS
        WHERE header_id = G_ERROR_REC.header_id(i);

        -- Delete MTL Sales Order Records
        INV_SalesOrder.Delete_MTL_Sales_Orders_Bulk
             (p_api_version_number     => 1.0
             ,p_error_rec              => G_ERROR_REC
             ,x_return_status          => l_return_status
             ,x_message_count          => l_msg_count
             ,x_message_data           => l_msg_data
             );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'ERROR IN DELETE_MTL_SALES_ORDERS_BULK :' ||L_RETURN_STATUS ) ;
                            END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Delete line records
        FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
        DELETE from OE_ORDER_LINES
        WHERE header_id = G_ERROR_REC.header_id(i);

        -- Delete Header Records
        FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
        DELETE from OE_ORDER_HEADERS
        WHERE header_id = G_ERROR_REC.header_id(i);

        IF G_DBI_INSTALLED = 'Y' THEN

          -- Delete from DBI log tables
          FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
          DELETE from ONT_DBI_CHANGE_LOG
          WHERE header_id = G_ERROR_REC.header_id(i);

        END IF;

        -- Delete Adjustment Records (added for bugfix 4180619)
        IF p_adjustments_exist = 'Y'  OR p_process_tax = 'Y' THEN
            FORALL i IN 1..G_ERROR_REC.order_source_id.COUNT
            DELETE from OE_PRICE_ADJUSTMENTS
            WHERE header_id = G_ERROR_REC.header_id(i);
        END IF;

        -- Delete CZ configuration revisions
        IF (p_process_configurations = 'Y') AND
           nvl(G_CONFIGURATOR_USED, 'N') = 'Y'
        THEN
            OE_BULK_CONFIG_UTIL.Delete_Configurations
               (   p_error_rec           => G_ERROR_REC
                  ,x_return_status       => l_return_status
               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add( 'ERROR IN OE_BULK_CONFIG_UTIL.Delete_Configurations :'
                        ||L_RETURN_STATUS ) ;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;



    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Exiting Delete_Error_Records :');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Delete_Error_Records'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Error_Records;

-- This procedure marks the headers interface records as errored for
-- any invalid headers or lines that have been inserted.
PROCEDURE Process_Invalid_Records
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   --
   -- This IF ensures that subsequent calls to process invalid records
   -- does not look at error records already updated on the
   -- interface tables by prior calls.
   --
   -- For e.g. process invalid records is called after headers
   -- processing first so it marks error for all invalid headers.
   -- Next, it is called after lines processing so it should update
   -- interface tables only for invalid lines.
   --
   IF (G_ERROR_REC.order_source_id.COUNT > G_ERROR_COUNT) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COUNT :'||G_ERROR_REC.ORDER_SOURCE_ID.COUNT ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORIG SYS REF :'||G_ERROR_REC.ORIG_SYS_DOCUMENT_REF ( 1 ) ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Header_Id  :'||G_ERROR_REC.HEADER_ID(1));
          oe_debug_pub.add('G_ERROR_COUNT  :'||G_ERROR_COUNT);
          oe_debug_pub.add('G_REQUEST_ID  :'||G_REQUEST_ID);
          oe_debug_pub.add('G_ORDER_SOURCE :'||G_ERROR_REC.ORDER_SOURCE_ID(1));
      END IF;

      --ER 9060917
      If NVL (Fnd_Profile.Value('ONT_HVOP_DROP_INVALID_LINES'), 'N')='Y' then

        FORALL i IN (G_error_count+1)..G_ERROR_REC.order_source_id.COUNT
        UPDATE OE_HEADERS_IFACE_ALL
	SET ERROR_FLAG = 'Y'
	WHERE REQUEST_ID = G_REQUEST_ID
	AND ORDER_SOURCE_ID = G_ERROR_REC.order_source_id(i)
        AND ORIG_SYS_DOCUMENT_REF = G_ERROR_REC.orig_sys_document_ref(i)
        AND NOT EXISTS
	    (SELECT 1
	     FROM oe_lines_iface_all b
	     WHERE b.orig_sys_document_ref = G_ERROR_REC.orig_sys_document_ref(i)
	     AND b.order_source_id = G_ERROR_REC.order_source_id(i)
   	     AND nvl(error_flag, 'N') = 'N');

   	G_ERROR_COUNT := G_ERROR_REC.order_source_id.COUNT;

      else --old behaviour

      	FORALL i IN (G_error_count+1)..G_ERROR_REC.order_source_id.COUNT
      	UPDATE OE_HEADERS_IFACE_ALL
        SET ERROR_FLAG = 'Y'
        WHERE REQUEST_ID = G_REQUEST_ID
        AND ORDER_SOURCE_ID = G_ERROR_REC.order_source_id(i)
        AND ORIG_SYS_DOCUMENT_REF = G_ERROR_REC.orig_sys_document_ref(i);

         G_ERROR_COUNT := G_ERROR_REC.order_source_id.COUNT;

      end if;
      --End of ER 9060917

   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add( 'Exiting Process_Invalid_Records ');
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Process_Invalid_Records'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Invalid_Records;

--
-- Update_DBI_Log
-- Bulk enabled version of OEXUDBIB.pls. Is used to insert records into DBI
-- log tables about lines created during bulk import
--
PROCEDURE Update_DBI_Log
( p_line_rec                  IN OE_WSH_BULK_GRP.Line_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS
  l_header_id               NUMBER;
  l_line_id                 NUMBER;
  l_line_count              NUMBER;
  l_set_of_books_rec        oe_order_cache.Set_Of_Books_Rec_Type;
  l_set_of_books_id         NUMBER;
  l_currency_code           VARCHAR2(15);
  l_last_update_date        DATE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   x_return_status      := FND_API.G_RET_STS_SUCCESS;

   l_set_of_books_rec := OE_ORDER_CACHE.LOAD_SET_OF_BOOKS;
   l_set_of_books_id := l_set_of_books_rec.set_of_books_id;
   l_currency_code := l_set_of_books_rec.currency_code;

   IF (l_set_of_books_id IS NULL) OR (l_currency_code IS NULL) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SET OF BOOKS OR CURRENCY IS NULL' ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR I IN 1..p_line_rec.line_id.count LOOP

     IF p_line_rec.booked_flag(I) = 'Y' THEN

        INSERT INTO ONT_DBI_CHANGE_LOG
          ( HEADER_ID
           ,LINE_ID
           ,SET_OF_BOOKS_ID
           ,CURRENCY_CODE
           ,LAST_UPDATE_DATE
           )
        VALUES
          ( p_line_rec.header_id(I)
           ,p_line_rec.line_id(I)
           ,l_set_of_books_id
           ,l_currency_code
           ,sysdate
           );

      END IF;

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Update_DBI_log');
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_DBI_Log;


PROCEDURE Process_Headers
( p_batch_id                  IN NUMBER
, p_validate_only             IN VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex        IN VARCHAR2 DEFAULT 'Y'
, p_defaulting_mode           IN VARCHAR2 DEFAULT 'Y'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
)
IS
  l_start_time             NUMBER;
  l_end_time               NUMBER;
  l_header_scredit_rec     OE_BULK_ORDER_PVT.Scredit_Rec_Type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN


   ----------------------------------------------------------------
   -- Load Headers from interface table.
   ----------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Header_Util.Load_Headers
                (p_batch_id         => p_batch_id
                ,p_header_rec       => G_HEADER_REC);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Load_Headers is (sec) '||((l_end_time-l_start_time)/100));

   IF G_HEADER_REC.HEADER_ID.COUNT = 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO ORDERS IN THIS BATCH , EXIT!' ) ;
      END IF;
      RETURN;
   END IF;


   ----------------------------------------------------------------
   --  Process Headers
   ----------------------------------------------------------------
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Process_Header.Entity
                 (p_header_rec          => G_HEADER_REC
                 ,x_header_scredit_rec  => l_header_scredit_rec
                 ,p_defaulting_mode     => p_defaulting_mode
                 ,p_process_configurations  => p_process_configurations
                 ,p_validate_configurations => p_validate_configurations
                 ,p_schedule_configurations => p_schedule_configurations
                 ,p_validate_desc_flex  => p_validate_desc_flex
                 );

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;


   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Headers Entity validation is (sec) '||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- Insert Messages into DB from above processing call
   -------------------------------------------------------------------

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SAVING MESSAGES '||OE_BULK_MSG_PUB.G_MSG_TBL.MESSAGE.COUNT ) ;
   END IF;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Msg_PUB.Save_Messages(G_REQUEST_ID);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Save Messages is (sec) '||((l_end_time-l_start_time)/100));


   ------------------------------------------------------------
   -- Update Headers Interface table for invalid headers.
   ------------------------------------------------------------
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;
   Process_Invalid_Records;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Process_Invalid_Records is (sec) '||((l_end_time-l_start_time)/100));

   IF p_validate_only = 'Y' THEN
      RETURN;
   END IF;

   -------------------------------------------------------------------
   -- Create Header Sales Credits
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Header_Util.Create_Header_Scredits(l_header_scredit_rec);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Create Sales Credits is (sec) '
          ||((l_end_time-l_start_time)/100));

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Process_Headers'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Headers;

PROCEDURE Process_Lines
( p_batch_id                  IN  NUMBER
, p_validate_only             IN VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex        IN VARCHAR2 DEFAULT 'Y'
, p_defaulting_mode           IN VARCHAR2 DEFAULT 'Y'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
, p_process_tax               IN VARCHAR2 DEFAULT 'N'
)
IS
-- l_line_rec  LINE_REC_TYPE;
  l_start_time             NUMBER;
  l_end_time               NUMBER;
  l_line_scredit_rec       OE_BULK_ORDER_PVT.Scredit_Rec_Type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   --  Bulk Load Lines

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;
     oe_debug_pub.add(  'Process Tax :'|| p_process_tax,1);

   OE_Bulk_Line_Util.Load_Lines
                (p_batch_id         => p_batch_id
                 ,p_process_configurations => p_process_configurations
                ,p_line_rec         => G_LINE_REC);
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AFTER LOADING LINES THE COUNT IS'||G_LINE_REC.LINE_ID.COUNT ) ;

     -- Bug 5640601 =>
     -- Selecting hsecs from v$times is changed to execute only when debug
     -- is enabled, as hsec is used for logging only when debug is enabled.
     SELECT hsecs INTO l_end_time from v$timer;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Load_Lines is (sec) '||((l_end_time-l_start_time)/100));

   IF G_LINE_REC.LINE_ID.COUNT = 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO LINES IN THIS BATCH , EXIT!' ) ;
      END IF;
      RETURN;
   END IF;

   --  Pre-Process Lines
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;


   OE_Bulk_Process_Line.Entity
                 (p_line_rec            => G_LINE_REC
                 ,p_header_rec          => G_HEADER_REC
                 ,x_line_scredit_rec    => l_line_scredit_rec
                 ,p_defaulting_mode     => p_defaulting_mode
                 ,p_process_configurations  => p_process_configurations
                 ,p_validate_configurations => p_validate_configurations
                 ,p_schedule_configurations => p_schedule_configurations
                 ,p_validate_only           => p_validate_only
                 ,p_validate_desc_flex  => p_validate_desc_flex
                 ,p_process_tax         => p_process_tax
);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Entity Validation is (sec) '||((l_end_time-l_start_time)/100));


   --  Insert Messages
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SAVING MESSAGES '||OE_BULK_MSG_PUB.G_MSG_TBL.MESSAGE.COUNT ) ;
   END IF;
   OE_Bulk_Msg_PUB.Save_Messages(G_REQUEST_ID);

   --  Update Headers Interface for Invalid Lines
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   Process_Invalid_Records;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Process_Invalid Records for lines is (sec) '||((l_end_time-l_start_time)/100));

   -------------------------------------------------------------------
   -- Create Line Sales Credits
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Line_Util.Create_Line_Scredits(l_line_scredit_rec);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Create Line Sales Credits is (sec) '
          ||((l_end_time-l_start_time)/100));

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Process_Lines'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Lines;


PROCEDURE Post_Process
( p_batch_id                  IN NUMBER
, p_adjustments_exist         IN VARCHAR2 DEFAULT 'Y'
, p_process_tax               IN VARCHAR2 DEFAULT 'N'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
)
IS
  l_start_time             NUMBER;
  l_end_time               NUMBER;
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_adjustments_exist      VARCHAR2(1); --pibadj
  l_credit_check_method    VARCHAR2(3):='OLD';
  -- Added for HVOP Tax project
  l_tax_calculated BOOLEAN;
--
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   l_adjustments_exist := p_adjustments_exist; --pibadj

   IF G_HEADER_REC.HEADER_ID.COUNT = 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO ORDERS IN THIS BATCH , EXIT!' ) ;
          oe_debug_pub.add(  ' Process Tax :'|| p_process_tax, 1);
      END IF;
      RETURN;
   END IF;


   -------------------------------------------------------------------
   -- Create Entries in MTL_SALES_ORDERS
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   INV_SalesOrder.Create_MTL_Sales_Orders_Bulk
             (p_api_version_number     => 1.0
             ,p_header_rec             => G_HEADER_REC
             ,x_return_status          => l_return_status
             ,x_message_count          => l_msg_count
             ,x_message_data           => l_msg_data
             );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'ERROR IN CREATE_MTL_SALES_ORDERS_BULK :' ||L_RETURN_STATUS ) ;
                            END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;


   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in MTL_SALES_ORDERS creates is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- Auto-Scheduling
   -------------------------------------------------------------------

   IF G_SCH_COUNT > 0 THEN

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

      OE_Bulk_Schedule_Util.Schedule_Orders
                   (p_line_rec          => OE_BULK_ORDER_PVT.G_LINE_REC
                   ,p_header_rec        => OE_BULK_ORDER_PVT.G_HEADER_REC
                   ,x_return_status     => l_return_status
                   );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Scheduling is (sec) '
          ||((l_end_time-l_start_time)/100));

   END IF;

  -- added for HVOP TAX project
   --IF p_process_tax = 'Y' THEN bug7685103
      OE_Bulk_Tax_Util.Get_Default_Tax_Code;
   --END IF;


--PIB
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' Then
	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_start_time from v$timer;
	   end if;

      IF G_PRICING_NEEDED = 'Y' AND QP_UTIL_PUB.Hvop_Pricing_Setup = 'Y'
         AND NOT G_CATCHWEIGHT THEN --bug 3798477
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('before calling OE_BULK_PRICEORDER_PVT.Price_Orders');
         END IF;
         OE_BULK_PRICEORDER_PVT.Price_Orders
                  (p_header_rec      => OE_BULK_ORDER_PVT.G_HEADER_REC
                  ,p_line_rec        => OE_BULK_ORDER_PVT.G_LINE_REC
                  ,p_adjustments_exist => p_adjustments_exist  --pibadj
                  ,x_return_status   => l_return_status
                  );

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('after OE_BULK_PRICEORDER_PVT.Price_Orders : return status : '||l_return_status);
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          G_PRICING_NEEDED := 'N';
          l_adjustments_exist := 'N'; --pibadj
          --new credit check should be used since new bulkhvop pricing got activated
          l_credit_check_method := 'NEW';
      END IF;
	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_end_time from v$timer;
	   end if;


      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in HVOP Pricing is (sec) '
          ||((l_end_time-l_start_time)/100));

   END IF;
--PIB


-- added for HVOP TAX project
   IF p_process_tax = 'Y' AND
      G_PRICING_NEEDED = 'N' THEN
           select hsecs into l_start_time from v$timer;

      OE_Bulk_Tax_Util.Calculate_Tax(p_post_insert => FALSE);
            select hsecs into l_end_time from v$timer;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Tax  is (sec) '
          ||((l_end_time-l_start_time)/100));

      IF G_ERROR_COUNT < G_ERROR_REC.order_source_id.COUNT THEN
          Process_Invalid_Records;
      END IF;
      l_tax_calculated := TRUE;
   ELSE
      l_tax_calculated := FALSE;
   END IF;


   -------------------------------------------------------------------
   -- Insert header and line records into DB, should be done after
   -- scheduling as updates by scheduling are done directly on globals!
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Header_Util.Insert_Headers
                ( p_header_rec      => G_HEADER_REC
                 ,p_batch_id        => p_batch_id
                 );

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Insert_headers is (sec) '||((l_end_time-l_start_time)/100));

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Line_Util.Insert_Lines
                ( p_line_rec         => G_LINE_REC
                 );

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Insert_Lines is (sec) '||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- Create Holds
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_Holds_Pvt.Create_Holds;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Evaluating Holds is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- Update DBI log tables
   -------------------------------------------------------------------

   IF G_DBI_INSTALLED = 'Y' THEN

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_start_time from v$timer;
	   end if;

      Update_DBI_Log(p_line_rec         => G_LINE_REC
                    ,x_return_status    => l_return_status
                    );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_end_time from v$timer;
	   end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Update DBI Logs is (sec) '
            ||((l_end_time-l_start_time)/100));

   END IF;


   -------------------------------------------------------------------
   -- Deleting Error Records from Headers and Lines
   -------------------------------------------------------------------

   /* Moving it to post pricing */
   -- Delete_Error_Records(p_batch_id);


   -------------------------------------------------------------------
   -- Pricing Steps
   -- 1. Create Price Adjustments from Interface Tables
   -- 2. Price the Order
   -- Open Issue: What about scheduling/holds evaluation on free good lines?
   -------------------------------------------------------------------

   IF l_adjustments_exist = 'Y' THEN --pibadj

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_start_time from v$timer;
	   end if;

      OE_Bulk_Price_Pvt.Insert_Adjustments(p_batch_id, l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_end_time from v$timer;
	   end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Inserting Price Adjs is (sec) '
          ||((l_end_time-l_start_time)/100));

   END IF;

   IF G_PRICING_NEEDED = 'Y' OR (G_CC_REQUIRED = 'Y' and l_credit_check_method = 'OLD')
                             OR (p_process_tax = 'Y' and NOT l_tax_calculated)
   THEN

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_start_time from v$timer;
	   end if;

      OE_Bulk_Price_Pvt.Price_Orders
                  (p_header_rec        => G_HEADER_REC
                  ,x_return_status     => l_return_status
                  ,p_process_tax       => p_process_tax
                  );

      G_CATCHWEIGHT := FALSE;  --bug 3798477

      -- Added for bugfix 4180619
      IF G_ERROR_COUNT < G_ERROR_REC.order_source_id.COUNT THEN
          Process_Invalid_Records;
      END IF;
      -- End

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_end_time from v$timer;
	   end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Pricing is (sec) '
          ||((l_end_time-l_start_time)/100));

   ELSIF (G_CC_REQUIRED = 'Y' and l_credit_check_method = 'NEW') THEN  --bug 4558078
       OE_BULK_PRICEORDER_PVT.credit_check(OE_BULK_ORDER_PVT.G_HEADER_REC);
   END IF;
   --PIB }

   -------------------------------------------------------------------
   -- Deleting Error Records from Headers and Lines
   -------------------------------------------------------------------

   -- Moved here for bugfix 4180619
   Delete_Error_Records(p_batch_id,
                        p_adjustments_exist,
                        p_process_tax,
                        p_process_configurations);

   -------------------------------------------------------------------
   -- Process Acknowledgments
   -------------------------------------------------------------------

   IF G_ACK_NEEDED = 'Y' THEN

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_start_time from v$timer;
	   end if;

      OE_Bulk_Ack_Pvt.Process_Acknowledgments(p_batch_id, l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	   -- Bug 5640601 =>
	   -- Selecting hsecs from v$times is changed to execute only when debug
	   -- is enabled, as hsec is used for logging only when debug is enabled.
	   IF l_debug_level > 0 Then
	     SELECT hsecs INTO l_end_time from v$timer;
	   end if;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Acknowledgments is (sec) '
          ||((l_end_time-l_start_time)/100));

   END IF;


   -------------------------------------------------------------------
   -- Start Header and Line Workflows
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   OE_Bulk_WF_Util.Start_Flows(p_header_rec     => G_HEADER_REC
                              ,p_line_rec       => G_LINE_REC
                              ,x_return_status  => l_return_status
                              );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Starting Workflows is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- OM-WSH-HVOP bulk shipping call.
   -------------------------------------------------------------------


   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   IF G_LINE_REC.shipping_eligible_flag.COUNT > 0 THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('eligible lines exist,call WSH', 5);
      END IF;

      OE_Shipping_Integration_Pvt.OM_To_WSH_Interface
      ( p_line_rec      => G_LINE_REC
       ,p_header_rec    => G_HEADER_REC
       ,x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

   FND_FILE.PUT_LINE
   (FND_FILE.LOG,'Time spent in OM to WSH Interface is (sec) '
    ||((l_end_time-l_start_time)/100));


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Post_Process'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Post_Process;


---------------------------------------------------------------
-- PUBLIC PROCEDURES
---------------------------------------------------------------

PROCEDURE Process_Batch
( p_batch_id                 IN  NUMBER
, p_validate_only            IN  VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex       IN  VARCHAR2 DEFAULT 'Y'
, p_defaulting_mode          IN  VARCHAR2 DEFAULT 'N'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
, p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_process_tax              IN  VARCHAR2 DEFAULT 'N'
, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR

)
IS
  l_adjustments_exist          VARCHAR2(1);
  l_start_time                 NUMBER;
  l_end_time                   NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
   oe_debug_pub.add(  ' In Process Batch : p_process_configurations :'|| p_process_configurations );
   oe_debug_pub.add(  ' Process Tax  :'|| p_process_tax  ,1);
   -- Initialize Return Status

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize message list

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      OE_BULK_MSG_PUB.initialize;
   END IF;

   -- Establish SAVEPOINT

   SAVEPOINT Process_Batch;

   -- Initialize Global Error Record

   G_ERROR_REC.order_source_id := OE_WSH_BULK_GRP.T_NUM();
   G_ERROR_REC.orig_sys_document_ref := OE_WSH_BULK_GRP.T_V50();
   G_ERROR_REC.header_id := OE_WSH_BULK_GRP.T_NUM();
   G_ERROR_COUNT := 0;

   -- Populate parameter if adjustments exist for this batch

   BEGIN

     SELECT 'Y'
     INTO l_adjustments_exist
     FROM OE_PRICE_ADJS_INTERFACE a, OE_HEADERS_IFACE_ALL h
     WHERE h.batch_id = p_batch_id
      AND a.order_source_id = h.order_source_id
      AND a.orig_sys_document_ref = h.orig_sys_document_ref
      AND rownum = 1;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_adjustments_exist := 'N';
   END;

   -- Initialize Batch Global Parameters

   G_PRICING_NEEDED              := 'N';
   G_ACK_NEEDED                  := 'N';
   G_SCH_COUNT                   := 0;
   -- Initialize Credit Checking Globals
   G_REALTIME_CC_REQUIRED := 'N';
   G_CC_REQUIRED := 'N';

   -- Initialize Batch Global Records

   OE_Bulk_Holds_PVT.Initialize_Holds_Tbl;


   -------------------------------------------------------------------
   -- I. Pre-processing - includes:
   --    a. Order Import Pre-Processing Steps from OEXVIMSB.pls 115.51
   --    b. Validations to ensure that orders meet pre-req criteria
   --       for BULK processing
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;
   OE_BULK_VALIDATE.Pre_Process(p_batch_id);
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Pre_Process is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- II. Attribute Validations on the Interface Tables
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;
   OE_BULK_VALIDATE.Attributes(p_batch_id, l_adjustments_exist);
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Attribute Validation is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- III. Value to ID conversions
   -------------------------------------------------------------------

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

   --  Value to ID for Header Attributes

   OE_Bulk_Value_To_Id.Headers(p_batch_id);

   --  Value to ID for Line Attributes

   OE_Bulk_Value_To_Id.Lines(p_batch_id);

   --  Value to ID for Adjustment Attributes

   IF l_adjustments_exist = 'Y' THEN
      OE_Bulk_Value_To_Id.Adjustments(p_batch_id);
   END IF;

   --  Process Error Messages from Value to ID conversions

   OE_Bulk_Value_To_Id.INSERT_ERROR_MESSAGES(p_batch_id);

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Value To ID is (sec) '
          ||((l_end_time-l_start_time)/100));


   -------------------------------------------------------------------
   -- Mark Error Status on Interface Tables
   -------------------------------------------------------------------

   OE_BULK_VALIDATE.MARK_INTERFACE_ERROR(p_batch_id);
   Process_Invalid_Records;

  -------------------------------------------------------------------
   --    Pre_process Configurations
   -------------------------------------------------------------------


   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'p_process_configurations =  '|| p_process_configurations ) ;
   END IF;

   IF (p_process_configurations = 'Y') THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING OE_BULK_CONFIG_UTIL.Pre_Process ' ) ;
       END IF;

       SELECT hsecs INTO l_start_time from v$timer;

       OE_BULK_CONFIG_UTIL.Pre_Process
                (p_batch_id                     => p_batch_id,
                 p_validate_only                => p_validate_only,
                 p_use_configurator             => G_CONFIGURATOR_USED,
                 p_validate_configurations      => p_validate_configurations);

       SELECT hsecs INTO l_end_time from v$timer;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in CONFIG Pre_Process is (sec) '
          ||((l_end_time-l_start_time)/100));

   END IF;


   -------------------------------------------------------------------
   -- Mark Error Status on Interface Tables
   -------------------------------------------------------------------

   OE_BULK_VALIDATE.MARK_INTERFACE_ERROR(p_batch_id);


   Process_Invalid_Records;


   -------------------------------------------------------------------
   -- IV. Process Order Headers in this Batch
   -------------------------------------------------------------------

   Process_Headers(p_batch_id           => p_batch_id
                  ,p_validate_only      => p_validate_only
                  ,p_validate_desc_flex => p_validate_desc_flex
                  ,p_defaulting_mode    => p_defaulting_mode
                  ,p_process_configurations  => p_process_configurations
                  ,p_validate_configurations => p_validate_configurations
                  ,p_schedule_configurations => p_schedule_configurations);


   -------------------------------------------------------------------
   -- V. Process Order Lines in this Batch
   -------------------------------------------------------------------

   Process_Lines(p_batch_id           => p_batch_id
                ,p_validate_only      => p_validate_only
                ,p_validate_desc_flex => p_validate_desc_flex
                ,p_defaulting_mode    => p_defaulting_mode
                ,p_process_configurations  => p_process_configurations
                ,p_validate_configurations => p_validate_configurations
                ,p_schedule_configurations => p_schedule_configurations
                ,p_process_tax        => p_process_tax);



   -------------------------------------------------------------------
   -- If validation only mode, no further processing is needed.
   -------------------------------------------------------------------
   IF p_validate_only = 'Y' THEN
      RETURN;
   END IF;


   -------------------------------------------------------------------
   -- VII. Post-Processing: This includes all processing steps that
   --     need to be done after order header and line records are validated.
   --     Creation of Default Sales Credits/Entries in MTL_SALES_ORDERS
   --     Creation of Included Items
   --     Holds Evaluation
   --     Auto-Scheduling
   --     Creation of Price Adjustments, Pricing Engine Calls
   --     Starting Workflows
   -------------------------------------------------------------------

   Post_Process(p_batch_id           => p_batch_id
               ,p_adjustments_exist  => l_adjustments_exist
               ,p_process_tax        => p_process_tax
               ,p_process_configurations  => p_process_configurations
               ,p_validate_configurations => p_validate_configurations
               ,p_schedule_configurations => p_schedule_configurations);


   --  Get message count and data

   OE_BULK_MSG_PUB.Count_And_Get
   (   p_count                       => x_msg_count
   ,   p_data                        => x_msg_data
   );


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR IN PROCESS_BATCH' ) ;
    END IF;
    ROLLBACK TO SAVEPOINT Process_Batch;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    OE_BULK_MSG_PUB.Count_And_Get
      (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR IN PROCESS_BATCH' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SQL ERROR :'||SQLERRM ) ;
    END IF;
    ROLLBACK TO SAVEPOINT Process_Batch;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Process_Batch'
        );
    --  Get message count and data
    OE_BULK_MSG_PUB.Count_And_Get
      (   p_count                       => x_msg_count
       ,   p_data                        => x_msg_data
       );
END Process_Batch;

FUNCTION GET_FLEX_ENABLED_FLAG(p_flex_name VARCHAR2)
RETURN VARCHAR2
IS
l_count NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT count(*)
    INTO l_count
    FROM fnd_descr_flex_column_usages
    WHERE APPLICATION_ID = 660
    AND DESCRIPTIVE_FLEXFIELD_NAME = p_flex_name
    AND ENABLED_FLAG = 'Y'
    AND ROWNUM = 1;

    IF l_count = 1 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END GET_FLEX_ENABLED_FLAG;

PROCEDURE mark_header_error(p_header_index IN NUMBER,
               p_header_rec IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE)
IS
error_count NUMBER := OE_Bulk_Order_Pvt.G_ERROR_REC.header_id.COUNT;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ENTERING OE_BULK_ORDER_PVT.MARK_HEADER_ERROR' ) ;
  oe_debug_pub.add('The error count is '|| error_count);
END IF;

     error_count := error_count + 1;

     OE_Bulk_Order_Pvt.G_ERROR_REC.order_source_id.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.order_source_id(error_count)
                        := p_header_rec.order_source_id(p_header_index);

     OE_Bulk_Order_Pvt.G_ERROR_REC.orig_sys_document_ref.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.orig_sys_document_ref(error_count)
                        := p_header_rec.orig_sys_document_ref(p_header_index);

     OE_Bulk_Order_Pvt.G_ERROR_REC.header_id.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.header_id(error_count)
                        := p_header_rec.header_id(p_header_index);

IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'EXITING OE_BULK_ORDER_PVT.MARK_HEADER_ERROR' ) ;
END IF;

EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'in others exception ' || SQLERRM ) ;
  END IF;
  IF OE_BULK_MSG_PUB.check_msg_level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_BULK_MSG_PUB.add_exc_msg
    (G_PKG_NAME
    ,'Mark_Header_Error'
    );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Mark_Header_Error;


END OE_BULK_ORDER_PVT;

/
