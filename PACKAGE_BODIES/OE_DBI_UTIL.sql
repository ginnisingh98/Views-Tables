--------------------------------------------------------
--  DDL for Package Body OE_DBI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DBI_UTIL" As
/* $Header: OEXUDBIB.pls 120.3.12010000.3 2009/04/15 13:26:43 ckasera ship $ */


Procedure Update_DBI_Log
( x_return_status OUT NOCOPY VARCHAR2

) IS

l_header_id               NUMBER;
l_line_id                 NUMBER;
I                         BINARY_INTEGER;
j                         BINARY_INTEGER;
l_exists                  VARCHAR2(1) :='N';
l_set_of_books_rec        oe_order_cache.Set_Of_Books_Rec_Type;
l_set_of_books_id         NUMBER;
l_currency_code           VARCHAR2(15);
l_last_update_date        DATE;
l_last_update_date_old    DATE;
l_header_last_update_date DATE;

CURSOR get_lines(p_header_id number)
IS
select line_id, header_id, l_header_last_update_date, 'N'
from oe_order_lines_all
where header_id = p_header_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
TYPE line_index_tbl IS TABLE OF VARCHAR2(1)
  INDEX BY VARCHAR2(40);
l_line_index_tbl line_index_tbl;

TYPE T_NUM IS TABLE OF NUMBER;
TYPE T_DATE IS TABLE OF DATE;
TYPE T_V1 IS TABLE OF VARCHAR2(1);

TYPE DBI_REC IS RECORD
(
  header_id        T_NUM := T_NUM(),
  line_id          T_NUM := T_NUM(),
  last_update_date T_DATE := T_DATE(),
  rec_exists_flag  T_V1 := T_V1()
);

l_dbi_rec DBI_REC;
l_dbi_create_rec DBI_REC;

BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING UPDATE_DBI API' , 1 ) ;
   END IF;
   x_return_status      := FND_API.G_RET_STS_SUCCESS;

   l_set_of_books_rec := OE_ORDER_CACHE.LOAD_SET_OF_BOOKS;
   l_set_of_books_id := l_set_of_books_rec.set_of_books_id;
   l_currency_code := l_set_of_books_rec.currency_code;

   IF (l_set_of_books_id IS NULL) OR (l_currency_code IS NULL) THEN
        oe_debug_pub.add(  'SET_OF_BOOKS_ID= '|| L_SET_OF_BOOKS_ID , 1 ) ;
        oe_debug_pub.add(  'CURRENCY_CODE= '|| L_CURRENCY_CODE , 1 ) ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (oe_order_util.g_header_rec.header_id is NOT NULL AND
       oe_order_util.g_header_rec.header_id <> FND_API.G_MISS_NUM AND
       oe_order_util.g_line_tbl.COUNT = 0 AND
       oe_order_util.g_line_scredit_tbl.COUNT = 0 AND
       oe_order_util. g_line_adj_tbl.COUNT = 0)
   THEN

       /* Some field in the header is changed and no line level changes */
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SOMETHING IN THE HEADER CHANGED' ) ;
       END IF;
       l_header_id := oe_order_util.g_header_rec.header_id;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JPN: HEADER ID' || L_HEADER_ID ) ;
       END IF;
       l_header_last_update_date := oe_order_util.g_header_rec.last_update_date;

   ELSIF (oe_order_util.g_header_scredit_tbl.count > 0 AND
          oe_order_util.g_line_tbl.COUNT = 0 AND
          oe_order_util.g_line_scredit_tbl.COUNT = 0) THEN

       -- Some field in the header sales credit changed and no line level
       -- changes

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SOMETHING IN THE HEADER sales credit CHANGED' ) ;
       END IF;
       I := oe_order_util.g_old_header_scredit_tbl.FIRST;
       l_header_id := oe_order_util.g_old_header_scredit_tbl(I).header_id;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JPN: HEADER ID' || L_HEADER_ID ) ;
       END IF;

       IF  oe_order_util.g_header_scredit_tbl(I).last_update_date IS NULL THEN
           l_header_last_update_date :=
                   oe_order_util.g_old_header_scredit_tbl(I).last_update_date;
       ELSE
           l_header_last_update_date :=
                   oe_order_util.g_header_scredit_tbl(I).last_update_date;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LAST UPDATE DATE OLD=' || l_header_last_update_date ) ;
       END IF;

   ELSIF  (oe_order_util.g_header_adj_tbl.count > 0 ) THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SOMETHING IN THE HEADER ADJUSTMENTS CHANGED' ) ;
       END IF;
       I := oe_order_util.g_header_adj_tbl.FIRST;
       l_header_id := oe_order_util.g_header_adj_tbl(I).header_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JPN: HEADER ID' || L_HEADER_ID ) ;
       END IF;

       l_header_last_update_date := oe_order_util.g_header_adj_tbl(I).last_update_date;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LAST UPDATE DATE OLD=' || l_header_last_update_date ) ;
       END IF;

   END IF;

   IF l_header_id IS NOT NULL THEN

       BEGIN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'Opening  get_lines' ) ;
           END IF;
           OPEN get_lines(l_header_id);
           FETCH get_lines BULK COLLECT INTO
               l_dbi_rec.line_id,
               l_dbi_rec.header_id,
               l_dbi_rec.last_update_date,
               l_dbi_rec.rec_exists_flag;
           IF get_lines%ROWCOUNT = 0 THEN
               raise NO_DATA_FOUND;
           END IF;
           CLOSE get_lines;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'There are no lines in this order' ) ;
           END IF;
           -- Header has no lines.
           RETURN;
       END;
       GOTO HANDLE_DBI_REC;

   END IF;

   j := 1;

   -- Check if there are changed lines
   IF oe_order_util.g_line_tbl.COUNT > 0 THEN

        l_dbi_rec.line_id.EXTEND(oe_order_util.g_line_tbl.COUNT);
        l_dbi_rec.last_update_date.EXTEND(oe_order_util.g_line_tbl.COUNT);
        l_dbi_rec.rec_exists_flag.EXTEND(oe_order_util.g_line_tbl.COUNT);
        l_dbi_rec.header_id.EXTEND(oe_order_util.g_line_tbl.COUNT); ---bug 7319732,7347663
        I := oe_order_util.g_line_tbl.FIRST;
        l_header_id := oe_order_util.g_old_line_tbl(I).header_id;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN LINE HEADER_ID= '||L_HEADER_ID, 1 ) ;
        END IF;
        WHILE I IS NOT NULL LOOP
            IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOOP INDEX='|| I , 1 ) ;
            END IF;

            l_dbi_rec.line_id(j) :=oe_order_util.g_old_line_tbl(I).line_id;
            l_dbi_rec.rec_exists_flag(j) := 'N';
            l_dbi_rec.header_id(j) :=oe_order_util.g_old_line_tbl(I).Header_id ;--bug 7319732,7347663
            -- Set the value for line_index table to Y to indicate that record
            -- already captured in l_dbi_rec.line_id for the given line_id.
            l_line_index_tbl(l_dbi_rec.line_id(j)) := 'Y';

            IF oe_order_util.g_line_tbl(I).last_update_date IS NULL THEN
                l_dbi_rec.last_update_date(j) :=
                          oe_order_util.g_old_line_tbl(I).last_update_date;
            ELSE
                l_dbi_rec.last_update_date(j) :=
                          oe_order_util.g_line_tbl(I).last_update_date;
            END IF;

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE_ID= '||l_dbi_rec.line_id(j) ) ;
              oe_debug_pub.add(  'LAST UPDATE DATE=' || l_dbi_rec.last_update_date(j) ) ;
              oe_debug_pub.add(  'LINE TBL HEADER ID=' || L_HEADER_ID ) ;
              oe_debug_pub.add( 'LINE TBL HEADER ID=' ||l_dbi_rec.header_id(j)); --bug 7319732,7347663
            END IF;
            I := oe_order_util.g_line_tbl.NEXT(I);
            j := j + 1;
        END LOOP;
   END IF;

   IF l_dbi_rec.line_id.COUNT > 0 THEN
       j := l_dbi_rec.line_id.COUNT + 1;
   ELSE
       j := 1;
   END IF;

   IF oe_order_util.g_line_scredit_tbl.COUNT > 0 THEN

       I := oe_order_util.g_line_scredit_tbl.FIRST;
       l_header_id := oe_order_util.g_old_line_scredit_tbl(I).header_id;
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN LINE SC HEADER_ID= '|| l_header_id, 1 ) ;
       END IF;

       WHILE I IS NOT NULL LOOP
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOOP INDEX='|| I , 1 ) ;
          END IF;

          l_line_id :=oe_order_util.g_old_line_scredit_tbl(I).line_id;
          IF NOT l_line_index_tbl.EXISTS(to_char(l_line_id)) THEN

              l_dbi_rec.line_id.EXTEND;
              l_dbi_rec.last_update_date.EXTEND;
              l_dbi_rec.rec_exists_flag.EXTEND;
              l_dbi_rec.Header_id.EXTEND ; ---bug 7319732 ,7347663
              l_dbi_rec.Header_id(j) :=oe_order_util.g_old_line_scredit_tbl(I).header_id; --bug 7319732,7347663
              l_dbi_rec.line_id(j) := oe_order_util.g_old_line_scredit_tbl(I).line_id;
              l_dbi_rec.rec_exists_flag(j) := 'N';
              -- Set the value for line_index table to Y to indicate that record
              -- already captured in l_dbi_rec.line_id for the given line_id.
              l_line_index_tbl(l_dbi_rec.line_id(j)) := 'Y';

              IF oe_order_util.g_line_scredit_tbl(I).last_update_date IS NULL
              THEN
                  l_dbi_rec.last_update_date(j) :=
                       oe_order_util.g_old_line_scredit_tbl(I).last_update_date;
              ELSE
                  l_dbi_rec.last_update_date(j) :=
                       oe_order_util.g_line_scredit_tbl(I).last_update_date;

              END IF;
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE_ID= '||l_dbi_rec.line_id(j) ) ;
                oe_debug_pub.add(  'LAST UPDATE DATE=' || l_dbi_rec.last_update_date(J) ) ;
              END IF;
              j := j + 1;

          END IF;
          I := oe_order_util.g_line_scredit_tbl.NEXT(I);
       END LOOP;

   END IF;

   IF l_dbi_rec.line_id.COUNT > 0 THEN
       j := l_dbi_rec.line_id.COUNT + 1;
   ELSE
       j := 1;
   END IF;

   IF oe_order_util.g_line_adj_tbl.COUNT >0 THEN

       I := oe_order_util.g_line_adj_tbl.FIRST;
       l_header_id := oe_order_util.g_old_line_adj_tbl(I).header_id;

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN LINE PRICE ADJUSTMENTS HEADER_ID= '|| l_header_id, 1 ) ;
       END IF;

        WHILE I IS NOT NULL LOOP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PA  LOOP INDEX='|| I , 1 ) ;
          END IF;
          l_line_id :=oe_order_util.g_old_line_adj_tbl(I).line_id;

          IF NOT l_line_index_tbl.EXISTS(to_char(l_line_id)) THEN

              l_dbi_rec.line_id.EXTEND;
              l_dbi_rec.last_update_date.EXTEND;
              l_dbi_rec.rec_exists_flag.EXTEND;
              l_dbi_rec.Header_id.EXTEND ; ---bug 7319732 ,7347663
              l_dbi_rec.Header_id(j) :=oe_order_util.g_old_line_adj_tbl(I).header_id; --bug 7319732 ,7347663
              l_dbi_rec.line_id(j) := oe_order_util.g_old_line_adj_tbl(I).line_id;
              l_dbi_rec.rec_exists_flag(j) := 'N';
              -- Set the value for line_index table to Y to indicate that record
              -- already captured in l_dbi_rec.line_id for the given line_id.
              l_line_index_tbl(l_dbi_rec.line_id(j)) := 'Y';

              IF oe_order_util.g_line_adj_tbl(I).last_update_date IS NULL
              THEN
                  l_dbi_rec.last_update_date(J) :=
                       oe_order_util.g_old_line_adj_tbl(I).last_update_date;
              ELSE
                  l_dbi_rec.last_update_date(J) :=
                       oe_order_util.g_line_adj_tbl(I).last_update_date;

              END IF;
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE_ID= '||l_dbi_rec.line_id(j) ) ;
                oe_debug_pub.add(  'LAST UPDATE DATE=' || l_dbi_rec.last_update_date(J) ) ;
              END IF;
              j := j + 1;

          END IF;
          I := oe_order_util.g_line_adj_tbl.NEXT(I);

        END LOOP;

   END IF;

   <<HANDLE_DBI_REC>>

   j:= 0;

  IF (l_dbi_rec.line_id.count > 0 ) THEN -- Bug # 5022517

   FOR i IN l_dbi_rec.line_id.FIRST..l_dbi_rec.line_id.LAST LOOP

       BEGIN
           IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Trying to lock the ONT_DBI_CHANGE_LOG');
           END IF;

           -- Check if the record exists in ONT_DBI_CHANGE_LOG.
           -- If yes then first take a lock on that record.

           SELECT 'Y'
           INTO l_dbi_rec.rec_exists_flag(i)
           FROM ONT_DBI_CHANGE_LOG
           ---  WHERE header_id = l_header_id  bug 7319732 ,7347663
           WHERE header_id=l_dbi_rec.header_id(i) ---bug 7319732 ,7347663
           AND line_id = l_dbi_rec.line_id(i)
           AND set_of_books_id = l_set_of_books_id
           AND currency_code   = l_currency_code
           FOR UPDATE;

       EXCEPTION
              WHEN NO_DATA_FOUND THEN
               IF l_debug_level > 0 THEN
                 oe_debug_pub.add(' Record does not exist');
               END IF;
               null;
              WHEN TOO_MANY_ROWS THEN
               IF l_debug_level > 0 THEN
                 oe_debug_pub.add(' Multiple records exists');
               END IF;
               l_dbi_rec.rec_exists_flag(i) := 'Y';
       END;

       -- If record doesn't exists then mark it for CREATE
       IF l_dbi_rec.rec_exists_flag(i) = 'N' THEN
           j := j + 1;
           l_dbi_create_rec.header_id.EXTEND ; ---bug 7319732 ,7347663
           l_dbi_create_rec.line_id.EXTEND;
           l_dbi_create_rec.last_update_date.EXTEND;
           l_dbi_create_rec.line_id(j) := l_dbi_rec.line_id(i);
           l_dbi_create_rec.last_update_date(j) := l_dbi_rec.last_update_date(i);
           l_dbi_create_rec.header_id(j):=l_dbi_rec.header_id(i) ; ---bug 7319732,7347663
           IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Creating new record ' || j);
               oe_debug_pub.add(' Line_Id is ' || l_dbi_create_rec.line_id(j));
           END IF;
       END IF;

   END LOOP;

  END IF; --  Bug # 5022517

   IF l_dbi_create_rec.line_id.EXISTS(1) THEN
   -- Create records in ONT_DBI_CHANGE_LOG
     ---changed l_header_id to l_dbi_create_rec.header_id(j) --bug 7319732,7347663
      IF l_debug_level > 0 THEN
          oe_debug_pub.add('Inserting new records ' || l_dbi_create_rec.line_id.COUNT );
      END IF;
      FORALL i IN 1..l_dbi_create_rec.line_id.COUNT
          INSERT INTO  ONT_DBI_CHANGE_LOG
          (HEADER_ID
          ,LINE_ID
          ,SET_OF_BOOKS_ID
          ,CURRENCY_CODE
          ,LAST_UPDATE_DATE
          )
          VALUES
         (l_dbi_create_rec.header_id(i)
         ,l_dbi_create_rec.line_id(i)
         ,l_set_of_books_id
         ,l_currency_code
         ,l_dbi_create_rec.last_update_date(i)
         );
   END IF;
  --removed l_dbi_create_rec.header_id(j) in above update bug 7647650,7562662
   -- If all records are new then no need to execute UPDATE.
   IF j <> l_dbi_rec.line_id.COUNT THEN
      IF l_debug_level > 0 THEN
          oe_debug_pub.add('Updating existing records '|| l_dbi_rec.line_id.COUNT );
      END IF;

       FORALL i in 1..l_dbi_rec.line_id.COUNT
       UPDATE ONT_DBI_CHANGE_LOG
       SET LAST_UPDATE_DATE = SYSDATE
       --WHERE HEADER_ID       = l_header_id
       WHERE HEADER_ID = l_dbi_rec.header_id(i) --bug 7319732,7347663
       AND   LINE_ID         = l_dbi_rec.line_id(i)
       AND   SET_OF_BOOKS_ID = l_set_of_books_id
       AND   CURRENCY_CODE   = l_currency_code
       AND  l_dbi_rec.rec_exists_flag(i) = 'Y';

   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO DATA FOUND' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
   WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'In Others of Update_DBI_Log' , 1 ) ;
            oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
        END IF;
        IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Update_DBI_log');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_DBI_Log;

END OE_DBI_UTIL;

/
