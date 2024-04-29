--------------------------------------------------------
--  DDL for Package Body OE_VERSIONING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VERSIONING_UTIL" AS
/* $Header: OEXUVERB.pls 120.9.12010000.2 2008/12/04 07:08:03 cpati ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Versioning_Util';

G_VERSION_NUMBER		NUMBER;

-- Forward declaration to delete created records from history
FUNCTION Delete_Created_Records
RETURN VARCHAR2
IS
i           NUMBER;
TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_temp_table num_tbl;
l_return_status	VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

l_return_status	:= FND_API.G_RET_STS_SUCCESS;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering Delete_Created_Records ',1);
END IF;

-- Get created records

 i := oe_order_util.g_old_line_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE then
      l_temp_table(l_temp_table.count + 1) := oe_order_util.g_old_line_tbl(i).line_id;
   end if;
 i := oe_order_util.g_old_line_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 if l_temp_table.count > 0 then
     FORALL i in 1..l_temp_table.COUNT
        DELETE FROM OE_ORDER_LINES_HISTORY
        WHERE line_id = l_temp_table(i);
     l_temp_table.DELETE;
 end if;

 i := oe_order_util.g_old_header_adj_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_header_adj_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE then
      l_temp_table(l_temp_table.count + 1) := oe_order_util.g_old_header_adj_tbl(i).price_adjustment_id;
   end if;
 i := oe_order_util.g_old_header_adj_tbl.NEXT(i);
 END LOOP;

 i := oe_order_util.g_old_line_adj_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_adj_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE  then
      l_temp_table(l_temp_table.count + 1) := oe_order_util.g_old_line_adj_tbl(i).price_adjustment_id;
   end if;
 i := oe_order_util.g_old_line_adj_tbl.NEXT(i);
 END LOOP;

 if l_temp_table.count > 0 then
     FORALL i in 1..l_temp_table.COUNT
        DELETE FROM OE_PRICE_ADJS_HISTORY
        WHERE price_adjustment_id = l_temp_table(i);
     l_temp_table.DELETE;
 end if;

 i := oe_order_util.g_old_header_scredit_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_header_scredit_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE then
      l_temp_table(l_temp_table.count + 1) := oe_order_util.g_old_header_scredit_tbl(i).sales_credit_id;
   end if;
 i := oe_order_util.g_old_header_scredit_tbl.NEXT(i);
 END LOOP;

 i := oe_order_util.g_old_line_scredit_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_scredit_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE then
      l_temp_table(l_temp_table.count + 1) := oe_order_util.g_old_line_scredit_tbl(i).sales_credit_id;
   end if;
 i := oe_order_util.g_old_line_scredit_tbl.NEXT(i);
 END LOOP;

 if l_temp_table.count > 0 then
     FORALL i in 1..l_temp_table.COUNT
        DELETE FROM OE_SALES_CREDIT_HISTORY
        WHERE sales_credit_id = l_temp_table(i);
     l_temp_table.DELETE;
 end if;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exiting Delete_Created_Records ',1);
END IF;

 RETURN l_return_status;

EXCEPTION
 WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT Perform_Versioning;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Delete_Created_Records'
        );
    END IF;

    RETURN l_return_status;
END Delete_Created_Records;

Procedure Execute_Versioning_Request(
p_header_id IN NUMBER,
p_document_type IN VARCHAR2,
p_changed_attribute IN VARCHAR2 default null,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
)
IS
  l_return_status VARCHAR2(30);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Executing Versioning/Audit delayed request');
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF OE_GLOBALS.G_ROLL_VERSION <> 'N' THEN
      Perform_Versioning (p_header_id => p_header_id,
        p_document_type => p_document_type,
        p_changed_attribute => p_changed_attribute,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        x_return_status => l_return_status);

      --takintoy Version articles
      If l_return_status = FND_API.G_RET_STS_SUCCESS
         AND OE_Code_Control.Get_Code_Release_Level >= '110510'
      Then
          OE_Contracts_Util.Version_Articles(
       p_api_version   => 1,
       p_doc_type      => OE_Contracts_Util.G_SO_DOC_TYPE,
       p_doc_id        => p_header_id,
       -- p_version_number => OE_ORDER_UTIL.G_OLD_HEADER_REC.VERSION_NUMBER ,
       p_version_number => G_VERSION_NUMBER,
       x_return_status => l_return_status,
       x_msg_data      => x_msg_data,
       x_msg_count     => x_msg_count);
      End If;
  ELSE
      --Perform Audit Trail
      Record_Changed_Records(
        p_changed_attribute => p_changed_attribute,
        x_return_status => l_return_status);
      IF (NOT OE_Versioning_Util.Reset_Globals) THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('End Versioning/Audit Request '|| l_return_status);
  END IF;

  x_return_status := l_return_status;

END Execute_Versioning_Request;


Procedure Perform_Versioning (
p_header_id IN NUMBER,
p_document_type IN VARCHAR2,
p_changed_attribute IN VARCHAR2 := NULL,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2
)
IS

l_return_status VARCHAR2(30);
l_lock_control NUMBER;
l_version_number NUMBER;
l_entity_id      NUMBER;
l_reason_id      NUMBER;
l_version_flag VARCHAR2(1);
l_phase_change_flag VARCHAR2(1);
i NUMBER;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

SAVEPOINT Perform_Versioning;

l_return_status	:= FND_API.G_RET_STS_SUCCESS;
l_version_flag := 'N';
l_phase_change_flag := 'N';

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering Perform_Versioning ',1);
END IF;

IF (OE_GLOBALS.G_ROLL_VERSION = 'PV') THEN
     l_version_flag := 'Y';
     l_phase_change_flag := 'Y';
   IF (p_document_type <> 'BLANKETS') THEN
       IF OE_ORDER_UTIL.g_old_header_rec.version_number IS NULL
         OR OE_ORDER_UTIL.g_old_header_rec.version_number = FND_API.G_MISS_NUM THEN
            select version_number into l_version_number from oe_order_headers_all where header_id = p_header_id;
       ELSE
          l_version_number := OE_ORDER_UTIL.g_old_header_rec.version_number;
       END IF;
   END IF;
ELSIF (OE_GLOBALS.G_ROLL_VERSION = 'P') THEN
     l_version_flag := 'N';
     l_phase_change_flag := 'Y';
ELSE
     l_phase_change_flag := 'N';
     l_version_flag := 'Y';
   IF (p_document_type <> 'BLANKETS') THEN
       IF OE_ORDER_UTIL.g_old_header_rec.version_number IS NULL
         OR OE_ORDER_UTIL.g_old_header_rec.version_number = FND_API.G_MISS_NUM THEN
         select version_number into l_version_number from oe_order_headers_all where header_id = p_header_id;
       ELSE
          l_version_number := OE_ORDER_UTIL.g_old_header_rec.version_number;
       END IF;
   END IF;
END IF;


IF (p_document_type = 'BLANKETS') THEN

  OE_Blanket_Util.Record_Blanket_History(p_phase_change_flag => l_phase_change_flag, p_version_flag => l_version_flag, x_return_status => l_return_status);

  IF (l_version_flag = 'Y') THEN

    SELECT LOCK_CONTROL, VERSION_NUMBER
    INTO l_lock_control, l_version_number
    FROM OE_BLANKET_HEADERS_ALL
    WHERE HEADER_ID = p_header_id;

    IF l_version_number = OE_Blanket_Util.g_old_header_hist_rec.version_number THEN

     UPDATE OE_BLANKET_HEADERS_ALL
     SET VERSION_NUMBER = l_version_number + 1,
     LOCK_CONTROL = l_lock_control + 1
     WHERE HEADER_ID = p_header_id;

      OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
    ELSIF l_version_number < OE_Blanket_Util.g_old_header_hist_rec.version_number THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_REVISION_NUM');
          OE_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --Apply reason changes
  IF OE_GLOBALS.G_CAPTURED_REASON = 'Y' AND
     OE_GLOBALS.G_REASON_CODE <> FND_API.G_MISS_CHAR THEN
     OE_Reasons_Util.Apply_Reason(
         p_entity_code => 'BLANKET_HEADER',
         p_entity_id => p_header_id,
         p_header_id => p_header_id,
         p_version_number => OE_Blanket_Util.g_old_header_hist_rec.version_number,
         p_reason_type => 'CANCEL_CODE',
         p_reason_code => OE_GLOBALS.G_REASON_CODE,
         p_reason_comments => OE_GLOBALS.G_REASON_COMMENTS,
         x_reason_id => l_reason_id,
         x_return_status => l_return_status);

    UPDATE OE_BLANKET_HEADERS_HIST
    SET REASON_ID = l_reason_id
    WHERE phase_change_flag = l_phase_change_flag
    AND version_flag = l_version_flag
    AND version_number = OE_Blanket_Util.g_old_header_hist_rec.version_number --7312291;
    AND HEADER_ID = p_header_id;  --7312291

  ELSIF OE_GLOBALS.G_CAPTURED_REASON = 'V' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_AUDIT_REASON_RQD');
          OE_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Bug 5156668
-- This needs to be called only in the end, hence commenting
--  IF (NOT Reset_Globals) THEN
--    RAISE FND_API.G_EXC_ERROR;
--  END IF;

-- XDING: Commentting out this DOESNOT fix bug 5156668 but cause
-- regression issue 505564, so put this code back
  IF (NOT Reset_Globals) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  RETURN;
END IF;


-- Return if header is created in same operation
-- add g_header_created check to fix bug 3700341
IF OE_Order_Util.g_header_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
   OE_GLOBALS.G_HEADER_CREATED THEN
  IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Not versioning because header was also created',1);
  END IF;

  x_return_status := l_return_status;

-- Bug 5156668
-- This needs to be called only in the end, hence commenting
--  IF (NOT Reset_Globals) THEN
--    RAISE FND_API.G_EXC_ERROR;
--  END IF;

-- XDING: Commentting out this DOESNOT fix bug 5156668 but cause
-- regression issue 505564, so put this code back
  IF (NOT Reset_Globals) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  RETURN;
END IF;

-- Record changed records

Record_Changed_Records(p_version_flag => l_version_flag,
   p_phase_change_flag => l_phase_change_flag,
   p_changed_attribute => p_changed_attribute,
   x_return_status => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

-- Record unchanged records
IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling Create_Version_History ',1);
END IF;

OE_Version_History_Util.Create_Version_History(p_header_id => p_header_id,
                       p_version_number => l_version_number,
                       p_phase_change_flag => l_phase_change_flag,
                       p_changed_attribute => p_changed_attribute,
                       x_return_status => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

  l_return_status := Delete_Created_Records;

IF IS_REASON_RQD <> 'N' THEN
 IF OE_GLOBALS.G_REASON_CODE IS NULL OR
    OE_GLOBALS.G_REASON_CODE = FND_API.G_MISS_CHAR THEN
   -- Get stored reason in event of SYSTEM change
   Get_Reason_Info(x_reason_code => OE_GLOBALS.G_REASON_CODE,
                   x_reason_comments => OE_GLOBALS.G_REASON_COMMENTS);

   IF OE_GLOBALS.G_REASON_CODE IS NOT NULL OR
       OE_GLOBALS.G_REASON_CODE = FND_API.G_MISS_CHAR THEN
     OE_GLOBALS.G_CAPTURED_REASON := 'Y';
   END IF;
 END IF;
END IF;

--Apply reason changes
IF (IS_REASON_RQD = 'Y' AND
     OE_GLOBALS.G_REASON_CODE <> FND_API.G_MISS_CHAR) OR
    (IS_REASON_RQD <> 'N' AND
     OE_GLOBALS.G_DEFAULT_REASON) THEN

    IF OE_GLOBALS.G_DEFAULT_REASON THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Defaulting Versioning Reason if necessary');
       END IF;
       OE_GLOBALS.G_REASON_CODE := nvl(OE_GLOBALS.G_REASON_CODE, 'SYSTEM');
    END IF;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling Apply_Reason ' || OE_GLOBALS.G_REASON_CODE,1);
END IF;

   OE_Reasons_Util.Apply_Reason(
         p_entity_code => 'HEADER',
         p_entity_id => p_header_id,
         p_header_id => p_header_id,
         p_version_number => l_version_number,
         p_reason_type => nvl(OE_GLOBALS.G_REASON_TYPE, 'CANCEL_CODE'),
         p_reason_code => OE_GLOBALS.G_REASON_CODE,
         p_reason_comments => OE_GLOBALS.G_REASON_COMMENTS,
         x_reason_id => l_reason_id,
         x_return_status => l_return_status);

    UPDATE OE_ORDER_HEADER_HISTORY
    SET REASON_ID = l_reason_id
    WHERE HEADER_ID = p_header_id
    AND phase_change_flag = l_phase_change_flag
    AND version_flag = l_version_flag
    AND version_number = l_version_number;

ELSIF IS_REASON_RQD <> 'N' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_AUDIT_REASON_RQD');
          OE_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;

END IF;

--Update l_version_number
IF (l_version_flag = 'Y') THEN

  IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' Updating version number, lock control ',1);
  END IF;
    SELECT LOCK_CONTROL
    INTO l_lock_control
    FROM OE_ORDER_HEADERS_ALL
    WHERE HEADER_ID = p_header_id;

    IF OE_ORDER_UTIL.G_HEADER_REC.VERSION_NUMBER = OE_ORDER_UTIL.G_OLD_HEADER_REC.VERSION_NUMBER
       OR OE_ORDER_UTIL.G_HEADER_REC.VERSION_NUMBER IS NULL
       OR OE_ORDER_UTIL.G_HEADER_REC.VERSION_NUMBER = FND_API.G_MISS_NUM
       OR OE_ORDER_UTIL.G_OLD_HEADER_REC.VERSION_NUMBER IS NULL
       OR OE_ORDER_UTIL.G_OLD_HEADER_REC.VERSION_NUMBER = FND_API.G_MISS_NUM THEN
      UPDATE OE_ORDER_HEADERS_ALL
      SET VERSION_NUMBER = l_version_number + 1,
      LOCK_CONTROL = l_lock_control + 1
      WHERE HEADER_ID = p_header_id;

      /* update the order cache so that the header can be updated without requery
         after creating a new version from line, bug 4523686*/
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(' Updating oe_order_cache.g_header_rec with version number, lock control ',1);
       END IF;
      OE_ORDER_CACHE.g_header_rec.version_number := l_version_number + 1;
      OE_ORDER_CACHE.g_header_rec.lock_control := l_lock_control + 1;

      OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
    ELSIF OE_ORDER_UTIL.G_HEADER_REC.VERSION_NUMBER < OE_ORDER_UTIL.G_OLD_HEADER_REC.VERSION_NUMBER THEN
          FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_REVISION_NUM');
          OE_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
    END IF;
