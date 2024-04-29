--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ORDER_SEQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ORDER_SEQ_PVT" AS
/* $Header: OKLRSATB.pls 120.3 2006/07/18 11:36:32 dkagrawa noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
---------------------------------------------------------------------------
-- PROCEDURE  insert_row
---------------------------------------------------------------------------

PROCEDURE insert_row (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec        IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec        OUT NOCOPY okl_csh_order_rec_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;

    l_cshorder_sequence  OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cshorder_seqmax    OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cat_id             OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;
    l_countless          INTEGER;
    l_newrownum          INTEGER;
    l_count              INTEGER;
    currseq              INTEGER;
    l_countgreat         INTEGER;

    l_ins_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec okl_csh_order_rec_type  :=  p_okl_csh_order_rec;
    l_stav_rec          stav_rec_type;
    x_stav_rec          stav_rec_type;
    l_stav_tbl          stav_tbl_type;
    x_stav_tbl          stav_tbl_type;

 -------------------
-- DECLARE Cursors
-------------------
 -- Get the order with highest sequence less than the given seq
    CURSOR c_csh_ordr_seq (l_sequence_number IN NUMBER) IS
    SELECT max(sta.SEQUENCE_NUMBER) MAXSEQ
    FROM OKL_BPD_CSH_ORDER_UV sta
    WHERE sta.SEQUENCE_NUMBER <= l_sequence_number
------------------------------------------------------------------------------------
    AND   sta.ORG_ID = OKL_CONTEXT.get_okc_org_id   --dkagrawa changed for MOAC  -- multi org compliant
------------------------------------------------------------------------------------
    ORDER BY SEQUENCE_NUMBER;

 -- Get the count of total orders
    CURSOR c_csh_ordr_count IS
    SELECT count(*) COUNT
    FROM OKL_BPD_CSH_ORDER_UV sta
--------------------------------------------------------------------------------------
    WHERE   sta.ORG_ID = OKL_CONTEXT.get_okc_org_id;   --dkagrawa changed for MOAC -- multi org compliant
--------------------------------------------------------------------------------------


--  Get the count of orders with highest sequence less than the given seq
   CURSOR c_csh_ordr_countless (l_sequence_number IN NUMBER) IS
   SELECT count(*) COUNT
   FROM OKL_BPD_CSH_ORDER_UV sta
   WHERE sta.SEQUENCE_NUMBER <= l_sequence_number
--------------------------------------------------------------------------------------
   AND   sta.ORG_ID = OKL_CONTEXT.get_okc_org_id;   --dkagrawa changed for MOAC -- multi org compliant
--------------------------------------------------------------------------------------

-- Get the orders with sequence number greater than highest sequence
-- less than given seq
   CURSOR c_csh_ordr_seqgreat (l_sequence_number IN NUMBER,
                               l_cat_id IN NUMBER) IS
   SELECT SEQUENCE_NUMBER, ID
          ,STY_ID, CAT_ID, OBJECT_VERSION_NUMBER
          ,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
   FROM OKL_STRM_TYP_ALLOCS
   WHERE SEQUENCE_NUMBER > l_sequence_number
--------------------------------------------------------------------------------------
   AND CAT_ID = l_cat_id; -- multi org compliant
--------------------------------------------------------------------------------------

-- Get the count of orders with sequence number greater than highest sequence
-- less than given seq
   CURSOR c_csh_ordr_seqgreat_count (l_sequence_number IN NUMBER) IS
   SELECT count(*) COUNT
   FROM OKL_BPD_CSH_ORDER_UV sta
   WHERE SEQUENCE_NUMBER > l_sequence_number
--------------------------------------------------------------------------------------
   AND   sta.ORG_ID = OKL_CONTEXT.get_okc_org_id;   --dkagrawa changed for MOAC -- multi org compliant
--------------------------------------------------------------------------------------

   c_csh_ordr_seq_rec               c_csh_ordr_seq%ROWTYPE;
   c_csh_ordr_count_rec             c_csh_ordr_count%ROWTYPE;
   c_csh_ordr_countless_rec         c_csh_ordr_countless%ROWTYPE;
   c_csh_ordr_seqgreat_rec          c_csh_ordr_seqgreat%ROWTYPE;
   c_csh_ordr_seqgreat_count_rec    c_csh_ordr_seqgreat_count%ROWTYPE;

  BEGIN

--  Assign the values for columns in stav_rec from view record
    l_stav_rec.object_version_number :=  l_okl_csh_order_rec.object_version_number;
    l_stav_rec.sty_id                :=  l_okl_csh_order_rec.sty_id;
    l_stav_rec.cat_id                :=  l_okl_csh_order_rec.cat_id;
    l_stav_rec.sequence_number       :=  l_okl_csh_order_rec.sequence_number;
    l_stav_rec.stream_allc_type      :=  l_okl_csh_order_rec.stream_allc_type;
    l_stav_rec.created_by            :=  l_okl_csh_order_rec.created_by;
    l_stav_rec.creation_date         :=  l_okl_csh_order_rec.creation_date;
    l_stav_rec.last_updated_by       :=  l_okl_csh_order_rec.last_updated_by;
    l_stav_rec.last_update_date      :=  l_okl_csh_order_rec.last_update_date;
    l_stav_rec.last_update_login     :=  l_okl_csh_order_rec.last_update_login;


    l_cshorder_sequence              :=  l_stav_rec.SEQUENCE_NUMBER;

------------------------------------------------------------
    l_cat_id                         :=  l_stav_rec.CAT_ID;
------------------------------------------------------------

    --Get the rownum of the order with highest sequence
    OPEN c_csh_ordr_countless(l_cshorder_sequence);
    FETCH c_csh_ordr_countless INTO c_csh_ordr_countless_rec;

    l_countless := c_csh_ordr_countless_rec.COUNT;

    --Check if this is the first sequence to be inserted
    OPEN c_csh_ordr_count;
    FETCH c_csh_ordr_count INTO c_csh_ordr_count_rec;

    l_count :=  c_csh_ordr_count_rec.COUNT;

    IF (l_count > 0) THEN

        --Get the highest sequence less than the new sequence to be created
        OPEN c_csh_ordr_seq(l_cshorder_sequence);
        FETCH c_csh_ordr_seq INTO c_csh_ordr_seq_rec;

        l_cshorder_seqmax := c_csh_ordr_seq_rec.MAXSEQ;

    --  Assign the ordered sequence no to the new record to be inserted
        currseq :=  (l_countless + 1)*5;

    ELSE

    --This is the first sequence being inserted
        currseq :=  5;

    END IF;

    --Get the orders with sequence greater than the highest sequence

    l_newrownum   := l_countless + 2;
    i   := 1;

    OPEN c_csh_ordr_seqgreat_count(l_cshorder_sequence);
    FETCH c_csh_ordr_seqgreat_count INTO c_csh_ordr_seqgreat_count_rec;

    l_countgreat := c_csh_ordr_seqgreat_count_rec.COUNT;

    OPEN c_csh_ordr_seqgreat(l_cshorder_sequence, l_cat_id);
    LOOP
    FETCH c_csh_ordr_seqgreat INTO c_csh_ordr_seqgreat_rec;
    EXIT WHEN c_csh_ordr_seqgreat%NOTFOUND;

    l_stav_tbl(i).ID  := c_csh_ordr_seqgreat_rec.ID;
    l_stav_tbl(i).SEQUENCE_NUMBER := (l_newrownum*5);

    l_stav_tbl(i).STY_ID                    := c_csh_ordr_seqgreat_rec.STY_ID;
    l_stav_tbl(i).CAT_ID                    := c_csh_ordr_seqgreat_rec.CAT_ID;
    l_stav_tbl(i).OBJECT_VERSION_NUMBER     := c_csh_ordr_seqgreat_rec.OBJECT_VERSION_NUMBER;
    l_stav_tbl(i).CREATED_BY                := c_csh_ordr_seqgreat_rec.CREATED_BY;
    l_stav_tbl(i).CREATION_DATE             := c_csh_ordr_seqgreat_rec.CREATION_DATE;
    l_stav_tbl(i).LAST_UPDATED_BY           := c_csh_ordr_seqgreat_rec.LAST_UPDATED_BY;
    l_stav_tbl(i).LAST_UPDATE_DATE          := c_csh_ordr_seqgreat_rec.LAST_UPDATE_DATE;
    l_stav_tbl(i).LAST_UPDATE_LOGIN         := c_csh_ordr_seqgreat_rec.LAST_UPDATE_LOGIN;

    l_newrownum := l_newrownum + 1;
    i   := i + 1;

    END LOOP;

    IF (l_countgreat > 0) THEN


-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
        okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_stav_tbl
                                                        ,x_stav_tbl
                                                        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
    END IF;

    l_stav_rec.SEQUENCE_NUMBER := currseq;

--  Insert the new record
-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.insert_strm_typ_allocs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.insert_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.insert_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_rec
                                                    ,x_stav_rec
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.insert_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.insert_strm_typ_allocs

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
    RAISE l_ins_ext;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    RAISE l_ins_ext;
    END IF;

    EXCEPTION

    WHEN l_ins_ext THEN
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    l_msg_data := 'Problems with External Delete';
    x_msg_data := l_msg_data ;

    END insert_row;


---------------------------------------------------------------------------
-- PROCEDURE  insert_row(s)
---------------------------------------------------------------------------

PROCEDURE insert_row (p_api_version  IN NUMBER
       ,p_init_msg_list              IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status              OUT NOCOPY VARCHAR2
       ,x_msg_count                  OUT NOCOPY NUMBER
       ,x_msg_data                   OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl          IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl          OUT NOCOPY okl_csh_order_tbl_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1) ;
    l_overall_status     VARCHAR2(1) ;

    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;

    l_cshorder_sequence  OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cshorder_seqmax    OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cat_id             OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;
    l_countless          INTEGER;
    l_newrownum          INTEGER;
    l_count              INTEGER;
    currseq              INTEGER;
    l_countgreat         INTEGER;



    l_ins_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec okl_csh_order_rec_type;
    lp_okl_csh_order_tbl okl_csh_order_tbl_type := p_okl_csh_order_tbl;
    lx_okl_csh_order_tbl okl_csh_order_tbl_type := p_okl_csh_order_tbl;
    l_stav_rec          stav_rec_type;
    x_stav_rec          stav_rec_type;
    l_stav_tbl          stav_tbl_type;
    l1_stav_tbl          stav_tbl_type;
    x_stav_tbl          stav_tbl_type;
    x1_stav_tbl         stav_tbl_type;

 -------------------
-- DECLARE Cursors
-------------------

-- Get all the orders for update
   CURSOR c_csh_ordr_seq_all(l_cat_id IN NUMBER) IS
   SELECT SEQUENCE_NUMBER, ID
   FROM OKL_STRM_TYP_ALLOCS
   --FROM OKL_BPD_CSH_ORDER_UV
   WHERE STREAM_ALLC_TYPE = 'ODD'
------------------------------
   AND CAT_ID = l_cat_id
------------------------------
   order by SEQUENCE_NUMBER;

-- add cat_id

   c_csh_ordr_seq_all_rec           c_csh_ordr_seq_all%ROWTYPE;

BEGIN

 IF (lp_okl_csh_order_tbl.COUNT > 0) THEN
   i := lp_okl_csh_order_tbl.FIRST;
   LOOP

    l_okl_csh_order_rec := lp_okl_csh_order_tbl(i);

--  Assign the values for columns in stav_rec from view record
    l_stav_rec.sty_id                :=  l_okl_csh_order_rec.sty_id;
    l_stav_rec.cat_id                :=  l_okl_csh_order_rec.cat_id;
    l_stav_rec.sequence_number       :=  l_okl_csh_order_rec.sequence_number;
    l_stav_rec.stream_allc_type      :=  l_okl_csh_order_rec.stream_allc_type;
    l_stav_rec.created_by            :=  l_okl_csh_order_rec.created_by;
    l_stav_rec.creation_date         :=  l_okl_csh_order_rec.creation_date;
    l_stav_rec.last_updated_by       :=  l_okl_csh_order_rec.last_updated_by;
    l_stav_rec.last_update_date      :=  l_okl_csh_order_rec.last_update_date;
    l_stav_rec.last_update_login     :=  l_okl_csh_order_rec.last_update_login;

    l_stav_tbl(i) := l_stav_rec;

------------------------------------------------------------
    l_cat_id                         :=  l_stav_rec.CAT_ID;
------------------------------------------------------------


    EXIT WHEN (i = lp_okl_csh_order_tbl.LAST);
    i := lp_okl_csh_order_tbl.NEXT(i);

  END LOOP;

--  Insert the new record(s)
-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.insert_strm_typ_allocs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.insert_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.insert_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_tbl
                                                    ,x_stav_tbl
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.insert_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.insert_strm_typ_allocs

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    --update the sequence only if the sequence is ordered
    IF (lp_okl_csh_order_tbl(1).stream_allc_type = 'ODD') THEN

        l_newrownum :=  1;
        i   := 1;

        OPEN c_csh_ordr_seq_all(l_cat_id);
        LOOP
        FETCH c_csh_ordr_seq_all INTO c_csh_ordr_seq_all_rec;
        EXIT WHEN c_csh_ordr_seq_all%NOTFOUND;

            l1_stav_tbl(i).ID  := c_csh_ordr_seq_all_rec.ID;
            l1_stav_tbl(i).SEQUENCE_NUMBER := (l_newrownum*5);

            l_newrownum := l_newrownum + 1;
            i   := i + 1;

        END LOOP;

-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
        okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l1_stav_tbl
                                                        ,x_stav_tbl
                                                        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;

    END IF;

END IF;

IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
	RAISE l_ins_ext;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE l_ins_ext;
END IF;

EXCEPTION

    WHEN l_ins_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with External Delete';
        x_msg_data := l_msg_data ;

END insert_row;

---------------------------------------------------------------------------
-- PROCEDURE  update_row
---------------------------------------------------------------------------

PROCEDURE update_row (p_api_version  IN NUMBER
       ,p_init_msg_list         IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status         OUT NOCOPY VARCHAR2
       ,x_msg_count             OUT NOCOPY NUMBER
       ,x_msg_data              OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec     IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec     OUT NOCOPY okl_csh_order_rec_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;

    l_cshorder_id        OKL_STRM_TYP_ALLOCS.ID%TYPE;
    l_cshorder_sequence  OKL_STRM_TYP_ALLOCS.SEQUENCE_NUMBER%TYPE;
    l_cshorder_seqmax    OKL_STRM_TYP_ALLOCS.SEQUENCE_NUMBER%TYPE;
    l_cat_id             OKL_STRM_TYP_ALLOCS.CAT_ID%TYPE;
    l_countless          INTEGER;
    l_greatrownum        INTEGER;
    l_lessrownum         INTEGER;
    l_count              INTEGER;
    currseq              INTEGER;
    l_countgreat         INTEGER;

    l_upd_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec     okl_csh_order_rec_type   := p_okl_csh_order_rec;
    l_stav_rec              stav_rec_type;
    x_stav_rec              stav_rec_type;
    l_stav_tbl              stav_tbl_type;
    x_stav_tbl              stav_tbl_type;


 -------------------
-- DECLARE Cursors
-------------------
 -- Get the order with highest sequence less than the given seq
    CURSOR c_csh_ordr_seq (l_sequence_number IN NUMBER, l_id IN NUMBER, l_cat_id IN NUMBER) IS
    SELECT max(sta.SEQUENCE_NUMBER) MAXSEQ
    FROM OKL_STRM_TYP_ALLOCS sta
    WHERE sta.SEQUENCE_NUMBER <= l_sequence_number
    AND  ID <> l_id
---------------------------------------------------------------------------
    AND CAT_ID = l_cat_id -- multi org compliant
---------------------------------------------------------------------------
    ORDER BY SEQUENCE_NUMBER;

-- add cat_id

 -- Get the count of total orders
    CURSOR c_csh_ordr_count (l_cat_id IN NUMBER)IS
    SELECT count(*) COUNT
    FROM OKL_STRM_TYP_ALLOCS
---------------------------------------------------------------------------
    WHERE CAT_ID = l_cat_id; -- multi org compliant
---------------------------------------------------------------------------

--  Get the corders with highest sequence less than the given seq
   CURSOR c_csh_ordr_seqless (l_sequence_number IN NUMBER, l_id IN NUMBER, l_cat_id IN NUMBER) IS
   SELECT SEQUENCE_NUMBER, ID
   FROM OKL_STRM_TYP_ALLOCS
   WHERE SEQUENCE_NUMBER <= l_sequence_number
   AND  ID <> l_id
---------------------------------------------------------------------------
   AND CAT_ID = l_cat_id -- multi org compliant
---------------------------------------------------------------------------
   ORDER BY SEQUENCE_NUMBER;

--  Get the count of orders with highest sequence less than the given seq
   CURSOR c_csh_ordr_countless (l_sequence_number IN NUMBER, l_id IN NUMBER, l_cat_id IN NUMBER) IS
   SELECT count(*) COUNT
   FROM OKL_STRM_TYP_ALLOCS sta
   WHERE sta.SEQUENCE_NUMBER <= l_sequence_number
   AND  ID <> l_id
---------------------------------------------------------------------------
   AND CAT_ID = l_cat_id; -- multi org compliant
---------------------------------------------------------------------------

-- Get the orders with sequence number greater than highest sequence
-- less than given seq
   CURSOR c_csh_ordr_seqgreat (l_sequence_number IN NUMBER, l_id IN NUMBER, l_cat_id IN NUMBER) IS
   SELECT SEQUENCE_NUMBER, ID
   FROM OKL_STRM_TYP_ALLOCS
   WHERE SEQUENCE_NUMBER > l_sequence_number
   AND  ID <> l_id
---------------------------------------------------------------------------
   AND CAT_ID = l_cat_id; -- multi org compliant
---------------------------------------------------------------------------

-- Get the count of orders with sequence number greater than highest sequence
-- less than given seq
   CURSOR c_csh_ordr_seqgreat_count (l_sequence_number IN NUMBER, l_id IN NUMBER, l_cat_id IN NUMBER) IS
   SELECT count(*) COUNT
   FROM OKL_STRM_TYP_ALLOCS
   WHERE SEQUENCE_NUMBER > l_sequence_number
   AND  ID <> l_id
---------------------------------------------------------------------------
   AND CAT_ID = l_cat_id; -- multi org compliant
---------------------------------------------------------------------------

   c_csh_ordr_seq_rec               c_csh_ordr_seq%ROWTYPE;
   c_csh_ordr_count_rec             c_csh_ordr_count%ROWTYPE;
   c_csh_ordr_seqless_rec           c_csh_ordr_seqless%ROWTYPE;
   c_csh_ordr_countless_rec         c_csh_ordr_countless%ROWTYPE;
   c_csh_ordr_seqgreat_rec          c_csh_ordr_seqgreat%ROWTYPE;
   c_csh_ordr_seqgreat_count_rec    c_csh_ordr_seqgreat_count%ROWTYPE;

  BEGIN

--  Assign the values for columns of stav_rec from view record
    l_stav_rec.ID               :=  l_okl_csh_order_rec.ID;
    l_stav_rec.SEQUENCE_NUMBER  :=  l_okl_csh_order_rec.SEQUENCE_NUMBER;
    l_stav_rec.CAT_ID           :=  l_okl_csh_order_rec.CAT_ID;

    l_cshorder_sequence         :=  l_stav_rec.SEQUENCE_NUMBER;
    l_cshorder_id               :=  l_stav_rec.ID;
    l_cat_id                    :=  l_stav_rec.CAT_ID;

    --Get the orders with sequence less than the current sequence
    OPEN c_csh_ordr_countless(l_cshorder_sequence,l_cshorder_id, l_cat_id);
    FETCH c_csh_ordr_countless INTO c_csh_ordr_countless_rec;

    l_countless := c_csh_ordr_countless_rec.COUNT;

    l_lessrownum   := 1;
    i   :=  1;

    OPEN c_csh_ordr_seqless(l_cshorder_sequence,l_cshorder_id, l_cat_id);
    LOOP
    FETCH c_csh_ordr_seqless INTO c_csh_ordr_seqless_rec;
    EXIT WHEN c_csh_ordr_seqless%NOTFOUND;

    l_stav_tbl(i).ID  := c_csh_ordr_seqless_rec.ID;
    l_stav_tbl(i).SEQUENCE_NUMBER := (l_lessrownum*5);

    l_lessrownum := l_lessrownum + 1;
    i := i + 1;

    END LOOP;

    IF (l_countless > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_tbl
                                                    ,x_stav_tbl
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

    END IF;


  --Get the highest sequence less than the new sequence to be created
    OPEN c_csh_ordr_seq(l_cshorder_sequence,l_cshorder_id, l_cat_id);
    FETCH c_csh_ordr_seq INTO c_csh_ordr_seq_rec;

    l_cshorder_seqmax := c_csh_ordr_seq_rec.MAXSEQ;

--  Assign the ordered sequence no to the new record to be inserted
    currseq :=  (l_countless + 1)*5;

    --Get the orders with sequence greater than the highest sequence

    l_greatrownum   := l_countless + 2;
    i   := 1;

    OPEN c_csh_ordr_seqgreat_count(l_cshorder_sequence,l_cshorder_id, l_cat_id);
    FETCH c_csh_ordr_seqgreat_count INTO c_csh_ordr_seqgreat_count_rec;

    l_countgreat := c_csh_ordr_seqgreat_count_rec.COUNT;

    OPEN c_csh_ordr_seqgreat(l_cshorder_sequence,l_cshorder_id, l_cat_id);
    LOOP
    FETCH c_csh_ordr_seqgreat INTO c_csh_ordr_seqgreat_rec;
    EXIT WHEN c_csh_ordr_seqgreat%NOTFOUND;

    l_stav_tbl(i).ID  := c_csh_ordr_seqgreat_rec.ID;
    l_stav_tbl(i).SEQUENCE_NUMBER := (l_greatrownum*5);

    l_greatrownum := l_greatrownum + 1;
    i   := i + 1;

    END LOOP;

    IF (l_countgreat > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_tbl
                                                    ,x_stav_tbl
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

    END IF;

    l_stav_rec.SEQUENCE_NUMBER :=   currseq;
    l_stav_rec.ID   :=  l_cshorder_id;

--  Update the current record
-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_rec
                                                    ,x_stav_rec
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE l_upd_ext;
  ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE l_upd_ext;
  END IF;

  EXCEPTION

    WHEN l_upd_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with External Insert';
        x_msg_data := l_msg_data ;

  END update_row;


---------------------------------------------------------------------------
-- PROCEDURE  update_row(s)
---------------------------------------------------------------------------

  PROCEDURE update_row (p_api_version  IN NUMBER
       ,p_init_msg_list              IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status              OUT NOCOPY VARCHAR2
       ,x_msg_count                  OUT NOCOPY NUMBER
       ,x_msg_data                   OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl          IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl          OUT NOCOPY okl_csh_order_tbl_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_overall_status     VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;

    l_cshorder_sequence  OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cshorder_seqmax    OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cat_id             OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;
    l_countless          INTEGER;
    l_newrownum          INTEGER;
    l_count              INTEGER;
    currseq              INTEGER;
    l_countgreat         INTEGER;

    l_upd_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec okl_csh_order_rec_type;
    lp_okl_csh_order_tbl okl_csh_order_tbl_type := p_okl_csh_order_tbl;
    lx_okl_csh_order_tbl okl_csh_order_tbl_type := p_okl_csh_order_tbl;
    l_stav_rec          stav_rec_type;
    x_stav_rec          stav_rec_type;
    l_stav_tbl          stav_tbl_type;
    x_stav_tbl          stav_tbl_type;

 -------------------
-- DECLARE Cursors
-------------------

--Get all the orders
  CURSOR   c_csh_ordr_all (l_cat_id IN NUMBER) IS
  SELECT   SEQUENCE_NUMBER, ID
  FROM     OKL_STRM_TYP_ALLOCS
  WHERE    CAT_ID = l_cat_id
  ORDER BY SEQUENCE_NUMBER;

  c_csh_ordr_all_rec               c_csh_ordr_all%ROWTYPE;

  BEGIN

   IF (lp_okl_csh_order_tbl.COUNT > 0) THEN
     i := lp_okl_csh_order_tbl.FIRST;
     LOOP

        l_okl_csh_order_rec := lp_okl_csh_order_tbl(i);

    --  Assign the values for columns of stav_rec from view record
        l_stav_rec.ID   :=      l_okl_csh_order_rec.ID;
        l_stav_rec.SEQUENCE_NUMBER  :=  l_okl_csh_order_rec.SEQUENCE_NUMBER;
        l_cat_id := l_okl_csh_order_rec.cat_id;
        l_stav_tbl(i) := l_stav_rec;

        EXIT WHEN (i = lp_okl_csh_order_tbl.LAST);
        i := lp_okl_csh_order_tbl.NEXT(i);

  END LOOP;

--  Update the current table
-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_tbl
                                                    ,x_stav_tbl
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    l_newrownum := 1;
    i   := 1;

    OPEN c_csh_ordr_all(l_cat_id);
    LOOP
    FETCH c_csh_ordr_all INTO c_csh_ordr_all_rec;
    EXIT WHEN c_csh_ordr_all%NOTFOUND;

    l_stav_tbl(i).ID  := c_csh_ordr_all_rec.ID;
    l_stav_tbl(i).SEQUENCE_NUMBER := (l_newrownum*5);

    l_newrownum := l_newrownum + 1;
    i   := i + 1;

    END LOOP;

-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
    okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_tbl
                                                    ,x_stav_tbl
                                                    );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

END IF;

IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
    RAISE l_upd_ext;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE l_upd_ext;
  END IF;

  EXCEPTION
    WHEN l_upd_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with External Delete';
        x_msg_data := l_msg_data ;

  END update_row;

---------------------------------------------------------------------------
-- PROCEDURE  delete_row
---------------------------------------------------------------------------

  PROCEDURE delete_row (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec        IN okl_csh_order_rec_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_cat_id             OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;

    i                    NUMBER;
    l_rownum             INTEGER    :=1;
    l_count              INTEGER;

    l_del_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec okl_csh_order_rec_type  :=  p_okl_csh_order_rec;
    l_stav_rec          stav_rec_type;
    l_stav_tbl          stav_tbl_type;
    x_stav_tbl          stav_tbl_type;
 -------------------
-- DECLARE Cursors
-------------------

-- Get all the orders in the table
   CURSOR c_csh_ordr_seq (l_cat_id IN NUMBER) IS
   SELECT ID, SEQUENCE_NUMBER
   FROM OKL_STRM_TYP_ALLOCS
   WHERE STREAM_ALLC_TYPE = 'ODD'
   AND CAT_ID = l_cat_id
   ORDER BY SEQUENCE_NUMBER;

--Check if the record exists
  CURSOR c_csh_ordr_exists(l_csh_ordr_id NUMBER, l_cat_id IN NUMBER) IS
  SELECT count(*) COUNT
  FROM OKL_STRM_TYP_ALLOCS
  WHERE ID = l_csh_ordr_id
  AND CAT_ID = l_cat_id;

   c_csh_ordr_seq_rec               c_csh_ordr_seq%ROWTYPE;
   c_csh_ordr_exists_rec            c_csh_ordr_exists%ROWTYPE;

    BEGIN

    --dbms_output.put_line('At the begin of delete_row in pvt');

    --Assign the values for columns of stav_rec from view record
    l_stav_rec.ID   :=      l_okl_csh_order_rec.ID;
    l_cat_id        :=      l_okl_csh_order_rec.CAT_ID;

    --Check if the record with this id exists
    OPEN c_csh_ordr_exists(l_stav_rec.ID, l_cat_id);
    FETCH c_csh_ordr_exists INTO c_csh_ordr_exists_rec;
    CLOSE c_csh_ordr_exists;

    --dbms_output.put_line('the count of rows in  delete_row in pvt ' ||
    --c_csh_ordr_exists_rec.COUNT);

    IF (c_csh_ordr_exists_rec.COUNT > 0) THEN

        okl_strm_typ_allocs_pub.delete_strm_typ_allocs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_stav_rec
                                                    );

        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;

    END IF;

    IF (l_okl_csh_order_rec.STREAM_ALLC_TYPE = 'ODD') THEN

        i   := 1;
        OPEN c_csh_ordr_seq(l_cat_id);
        LOOP
        FETCH c_csh_ordr_seq INTO c_csh_ordr_seq_rec;
        EXIT WHEN c_csh_ordr_seq%NOTFOUND;

        l_stav_tbl(i).ID  := c_csh_ordr_seq_rec.ID;
        l_stav_tbl(i).SEQUENCE_NUMBER := (l_rownum*5);

        l_rownum := l_rownum + 1;
        i   := i + 1;

        END LOOP;

-- Start of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
        okl_strm_typ_allocs_pub.update_strm_typ_allocs(l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_stav_tbl
                                                        ,x_stav_tbl
                                                        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSATB.pls call okl_strm_typ_allocs_pub.update_strm_typ_allocs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_strm_typ_allocs_pub.update_strm_typ_allocs

        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;

    END IF;

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE l_del_ext;
  ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE l_del_ext;
  END IF;

  EXCEPTION

    WHEN l_del_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with External Insert';
        x_msg_data := l_msg_data ;

  END delete_row;

---------------------------------------------------------------------------
-- PROCEDURE  delete_row(s)
---------------------------------------------------------------------------

  PROCEDURE delete_row (p_api_version  IN NUMBER
       ,p_init_msg_list              IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status              OUT NOCOPY VARCHAR2
       ,x_msg_count                  OUT NOCOPY NUMBER
       ,x_msg_data                   OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl          IN okl_csh_order_tbl_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_overall_status     VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    NUMBER;

    l_cshorder_sequence  OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_cshorder_seqmax    OKL_BPD_CSH_ORDER_UV.SEQUENCE_NUMBER%TYPE;
    l_countless          INTEGER;
    l_newrownum          INTEGER;
    l_count              INTEGER;
    currseq              INTEGER;
    l_countgreat         INTEGER;

    l_del_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    l_okl_csh_order_rec  okl_csh_order_rec_type;
    lp_okl_csh_order_tbl okl_csh_order_tbl_type;
    l_stav_rec          stav_rec_type;
    x_stav_rec          stav_rec_type;
    l_stav_tbl          stav_tbl_type;
    x_stav_tbl          stav_tbl_type;

BEGIN

SAVEPOINT csh_order_seq_delete_tbl;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_okl_csh_order_tbl :=  p_okl_csh_order_tbl;

--Delete the Master
--Initialize the return status
l_return_status := Okc_Api.G_RET_STS_SUCCESS;

-- Begin Post-Generation Change
-- overall error status
l_overall_status := Okl_Api.G_RET_STS_SUCCESS;
-- End Post-Generation Change

IF (lp_okl_csh_order_tbl.COUNT > 0) THEN
  i := lp_okl_csh_order_tbl.FIRST;
  LOOP

        delete_row(
              l_api_version
             ,l_init_msg_list
             ,l_return_status
             ,l_msg_count
             ,l_msg_data
             ,lp_okl_csh_order_tbl(i));

-- Begin Post-Generation Change
-- store the highest degree of error
IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
 IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    l_overall_status := x_return_status;
 END IF;
END IF;
-- End Post-Generation Change

    EXIT WHEN (i = lp_okl_csh_order_tbl.LAST);
    i := lp_okl_csh_order_tbl.NEXT(i);
  END LOOP;

-- Begin Post-Generation Change
-- return overall status
x_return_status := l_overall_status;
-- End Post-Generation Change

 END IF;

 IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
    RAISE l_del_ext;
 ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE l_del_ext;
END IF;

 EXCEPTION

    WHEN l_del_ext THEN
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        l_msg_data := 'Problems with External Delete';
        x_msg_data := l_msg_data ;

  END delete_row;

END OKL_CSH_ORDER_SEQ_Pvt;

/
