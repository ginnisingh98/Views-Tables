--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ALLCT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ALLCT_RULES_PVT" AS
/* $Header: OKLRCSAB.pls 120.2 2006/07/11 09:44:26 dkagrawa noship $ */


---------------------------------------------------------------------------
-- PROCEDURE  delete_comb_rule
---------------------------------------------------------------------------

PROCEDURE delete_row (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_cahv_rec        IN cahv_rec_type
                        ) IS

---------------------------
-- DECLARE Local Variables
---------------------------

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                        NUMBER;
    l_allct_name         OKL_CSH_ALLCT_SRCHS.NAME%TYPE;
    l_allct_id           OKL_CSH_ALLCT_SRCHS.ID%TYPE;
    l_del_ext            EXCEPTION;

------------------------------
-- DECLARE Record/Table Types
------------------------------

    --l_cahv_rec     cahv_rec_type;
    l_cahv_rec     cahv_rec_type   := p_cahv_rec;
    l_cahv_tbl     cahv_tbl_type;

    l_sstv_rec     Okl_Sst_Pvt.sstv_rec_type;
    l_sstv_tbl     Okl_Sst_Pvt.sstv_tbl_type;

-------------------
-- DECLARE Cursors
-------------------
--  Get the ID given the name of the rule
--  CURSOR c_csh_allct_srchs_id (cp_rule_name IN VARCHAR2) IS
--  SELECT cas.ID
--  FROM OKL_CSH_ALLCT_SRCHS_V cas
--  WHERE cas.NAME = cp_rule_name;

--  Get the ID of the combination given the CAH_ID
    CURSOR c_srch_strm_typs_id (cp_rule_id IN NUMBER) IS
    SELECT sst.ID
    FROM OKL_SRCH_STRM_TYPS_V sst
    WHERE sst.CAH_ID = cp_rule_id;

    c_srch_strm_typs_id_rec c_srch_strm_typs_id%ROWTYPE;

    BEGIN

    l_allct_id    :=  l_cahv_rec.ID;
    --OPEN c_csh_allct_srchs_id (l_allct_name);

    --FETCH c_csh_allct_srchs_id INTO l_allct_id;
    --EXIT WHEN c_csh_allct_srchs_id%NOTFOUND
    --OR p_allct_name IS NULL;

    -- dbms_output.put_line('Rule Id for name ' || l_allct_name || ' is '  || l_allct_id);


    i  := 1;

    OPEN c_srch_strm_typs_id (l_allct_id);
    LOOP

    FETCH c_srch_strm_typs_id INTO c_srch_strm_typs_id_rec;
    EXIT WHEN c_srch_strm_typs_id%NOTFOUND;

    l_sstv_tbl(i).ID          := c_srch_strm_typs_id_rec.ID;

    i := i + 1;

    END LOOP;


    Okl_Srch_Strm_Typs_Pub.delete_srch_strm_typs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_sstv_tbl
                                                    );

    -- dbms_output.put_line ('combinations deleted, About to delete the rule');
    -- dbms_output.put_line('l_return_status for comb is: ' || l_return_status);
    -- dbms_output.put_line('l_msg_data for comb is: '      || l_msg_data);



    l_cahv_rec.ID            := l_allct_id;


    Okl_Csh_Allct_Srchs_Pub.delete_csh_allct_srchs(l_api_version
                                                    ,l_init_msg_list
                                                    ,l_return_status
                                                    ,l_msg_count
                                                    ,l_msg_data
                                                    ,l_cahv_rec
                                                    );

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

-- dbms_output.put_line('l_return_status for rule is: ' || l_return_status);
-- dbms_output.put_line('l_msg_data fo rule is: '      || l_msg_data);
-- dbms_output.put_line ('rule deleted');


    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
    RAISE L_DEL_EXT;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
    RAISE L_DEL_EXT;
    END IF;

    EXCEPTION

    WHEN L_DEL_EXT THEN
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    l_msg_data := 'Problems with External Delete';
    x_msg_data := l_msg_data ;


    END delete_row;


    END OKL_CSH_ALLCT_RULES_Pvt;


/