END IF;

G_VERSION_NUMBER := l_version_number;
--added for bug5216912 start
if G_VERSION_NUMBER is null then
   G_VERSION_NUMBER := OE_ORDER_UTIL.g_old_header_rec.version_number;
end if;
--added for bug5216912  end
-- added for 3679627
x_return_status := l_return_status;

-- Bug 5156668
-- This needs to be called only in the end, hence commenting
--IF (NOT Reset_Globals) THEN
--   RAISE FND_API.G_EXC_ERROR;
--END IF;

-- XDING: Commentting out this DOESNOT fix bug 5156668 but cause
-- regression issue 505564, so put this code back
  IF (NOT Reset_Globals) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVEPOINT Perform_Versioning;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
 WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT Perform_Versioning;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Perform_Versioning'
        );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Perform_Versioning;


FUNCTION Get_Header_ID
RETURN NUMBER
IS
i           NUMBER;
BEGIN

-- Get current header_id

if oe_order_util.g_header_id <> FND_API.G_MISS_NUM then
      RETURN oe_order_util.g_header_id;
elsif
 oe_order_util.g_old_header_rec.header_id <> FND_API.G_MISS_NUM then
      RETURN oe_order_util.g_old_header_rec.header_id;
elsif
 oe_order_util.g_header_rec.header_id <> FND_API.G_MISS_NUM then
      RETURN oe_order_util.g_header_rec.header_id;
