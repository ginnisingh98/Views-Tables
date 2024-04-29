--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ORDER_SEQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ORDER_SEQ_PUB" AS
/* $Header: OKLPSATB.pls 120.3 2006/07/11 09:38:19 dkagrawa noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


---------------------------------------------------------------------------
-- PROCEDURE  insert_order_sequence
---------------------------------------------------------------------------

PROCEDURE insert_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec        IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec        OUT NOCOPY okl_csh_order_rec_type) IS

i                    NUMBER :=0;
l_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_okl_csh_order_rec  okl_csh_order_rec_type;
lx_okl_csh_order_rec  okl_csh_order_rec_type;


BEGIN







SAVEPOINT csh_order_seq_update_rec;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_okl_csh_order_rec :=  p_okl_csh_order_rec;
lx_okl_csh_order_rec :=  p_okl_csh_order_rec;

--Delete the Master
-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
Okl_Csh_Order_Seq_Pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_okl_csh_order_rec
                         ,lx_okl_csh_order_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row


x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ORDER_SEQ_PUB','update_csh_order_seq');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END insert_order_sequence;

---------------------------------------------------------------------------
-- PROCEDURE  insert_order_sequence(s)
---------------------------------------------------------------------------

PROCEDURE insert_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_tbl        IN okl_csh_order_tbl_type
       ,x_okl_csh_order_tbl        OUT NOCOPY okl_csh_order_tbl_type) IS

i                    NUMBER :=0;
l_return_status      VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version        NUMBER ;
l_init_msg_list      VARCHAR2(1) ;
l_msg_data           VARCHAR2(2000);
l_msg_count          NUMBER ;
lp_okl_csh_order_tbl          okl_csh_order_tbl_type;
lx_okl_csh_order_tbl          okl_csh_order_tbl_type;

BEGIN






SAVEPOINT csh_order_seq_update_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_okl_csh_order_tbl :=  p_okl_csh_order_tbl;
lx_okl_csh_order_tbl :=  p_okl_csh_order_tbl;


--Delete the Master
--Initialize the return status
l_return_status := Okc_Api.G_RET_STS_SUCCESS;

IF (lp_okl_csh_order_tbl.COUNT > 0) THEN
  i := p_okl_csh_order_tbl.FIRST;
  LOOP

-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
    Okl_Csh_Order_Seq_Pvt.insert_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_okl_csh_order_tbl(i)
                             ,lx_okl_csh_order_tbl(i));
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

    EXIT WHEN (i = lp_okl_csh_order_tbl.LAST);
    i := p_okl_csh_order_tbl.NEXT(i);
  END LOOP;
END IF;

IF (l_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ORDER_SEQ_PUB','update_csh_order_seq');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END insert_order_sequence;


---------------------------------------------------------------------------
-- PROCEDURE  update_order_sequence
---------------------------------------------------------------------------

PROCEDURE update_order_sequence (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_okl_csh_order_rec        IN okl_csh_order_rec_type
       ,x_okl_csh_order_rec        OUT NOCOPY okl_csh_order_rec_type) IS

i                    NUMBER :=0;
l_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_okl_csh_order_rec  okl_csh_order_rec_type;
lx_okl_csh_order_rec  okl_csh_order_rec_type;

BEGIN






SAVEPOINT csh_order_seq_update_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_okl_csh_order_rec :=  p_okl_csh_order_rec;
lx_okl_csh_order_rec :=  p_okl_csh_order_rec;


--Delete the Master
-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.update_row
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.update_row ');
    END;
  END IF;
Okl_Csh_Order_Seq_Pvt.update_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_okl_csh_order_rec
                         ,lx_okl_csh_order_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.update_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.update_row

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_order_seq_update_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ORDER_SEQ_PUB','update_csh_order_seq');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END update_order_sequence;

---------------------------------------------------------------------------
-- PROCEDURE  update_order_sequence(s)
---------------------------------------------------------------------------

PROCEDURE update_order_sequence (p_api_version       IN NUMBER
                                ,p_init_msg_list     IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_msg_count         OUT NOCOPY NUMBER
                                ,x_msg_data          OUT NOCOPY VARCHAR2
                                ,p_okl_csh_order_tbl IN okl_csh_order_tbl_type
                                ,x_okl_csh_order_tbl OUT NOCOPY okl_csh_order_tbl_type
                                ) IS

i                           NUMBER :=0;
j                           NUMBER :=0;
k                           NUMBER :=0;
l                           NUMBER :=0;

l_return_status             VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version               NUMBER;
l_init_msg_list             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
l_msg_count                 NUMBER;
l_count                     INTEGER;

l_id                        OKL_STRM_TYP_ALLOCS.ID%TYPE;
l_sty_id                    OKL_BPD_CSH_ORDER_UV.STY_ID%TYPE;
l_cat_id                    OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;
l_seq_num                   OKL_BPD_CSH_ORDER_UV.CAT_ID%TYPE;
l_strm_type                 OKL_BPD_CSH_ORDER_UV.STREAM_ALLC_TYPE%TYPE;

lp_okl_csh_order_tbl        okl_csh_order_tbl_type;
lx_okl_csh_order_tbl        okl_csh_order_tbl_type;
lp_okl_csh_order_upd_tbl    okl_csh_order_tbl_type;
lx_okl_csh_order_upd_tbl    okl_csh_order_tbl_type;
lp_okl_csh_order_ins_tbl    okl_csh_order_tbl_type;
lx_okl_csh_order_ins_tbl    okl_csh_order_tbl_type;
lp_okl_csh_order_del_tbl    okl_csh_order_tbl_type;
lp_okl_csh_pro_ins_tbl      okl_csh_order_tbl_type;
lx_okl_csh_pro_ins_tbl      okl_csh_order_tbl_type;
lp_okl_csh_pro_del_tbl      okl_csh_order_tbl_type;

 -------------------
-- DECLARE Cursors
-------------------

    -- get id of record to be updated or deleted for ODD
    CURSOR c_get_id_odd (l_sty_id IN NUMBER, l_cat_id IN NUMBER) IS
    SELECT id
    FROM OKL_STRM_TYP_ALLOCS sta
    WHERE sta.STY_ID  = l_sty_id
    AND   sta.CAT_ID  = l_cat_id
    AND   sta.STREAM_ALLC_TYPE = 'ODD';

    -- get id of record to be updated or deleted for PRO
    CURSOR c_get_id_pro (l_sty_id IN NUMBER, l_cat_id IN NUMBER) IS
    SELECT id
    FROM OKL_STRM_TYP_ALLOCS sta
    WHERE sta.STY_ID  = l_sty_id
    AND   sta.CAT_ID  = l_cat_id
    AND   sta.STREAM_ALLC_TYPE = 'PRO';

    --Find whether it's insert or update for ordered sequence
    CURSOR c_csh_ins_upd_flag (l_sty_id IN NUMBER, l_cat_id IN NUMBER) IS
    SELECT count(*) COUNT
    FROM OKL_STRM_TYP_ALLOCS sta
    WHERE sta.STY_ID  = l_sty_id
    AND   sta.CAT_ID  = l_cat_id
    AND   sta.STREAM_ALLC_TYPE = 'ODD';

    --Find whether it's new insert or duplicate for prorate sequence
    CURSOR c_csh_ins_yn_flag (l_sty_id IN NUMBER, l_cat_id IN NUMBER) IS
    SELECT count(*) COUNT
    FROM OKL_STRM_TYP_ALLOCS sta
    WHERE sta.STY_ID  = l_sty_id
    AND   sta.CAT_ID  = l_cat_id
    AND   sta.STREAM_ALLC_TYPE = 'PRO'
    AND   sta.ID is not null;

   c_csh_ins_upd_flag_rec               c_csh_ins_upd_flag%ROWTYPE;
   c_csh_ins_yn_flag_rec                c_csh_ins_yn_flag%ROWTYPE;

BEGIN



SAVEPOINT csh_order_seq_update_tbl;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_okl_csh_order_tbl :=  p_okl_csh_order_tbl;
lx_okl_csh_order_tbl :=  p_okl_csh_order_tbl;

--Delete the Master
--Initialize the return status
l_return_status := Okc_Api.G_RET_STS_SUCCESS;


IF (lp_okl_csh_order_tbl.COUNT > 0) THEN
    i := lp_okl_csh_order_tbl.FIRST;
    j := 1;
    k := 1;
    l := 1;

    LOOP

        l_sty_id    := lp_okl_csh_order_tbl(i).STY_ID;
        l_cat_id    := lp_okl_csh_order_tbl(i).CAT_ID;
        l_strm_type := lp_okl_csh_order_tbl(i).STREAM_ALLC_TYPE;


        --Check if the sequence is ordered
        IF (l_strm_type = 'ODD') THEN
            l_seq_num   := lp_okl_csh_order_tbl(i).SEQUENCE_NUMBER;
                IF (l_seq_num > 0) THEN

                    OPEN c_csh_ins_upd_flag(l_sty_id, l_cat_id);
                    FETCH c_csh_ins_upd_flag INTO c_csh_ins_upd_flag_rec;
                    CLOSE c_csh_ins_upd_flag;

                    OPEN c_get_id_odd(l_sty_id, l_cat_id);
                    FETCH c_get_id_odd INTO l_id;
                    CLOSE c_get_id_odd;

                    l_count :=  c_csh_ins_upd_flag_rec.COUNT;

                    IF (l_count > 0) THEN

                        lp_okl_csh_order_tbl(i).id := l_id;
                        lp_okl_csh_order_tbl(i).STREAM_ALLC_TYPE := 'ODD';
                        lp_okl_csh_order_upd_tbl(j) :=  lp_okl_csh_order_tbl(i);
                        j := j + 1;

                    ELSE

                        lp_okl_csh_order_tbl(i).STREAM_ALLC_TYPE := 'ODD';
                        lp_okl_csh_order_ins_tbl(k) :=  lp_okl_csh_order_tbl(i);
                        k := k + 1;

                    END IF;

                ELSE
                    l_id := NULL;
                    OPEN c_get_id_odd(l_sty_id, l_cat_id);
                    FETCH c_get_id_odd INTO l_id;
                    CLOSE c_get_id_odd;


                    IF l_id IS NOT NULL THEN
                        lp_okl_csh_order_tbl(i).id := l_id;
                        lp_okl_csh_order_tbl(i).STREAM_ALLC_TYPE := 'ODD';
                        lp_okl_csh_order_del_tbl(l) :=  lp_okl_csh_order_tbl(i);
                        l := l + 1;
                    END IF;

                END IF;

            -- the seq is prorate
            ELSE

                IF (l_strm_type = 'PRO') THEN

                    OPEN c_csh_ins_yn_flag(l_sty_id, l_cat_id);
                    FETCH c_csh_ins_yn_flag INTO c_csh_ins_yn_flag_rec;
                    CLOSE c_csh_ins_yn_flag;

                    l_count :=  c_csh_ins_yn_flag_rec.COUNT;

                    IF (l_count <= 0) THEN
                        lp_okl_csh_order_tbl(i).STREAM_ALLC_TYPE := 'PRO';
                        lp_okl_csh_order_ins_tbl(j) :=  lp_okl_csh_order_tbl(i);
                        j := j + 1;
                    END IF;

                ELSE

                    l_id := NULL;
                    OPEN c_get_id_pro(l_sty_id, l_cat_id);
                    FETCH c_get_id_pro INTO l_id;
                    CLOSE c_get_id_pro;

                    IF l_id IS NOT NULL THEN
                        lp_okl_csh_order_tbl(i).id := l_id;
                        lp_okl_csh_order_del_tbl(k) :=  lp_okl_csh_order_tbl(i);
                        k := k + 1;
                    END IF;

                END IF;

            END IF;

            EXIT WHEN (i = lp_okl_csh_order_tbl.LAST);
            i := lp_okl_csh_order_tbl.NEXT(i);
    END LOOP;

    IF (lp_okl_csh_order_upd_tbl.COUNT = 0) OR
       (lp_okl_csh_order_ins_tbl.COUNT = 0) THEN

        x_return_status := l_return_status;

    END IF;

    IF (lp_okl_csh_order_upd_tbl.COUNT > 0) THEN

    --updating sequences


-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.update_row
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.update_row ');
    END;
  END IF;
        Okl_Csh_Order_Seq_Pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_okl_csh_order_upd_tbl
                             ,lx_okl_csh_order_upd_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.update_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.update_row

        x_okl_csh_order_tbl :=   lx_okl_csh_order_upd_tbl;
        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;


    END IF;

    IF (lp_okl_csh_order_ins_tbl.COUNT > 0) THEN

        --inserting sequences


-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
        Okl_Csh_Order_Seq_Pvt.insert_row(
                                  l_api_version
                                 ,l_init_msg_list
                                 ,l_return_status
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,lp_okl_csh_order_ins_tbl
                                ,lx_okl_csh_order_ins_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.insert_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.insert_row


        x_okl_csh_order_tbl :=   lx_okl_csh_order_ins_tbl;
        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;


    END IF;

    IF (lp_okl_csh_order_del_tbl.COUNT > 0) THEN

        --deleting sequence
        i := lp_okl_csh_order_tbl.FIRST;
        loop
            EXIT WHEN (i = lp_okl_csh_order_del_tbl.LAST);
            i := i + 1;
        end loop;


-- Start of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.delete_row
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.delete_row ');
    END;
  END IF;
        Okl_Csh_Order_Seq_Pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_okl_csh_order_del_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSATB.pls call Okl_Csh_Order_Seq_Pvt.delete_row ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Csh_Order_Seq_Pvt.delete_row

        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;

--        commit;


    END IF;

/*
 IF (lp_okl_csh_pro_ins_tbl.COUNT > 0) THEN

        --inserting sequences


        Okl_Csh_Order_Seq_Pvt.insert_row(
                                  l_api_version
                                 ,l_init_msg_list
                                 ,l_return_status
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,lp_okl_csh_pro_ins_tbl
                                 ,lx_okl_csh_pro_ins_tbl);


        x_okl_csh_order_tbl :=   lx_okl_csh_pro_ins_tbl;
        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;


 END IF;

 IF (lp_okl_csh_pro_del_tbl.COUNT > 0) THEN

        Okl_Csh_Order_Seq_Pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_okl_csh_pro_del_tbl);

        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;


 END IF;
*/
END IF;

IF (l_return_status = Fnd_Api.G_RET_STS_ERROR)  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_order_seq_update_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ORDER_SEQ_PUB','update_csh_order_seq');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END update_order_sequence;

END OKL_CSH_ORDER_SEQ_PUB;

/