else
 i := oe_order_util.g_old_line_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_old_line_tbl(i).header_id;
   end if;
 i := oe_order_util.g_old_line_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_line_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_line_tbl(i).header_id;
   end if;
 i := oe_order_util.g_line_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_old_header_adj_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_header_adj_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_old_header_adj_tbl(i).header_id;
   end if;
 i := oe_order_util.g_old_header_adj_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_header_adj_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_header_adj_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_header_adj_tbl(i).header_id;
   end if;
 i := oe_order_util.g_header_adj_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_old_line_adj_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_adj_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_old_line_adj_tbl(i).header_id;
   end if;
 i := oe_order_util.g_old_line_adj_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_line_adj_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_adj_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_line_adj_tbl(i).header_id;
   end if;
 i := oe_order_util.g_line_adj_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_old_header_scredit_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_header_scredit_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_old_header_scredit_tbl(i).header_id;
   end if;
 i := oe_order_util.g_old_header_scredit_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_header_scredit_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_header_scredit_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_header_scredit_tbl(i).header_id;
   end if;
 i := oe_order_util.g_header_scredit_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_old_line_scredit_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_old_line_scredit_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_old_line_scredit_tbl(i).header_id;
   end if;
 i := oe_order_util.g_old_line_scredit_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_line_scredit_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_scredit_tbl(i).header_id <> FND_API.G_MISS_NUM then
         RETURN oe_order_util.g_line_scredit_tbl(i).header_id;
   end if;
 i := oe_order_util.g_line_scredit_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

end if;

END Get_Header_Id;

--Procedure runs from delayed request. This procedure is called to handle
--changed records, handling both audit trail requests and changed records
--prior to recording unchanged records in the event of versioning/phase change

Procedure Record_Changed_Records(
p_version_flag IN VARCHAR2 := NULL,
p_phase_change_flag IN VARCHAR2 := NULL,
p_changed_attribute IN VARCHAR2 := NULL,
x_return_status OUT NOCOPY VARCHAR2)
IS
i NUMBER;
l_return_status VARCHAR2(1);
l_hist_type_code VARCHAR2(30);
l_audit_flag VARCHAR2(1);
l_header_id NUMBER;
l_version_number NUMBER;
l_reason_id NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

SAVEPOINT Record_Changed_Records;
l_return_status	:= FND_API.G_RET_STS_SUCCESS;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering OE_Versioning_util.record_changed_records ',1);
END IF;

l_header_id := Get_Header_ID;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_Versioning_Util header_id:  ' || l_header_id,1);
END IF;

IF OE_ORDER_UTIL.g_old_header_rec.version_number IS NULL
   OR OE_ORDER_UTIL.g_old_header_rec.version_number = FND_API.G_MISS_NUM THEN
      select version_number into l_version_number from oe_order_headers_all where header_id = l_header_id;
ELSE
    l_version_number := OE_ORDER_UTIL.g_old_header_rec.version_number;
END IF;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Before updating history ',1);
END IF;

--Update history with audit flag information gathered in global picture
IF OE_Order_Util.g_old_header_rec.header_id <> FND_API.G_MISS_NUM THEN
        IF NOT OE_GLOBALS.Equal(OE_Order_Util.g_old_header_rec.operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_header_hist_code IS NOT NULL) THEN

             IF g_audit_header_hist_code IS NOT NULL THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_header_hist_code;
             ELSE
                l_audit_flag := 'N';
             END IF;


          if g_audit_header_reason_required and l_audit_flag = 'Y' then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'HEADER',
                  p_entity_id => oe_order_util.g_old_header_rec.header_id,
                  p_header_id => oe_order_util.g_old_header_rec.header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CANCEL_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_header_rec.change_reason,
                  p_reason_comments => OE_ORDER_UTIL.g_header_rec.change_comments,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Header',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

          end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordheaderhist operation: '|| oe_order_util.g_old_header_rec.operation,1);
END IF;

          OE_CHG_ORDER_PVT.RecordHeaderHist
              ( p_header_id => oe_order_util.g_old_header_rec.header_id,
                p_header_rec => oe_order_util.g_old_header_rec,
                p_hist_type_code => l_hist_type_code,
                p_reason_code => NULL,
                p_comments => NULL,
                p_audit_flag => l_audit_flag,
                p_version_flag => p_version_flag,
                p_phase_change_flag => p_phase_change_flag,
                p_version_number => l_version_number,
                p_reason_id => l_reason_id,
                p_wf_activity_code => null,
                p_wf_result_code => null,
                p_changed_attribute => p_changed_attribute,
                x_return_status => l_return_status
              );

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Inserting Header History Caused Error ',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
          end if;

        END IF;
END IF;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: before recording lines ',1);
END IF;

--Update history for lines
i := oe_order_util.g_old_line_tbl.FIRST;  -- get subscript of first element
WHILE i IS NOT NULL LOOP
        IF NOT OE_GLOBALS.Equal(oe_order_util.g_old_line_tbl(i).operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_line_id_tbl.exists(i)) THEN
             IF g_audit_line_id_tbl.exists(i) THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_line_id_tbl(i).hist_type_code;
             ELSE
                l_audit_flag := 'N';
                l_hist_type_code := 'VERSIONING';
             END IF;

          if l_debug_level > 0 then
             oe_debug_pub.add('audit flag :'||l_audit_flag);
             oe_debug_pub.add('hist type code :'||l_hist_type_code);
          end if;

          if l_audit_flag = 'Y' and g_audit_line_id_tbl.exists(i) and
             (g_audit_line_id_tbl(i).reason_required
              -- Cancellation (hist type of CANCELLATION)
              -- Or qty decrease (hist type of QUANTITY UPDATE) can always send
              -- in a reason as cancel action window has a reason field. This
              -- value can be passed even if constraint does not require reason
              -- but if reason is supplied for these hist types, it should be
              -- captured.
              OR (l_hist_type_code IN ('CANCELLATION','QUANTITY UPDATE')
                  and OE_ORDER_UTIL.g_line_tbl(i).change_reason is not null
                  and OE_ORDER_UTIL.g_line_tbl(i).change_reason <> fnd_api.g_miss_char
                  )
              ) then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'LINE',
                  p_entity_id => oe_order_util.g_old_line_tbl(i).line_id,
                  p_header_id => oe_order_util.g_old_line_tbl(i).header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CANCEL_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_line_tbl(i).change_reason,
                  p_reason_comments => OE_ORDER_UTIL.g_line_tbl(i).change_comments,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Line',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

          end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordlinehist operation: '|| oe_order_util.g_old_line_tbl(i).operation,1);
END IF;

                OE_CHG_ORDER_PVT.RecordLineHist
                  (p_line_id => oe_order_util.g_old_line_tbl(i).line_id,
                   p_line_rec => oe_order_util.g_old_line_tbl(i),
                   p_hist_type_code => l_hist_type_code,
                   p_reason_code => NULL,
                   p_comments => NULL,
                   p_audit_flag => l_audit_flag,
                   p_version_flag => p_version_flag,
                   p_phase_change_flag => p_phase_change_flag,
                   p_version_number => l_version_number,
                   p_reason_id => l_reason_id,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);
             IF l_debug_level  > 0 THEN
                OE_DEBUG_PUB.add('IN OEXUVERB:After'||l_return_status,5);
             END IF;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Inserting Line Audit History error',1);
                   END IF;
                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

         END IF;
   i := oe_order_util.g_old_line_tbl.NEXT(i);  -- get subscript of next element
END LOOP;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: before recording header adjs ',1);
END IF;

--Update history for header adj
i := oe_order_util.g_old_header_adj_tbl.FIRST;  -- get subscript of first element
WHILE i IS NOT NULL LOOP
        IF NOT OE_GLOBALS.Equal(oe_order_util.g_old_header_adj_tbl(i).operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_header_adj_id_tbl.exists(i)) THEN
             IF g_audit_header_adj_id_tbl.exists(i) THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_header_adj_id_tbl(i).hist_type_code;
             ELSE
                l_audit_flag := 'N';
                l_hist_type_code := NULL;
             END IF;

            if l_audit_flag = 'Y' and g_audit_header_adj_id_tbl.exists(i) and
             g_audit_header_adj_id_tbl(i).reason_required then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'HEADER_ADJ',
                  p_entity_id => oe_order_util.g_old_header_adj_tbl(i).price_adjustment_id,
                  p_header_id => oe_order_util.g_old_header_adj_tbl(i).header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CHANGE_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_header_adj_tbl(i).change_reason_code,
                  p_reason_comments => OE_ORDER_UTIL.g_header_adj_tbl(i).change_reason_text,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Header Adj',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

            end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordHPAdjhist operation: '|| oe_order_util.g_old_header_adj_tbl(i).operation,1);
END IF;

                OE_CHG_ORDER_PVT.RecordHPAdjHist
                  (p_header_adj_id => oe_order_util.g_old_header_adj_tbl(i).price_adjustment_id,
                   p_header_adj_rec => oe_order_util.g_old_header_adj_tbl(i),
                   p_hist_type_code => l_hist_type_code,
                   p_reason_code => oe_globals.g_reason_code,
                   p_comments => oe_globals.g_reason_comments,
                   p_audit_flag => l_audit_flag,
                   p_version_flag => p_version_flag,
                   p_phase_change_flag => p_phase_change_flag,
                   p_version_number => l_version_number,
                   p_reason_id => l_reason_id,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);

                   IF l_debug_level  > 0 THEN
                      OE_DEBUG_PUB.add('IN OEXUVERB:After'||l_return_status,5);
                   END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Inserting Line Audit History error',1);
                   END IF;

                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

          END IF;
   i := oe_order_util.g_old_header_adj_tbl.NEXT(i);  -- get subscript of next element
END LOOP;


IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: before recording header scredits ',1);
END IF;

--Update history for header scredit
i := oe_order_util.g_old_header_scredit_tbl.FIRST;  -- get subscript of first element
WHILE i IS NOT NULL LOOP
        IF NOT OE_GLOBALS.Equal(oe_order_util.g_old_header_scredit_tbl(i).operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_header_scredit_id_tbl.exists(i)) THEN
             IF g_audit_header_scredit_id_tbl.exists(i) THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_header_scredit_id_tbl(i).hist_type_code;
             ELSE
                l_audit_flag := 'N';
                l_hist_type_code := NULL;
             END IF;

            if l_audit_flag = 'Y' and g_audit_header_scredit_id_tbl.exists(i) and
             g_audit_header_scredit_id_tbl(i).reason_required then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'HEADER_SCREDIT',
                  p_entity_id => oe_order_util.g_old_header_scredit_tbl(i).sales_credit_id,
                  p_header_id => oe_order_util.g_old_header_scredit_tbl(i).header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CANCEL_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_header_scredit_tbl(i).change_reason,
                  p_reason_comments => OE_ORDER_UTIL.g_header_scredit_tbl(i).change_comments,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Header Scredit',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

            end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordHSCredithist operation: '|| oe_order_util.g_old_header_scredit_tbl(i).operation,1);
END IF;

                OE_CHG_ORDER_PVT.RecordHSCreditHist
                  (p_header_scredit_id => oe_order_util.g_old_header_scredit_tbl(i).sales_credit_id,
                   p_header_scredit_rec => oe_order_util.g_old_header_scredit_tbl(i),
                   p_hist_type_code => l_hist_type_code,
                   p_reason_code => oe_globals.g_reason_code,
                   p_comments => oe_globals.g_reason_comments,
                   p_audit_flag => l_audit_flag,
                   p_version_flag => p_version_flag,
                   p_phase_change_flag => p_phase_change_flag,
                   p_version_number => l_version_number,
                   p_reason_id => l_reason_id,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);

                IF l_debug_level  > 0 THEN
                   OE_DEBUG_PUB.add('IN OEXUVERB:After'||l_return_status,5);
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Inserting Line Audit History error',1);
                   END IF;
                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

        END IF;
   i := oe_order_util.g_old_header_scredit_tbl.NEXT(i);  -- get subscript of next element
END LOOP;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: before recording line adjs ',1);
END IF;
--Update history for line adj
i := oe_order_util.g_old_line_adj_tbl.FIRST;  -- get subscript of first element
WHILE i IS NOT NULL LOOP
        IF NOT OE_GLOBALS.Equal(oe_order_util.g_old_line_adj_tbl(i).operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_line_adj_id_tbl.exists(i)) THEN
             IF g_audit_line_adj_id_tbl.exists(i) THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_line_adj_id_tbl(i).hist_type_code;
             ELSE
                l_audit_flag := 'N';
                l_hist_type_code := NULL;
             END IF;

            if l_audit_flag = 'Y' and g_audit_line_adj_id_tbl.exists(i) and
             g_audit_line_adj_id_tbl(i).reason_required then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'LINE_ADJ',
                  p_entity_id => oe_order_util.g_old_line_adj_tbl(i).price_adjustment_id,
                  p_header_id => oe_order_util.g_old_line_adj_tbl(i).header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CHANGE_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_line_adj_tbl(i).change_reason_code,
                  p_reason_comments => OE_ORDER_UTIL.g_line_adj_tbl(i).change_reason_text,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Line Adj',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

            end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordLPAdjhist operation: '|| oe_order_util.g_old_line_adj_tbl(i).operation,1);
END IF;

                OE_CHG_ORDER_PVT.RecordLPAdjHist
                  (p_line_adj_id => oe_order_util.g_old_line_adj_tbl(i).price_adjustment_id,
                   p_line_adj_rec => oe_order_util.g_old_line_adj_tbl(i),
                   p_hist_type_code => l_hist_type_code,
                   p_reason_code => oe_globals.g_reason_code,
                   p_comments => oe_globals.g_reason_comments,
                   p_audit_flag => l_audit_flag,
                   p_version_flag => p_version_flag,
                   p_phase_change_flag => p_phase_change_flag,
                   p_version_number => l_version_number,
                   p_reason_id => l_reason_id,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);

                   IF l_debug_level  > 0 THEN
                      OE_DEBUG_PUB.add('IN OEXUVERB:After'||l_return_status,5);
                   END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Inserting Line Audit History error',1);
                   END IF;

                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

        END IF;
i := oe_order_util.g_old_line_adj_tbl.NEXT(i);  -- get subscript of next element
END LOOP;

IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: before recording line scredits ',1);
END IF;
--Update history for line scredit
i := oe_order_util.g_old_line_scredit_tbl.FIRST;  -- get subscript of first element
WHILE i IS NOT NULL LOOP
        IF NOT OE_GLOBALS.Equal(oe_order_util.g_old_line_scredit_tbl(i).operation, OE_GLOBALS.G_OPR_CREATE) AND
            (p_version_flag = 'Y' OR p_phase_change_flag = 'Y' or
             g_audit_line_scredit_id_tbl.exists(i)) THEN
             IF g_audit_line_scredit_id_tbl.exists(i) THEN
                l_audit_flag := 'Y';
                l_hist_type_code := g_audit_line_scredit_id_tbl(i).hist_type_code;
             ELSE
                l_audit_flag := 'N';
                l_hist_type_code := NULL;
             END IF;

            if l_audit_flag = 'Y' and g_audit_line_scredit_id_tbl.exists(i) and
             g_audit_line_scredit_id_tbl(i).reason_required then
           --Apply Reason for audit
            OE_Reasons_Util.Apply_Reason(
                  p_entity_code => 'LINE_SCREDIT',
                  p_entity_id => oe_order_util.g_old_line_scredit_tbl(i).sales_credit_id,
                  p_header_id => oe_order_util.g_old_line_scredit_tbl(i).header_id,
                  p_version_number => l_version_number,
                  p_reason_type => 'CANCEL_CODE',
                  p_reason_code => OE_ORDER_UTIL.g_line_scredit_tbl(i).change_reason,
                  p_reason_comments => OE_ORDER_UTIL.g_line_scredit_tbl(i).change_comments,
                  x_reason_id => l_reason_id,
                  x_return_status => l_return_status);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('Applying Audit Reason Caused Error on Line Scredit',1);
             END IF;

             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
            end if;

            end if; --end apply reason

IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling recordLSCredithist operation: '|| oe_order_util.g_old_line_scredit_tbl(i).operation,1);
END IF;

                OE_CHG_ORDER_PVT.RecordLSCreditHist
                  (p_line_scredit_id => oe_order_util.g_old_line_scredit_tbl(i).sales_credit_id,
                   p_line_scredit_rec => oe_order_util.g_old_line_scredit_tbl(i),
                   p_hist_type_code => l_hist_type_code,
                   p_reason_code => oe_globals.g_reason_code,
                   p_comments => oe_globals.g_reason_comments,
                   p_audit_flag => l_audit_flag,
                   p_version_flag => p_version_flag,
                   p_phase_change_flag => p_phase_change_flag,
                   p_version_number => l_version_number,
                   p_reason_id => l_reason_id,
                   p_wf_activity_code => null,
                   p_wf_result_code => null,
                   x_return_status => l_return_status);

                IF l_debug_level  > 0 THEN
                   OE_DEBUG_PUB.add('IN OEXUVERB:After'||l_return_status,5);
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Inserting Line Audit History error',1);
                   END IF;
                   IF l_return_status = FND_API.G_RET_STS_ERROR then
                      raise FND_API.G_EXC_ERROR;
                   ELSE
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;

        END IF;
i := oe_order_util.g_old_line_scredit_tbl.NEXT(i);  -- get subscript of next element
END LOOP;

-- added for bug 4321689
x_return_status := l_return_status;

/*
IF (NOT Reset_Globals) THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;
*/
EXCEPTION
 WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT Record_Changed_Records;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Record Changed Records'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Record_Changed_Records;

Function Reset_Globals
RETURN BOOLEAN
IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   --Reset globals
IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: reset_globals ',1);
END IF;

   OE_GLOBALS.G_ROLL_VERSION := 'N';
   OE_GLOBALS.G_CAPTURED_REASON := 'N';
   OE_GLOBALS.G_REASON_CODE := NULL;
   OE_GLOBALS.G_REASON_COMMENTS := NULL;
   OE_GLOBALS.G_REASON_TYPE := NULL;
      G_Audit_Line_ID_Tbl.DELETE;
      G_Audit_Header_Adj_ID_Tbl.DELETE;
      G_Audit_Line_Adj_ID_Tbl.DELETE;
      G_Audit_Header_Scredit_ID_Tbl.DELETE;
      G_Audit_Line_Scredit_ID_Tbl.DELETE;

      G_AUDIT_HEADER_HIST_CODE := NULL;

   RETURN TRUE;
END Reset_Globals;

Procedure Check_Security(
p_column_name IN VARCHAR2,
p_on_operation_action IN NUMBER)
IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: check security ',1);
        oe_debug_pub.add(' OEXUVERB: gen_version action: '|| p_on_operation_action,1);
   END IF;

 -- added for bug 3518059
 -- add g_header_created check to fix bug 3700341
 if OE_Order_Util.g_header_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
    OE_GLOBALS.G_HEADER_CREATED OR
    OE_Blanket_Util.g_header_rec.operation = OE_GLOBALS.G_OPR_CREATE then
   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: header is created, do nothing',1);
   END IF;
 else
   IF p_column_name = 'TRANSACTION_PHASE_CODE' AND
      OE_QUOTE_UTIL.G_COMPLETE_NEG = 'Y' THEN
      --if transaction_phase is changing
      IF OE_GLOBALS.G_ROLL_VERSION = 'Y' THEN
         OE_GLOBALS.G_ROLL_VERSION := 'PV';
      ELSIF OE_GLOBALS.G_ROLL_VERSION = 'N' THEN
         OE_GLOBALS.G_ROLL_VERSION := 'P';
      END IF;
   END IF;

   IF p_on_operation_action IN (.1,.2) THEN
      IF OE_GLOBALS.G_ROLL_VERSION = 'P' THEN
         OE_GLOBALS.G_ROLL_VERSION := 'PV';
      ELSIF OE_GLOBALS.G_ROLL_VERSION = 'N' THEN
         OE_GLOBALS.G_ROLL_VERSION := 'Y';
      END IF;

      IF p_on_operation_action = .1 AND OE_GLOBALS.G_CAPTURED_REASON = 'N' THEN
         --Capture reason required for versioning
          OE_GLOBALS.G_CAPTURED_REASON := 'V';
      END IF;
   END IF;
 end if;
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' OEXUVERB: gen_version roll: '|| oe_globals.g_roll_version,1);
       END IF;

END Check_Security;


FUNCTION IS_REASON_RQD RETURN Varchar2 IS
BEGIN
     IF OE_GLOBALS.G_CAPTURED_REASON IN ('V') THEN
      RETURN OE_GLOBALS.G_CAPTURED_REASON;
     ELSIF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
      RETURN 'A';
     ELSE
	-- else condition added for bug 4144357
       IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.count > 0 THEN
          FOR l_ind in 1..OE_GLOBALS.oe_audit_history_tbl.last LOOP
              IF OE_GLOBALS.OE_AUDIT_HISTORY_TBL.exists(l_ind) AND
                 OE_GLOBALS.oe_audit_history_tbl(l_ind).HISTORY_TYPE = 'R' THEN
                 OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'Y';
                 RETURN 'A';
              END IF;
          END LOOP;
       END IF;
     END IF;

     IF OE_GLOBALS.G_CAPTURED_REASON IN ('N','Y') THEN
      RETURN OE_GLOBALS.G_CAPTURED_REASON;
     END IF;
END;

FUNCTION IS_AUDIT_REASON_CAPTURED
(p_entity_code IN VARCHAR2,
 p_entity_id IN NUMBER)
RETURN BOOLEAN
IS
l_ind NUMBER;
l_result VARCHAR2(1);
l_return_stat VARCHAR2(1);

BEGIN

G_UI_CALLED := TRUE;

IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
    IF OE_Order_Util.g_header_rec.change_reason <> FND_API.G_MISS_CHAR THEN
       g_temp_reason_code := OE_Order_Util.g_header_rec.change_reason;
       g_temp_reason_comments := OE_Order_Util.g_header_rec.change_comments;
       RETURN TRUE;
    END IF;
ELSE

 OE_Order_Util.Return_Glb_Ent_Index(
			p_entity_code,
			p_entity_id,
			l_ind,
			l_result,
			l_return_stat);

 IF l_result = FND_API.G_TRUE THEN
  IF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
    IF OE_Order_Util.g_line_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR THEN
         g_temp_reason_code := OE_Order_Util.g_line_tbl(l_ind).change_reason;
         g_temp_reason_comments := OE_Order_Util.g_line_tbl(l_ind).change_comments;
         RETURN TRUE;
    END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN
    IF OE_Order_Util.g_header_adj_tbl(l_ind).change_reason_code <> FND_API.G_MISS_CHAR THEN
         g_temp_reason_code := OE_Order_Util.g_header_adj_tbl(l_ind).change_reason_code;
         g_temp_reason_comments := OE_Order_Util.g_header_adj_tbl(l_ind).change_reason_text;
         RETURN TRUE;
    END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT THEN
    IF OE_Order_Util.g_header_scredit_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR THEN
         g_temp_reason_code := OE_Order_Util.g_header_scredit_tbl(l_ind).change_reason;
         g_temp_reason_comments := OE_Order_Util.g_header_scredit_tbl(l_ind).change_comments;
         RETURN TRUE;
    END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN
    IF OE_Order_Util.g_line_adj_tbl(l_ind).change_reason_code <> FND_API.G_MISS_CHAR THEN
         g_temp_reason_code := OE_Order_Util.g_line_adj_tbl(l_ind).change_reason_code;
         g_temp_reason_comments := OE_Order_Util.g_line_adj_tbl(l_ind).change_reason_text;
         RETURN TRUE;
    END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_SCREDIT THEN
    IF OE_Order_Util.g_line_scredit_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR THEN
         g_temp_reason_code := OE_Order_Util.g_line_scredit_tbl(l_ind).change_reason;
         g_temp_reason_comments := OE_Order_Util.g_line_scredit_tbl(l_ind).change_comments;
         RETURN TRUE;
    END IF;
  END IF;
 END IF;
END IF;

RETURN FALSE;

END;

FUNCTION CAPTURED_REASON RETURN Varchar2 IS
BEGIN
   RETURN OE_GLOBALS.G_REASON_CODE;
END CAPTURED_REASON;


Procedure Capture_Audit_Info(
p_entity_code IN VARCHAR2,
p_entity_id IN NUMBER,
p_hist_type_code IN VARCHAR2
)
IS
l_ind NUMBER;
l_result VARCHAR2(1);
l_return_stat VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  if l_debug_level > 0 then
  oe_debug_pub.add('capture audit info');
  oe_debug_pub.add('entity code :'||p_entity_code);
  oe_debug_pub.add('entity id :'||p_entity_id);
  oe_debug_pub.add('hist type :'||p_hist_type_code);
  end if;

  IF p_entity_code <> OE_GLOBALS.G_ENTITY_HEADER THEN
     OE_Order_Util.Return_Glb_Ent_Index(
			p_entity_code,
			p_entity_id,
			l_ind,
			l_result,
			l_return_stat);
  END IF;

  IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
           G_Audit_Header_Hist_Code := 'UPDATE';
       IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
           G_Audit_Header_Reason_Required := TRUE;
       END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
        IF NOT G_Audit_Line_ID_Tbl.exists(l_ind)
          OR G_Audit_Line_ID_Tbl(l_ind).hist_type_code NOT IN ('SPLIT', 'CANCELLATION') THEN
           G_Audit_Line_ID_Tbl(l_ind).entity_id := p_entity_id;
           G_Audit_Line_ID_Tbl(l_ind).hist_type_code := p_hist_type_code;
           IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
             G_Audit_Line_ID_Tbl(l_ind).Reason_Required := TRUE;
           END IF;
        END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN
        IF NOT G_Audit_Header_Adj_ID_Tbl.exists(l_ind)
          OR G_Audit_Header_Adj_ID_Tbl(l_ind).hist_type_code NOT IN ('SPLIT', 'CANCELLATION') THEN
           G_Audit_Header_Adj_ID_Tbl(l_ind).entity_id := p_entity_id;
           G_Audit_Header_Adj_ID_Tbl(l_ind).hist_type_code := p_hist_type_code;
           IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
             G_Audit_Header_Adj_ID_Tbl(l_ind).Reason_Required := TRUE;
           END IF;
        END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT THEN
        IF NOT G_Audit_Header_scredit_ID_Tbl.exists(l_ind)
          OR G_Audit_Header_scredit_ID_Tbl(l_ind).hist_type_code NOT IN ('SPLIT', 'CANCELLATION') THEN
           G_Audit_Header_scredit_ID_Tbl(l_ind).entity_id := p_entity_id;
           G_Audit_Header_scredit_ID_Tbl(l_ind).hist_type_code := p_hist_type_code;
           IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
             G_Audit_Header_Scredit_ID_Tbl(l_ind).Reason_Required := TRUE;
           END IF;
        END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN
        IF NOT G_Audit_Line_Adj_ID_Tbl.exists(l_ind)
          OR G_Audit_Line_Adj_ID_Tbl(l_ind).hist_type_code NOT IN ('SPLIT', 'CANCELLATION') THEN
           G_Audit_Line_Adj_ID_Tbl(l_ind).entity_id := p_entity_id;
           G_Audit_Line_Adj_ID_Tbl(l_ind).hist_type_code := p_hist_type_code;
           IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
             G_Audit_Line_Adj_ID_Tbl(l_ind).Reason_Required := TRUE;
           END IF;
        END IF;
  ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_SCREDIT THEN
        IF NOT G_Audit_Line_scredit_ID_Tbl.exists(l_ind)
          OR G_Audit_Line_scredit_ID_Tbl(l_ind).hist_type_code NOT IN ('SPLIT', 'CANCELLATION') THEN
           G_Audit_Line_scredit_ID_Tbl(l_ind).entity_id := p_entity_id;
           G_Audit_Line_scredit_ID_Tbl(l_ind).hist_type_code := p_hist_type_code;
           IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
             G_Audit_Line_Scredit_ID_Tbl(l_ind).Reason_Required := TRUE;
           END IF;
        END IF;
  END IF;

  OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
END Capture_Audit_Info;

Procedure Get_Reason_Info(
x_reason_code OUT NOCOPY VARCHAR2,
x_reason_comments OUT NOCOPY VARCHAR2
)
IS
i           NUMBER;
BEGIN

-- Get reason from temp values
if G_UI_CALLED THEN
   x_reason_code := G_TEMP_REASON_CODE;
   x_reason_comments := G_TEMP_REASON_COMMENTS;

   G_TEMP_REASON_CODE := NULL;
   G_TEMP_REASON_COMMENTS := NULL;

   G_UI_CALLED := FALSE;

   RETURN;
end if;

-- Get current change reason

if OE_GLOBALS.G_REASON_CODE IS NOT NULL THEN
   x_reason_code := OE_GLOBALS.G_REASON_CODE;
   x_reason_comments := OE_GLOBALS.G_REASON_COMMENTS;
end if;

if oe_order_util.g_header_rec.change_reason <> FND_API.G_MISS_CHAR then
      x_reason_code :=  oe_order_util.g_header_rec.change_reason;
      x_reason_comments :=  oe_order_util.g_header_rec.change_comments;
      RETURN;
else

 i := oe_order_util.g_header_adj_tbl.FIRST;  -- get subscript of first element
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_header_adj_tbl(i).change_reason_code <> FND_API.G_MISS_CHAR then
         x_reason_code := oe_order_util.g_header_adj_tbl(i).change_reason_code;
         x_reason_comments := oe_order_util.g_header_adj_tbl(i).change_reason_text;
         RETURN;
   end if;
 i := oe_order_util.g_header_adj_tbl.NEXT(i);  -- get subscript of next element
 END LOOP;

 i := oe_order_util.g_header_scredit_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_header_scredit_tbl(i).change_reason <> FND_API.G_MISS_CHAR then
         x_reason_code := oe_order_util.g_header_scredit_tbl(i).change_reason;
         x_reason_comments := oe_order_util.g_header_scredit_tbl(i).change_comments;
         RETURN;
   end if;
 i := oe_order_util.g_header_scredit_tbl.NEXT(i);
 END LOOP;

 i := oe_order_util.g_line_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_tbl(i).change_reason <> FND_API.G_MISS_CHAR then
         x_reason_code :=  oe_order_util.g_line_tbl(i).change_reason;
         x_reason_comments :=  oe_order_util.g_line_tbl(i).change_comments;
         RETURN;
   end if;
 i := oe_order_util.g_line_tbl.NEXT(i);
 END LOOP;

 i := oe_order_util.g_line_adj_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_adj_tbl(i).change_reason_code <> FND_API.G_MISS_CHAR then
         x_reason_code := oe_order_util.g_line_adj_tbl(i).change_reason_code;
         x_reason_comments := oe_order_util.g_line_adj_tbl(i).change_reason_text;
         RETURN;
   end if;
 i := oe_order_util.g_line_adj_tbl.NEXT(i);
 END LOOP;

 i := oe_order_util.g_line_scredit_tbl.FIRST;
 WHILE i IS NOT NULL LOOP
   if oe_order_util.g_line_scredit_tbl(i).change_reason <> FND_API.G_MISS_CHAR then
         x_reason_code := oe_order_util.g_line_scredit_tbl(i).change_reason;
         x_reason_comments := oe_order_util.g_line_scredit_tbl(i).change_comments;
         RETURN;
   end if;
 i := oe_order_util.g_line_scredit_tbl.NEXT(i);
 END LOOP;

end if;

END Get_Reason_Info;

-------------------------------
--  QUERY_ROW(S) Procedures have been moved to
--     OE_Version_History_Util (OEXHVERS/B.pls)
-------------------------------

END OE_Versioning_Util;

/
