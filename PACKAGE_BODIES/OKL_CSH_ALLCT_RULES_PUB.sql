--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ALLCT_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ALLCT_RULES_PUB" AS
/* $Header: OKLPCSAB.pls 115.6 2004/04/13 10:42:29 rnaik noship $ */


---------------------------------------------------------------------------
-- PROCEDURE  delete_comb_rule
---------------------------------------------------------------------------

PROCEDURE delete_comb_rules (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_cahv_rec        IN cahv_rec_type
                        ) IS

i                    NUMBER :=0;
l_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cahv_rec  cahv_rec_type;
lx_cahv_rec  cahv_rec_type;

BEGIN







SAVEPOINT csh_allct_rules_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_rec :=  p_cahv_rec;
lx_cahv_rec :=  p_cahv_rec;


--Delete the Master
Okl_Csh_Allct_Rules_Pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cahv_rec);

--dbms_output.put_line('l_return_status in pub is: ' || l_return_status);
--dbms_output.put_line('l_msg_data in pub is: '      || l_msg_data);

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
      ROLLBACK TO csh_allct_rules_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_rules_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_rules_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_RULES_PUB','delete_csh_allct_srchs');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END delete_comb_rules;

---------------------------------------------------------------------------
-- PROCEDURE  delete_comb_rules
---------------------------------------------------------------------------

PROCEDURE delete_comb_rules (p_api_version  IN NUMBER
       ,p_init_msg_list   IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
       ,x_return_status   OUT NOCOPY VARCHAR2
       ,x_msg_count       OUT NOCOPY NUMBER
       ,x_msg_data        OUT NOCOPY VARCHAR2
       ,p_cahv_tbl        IN cahv_tbl_type
                        ) IS

i                    NUMBER :=0;
l_return_status      VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version        NUMBER ;
l_init_msg_list      VARCHAR2(1) ;
l_msg_data           VARCHAR2(2000);
l_msg_count          NUMBER ;
lp_cahv_tbl          cahv_tbl_type;
lx_cahv_tbl          cahv_tbl_type;

BEGIN






SAVEPOINT csh_allct_rules_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_tbl :=  p_cahv_tbl;
lx_cahv_tbl :=  p_cahv_tbl;


--Delete the Master
--Initialize the return status
l_return_status := Okc_Api.G_RET_STS_SUCCESS;

IF (lp_cahv_tbl.COUNT > 0) THEN
  i := p_cahv_tbl.FIRST;
  LOOP

    Okl_Csh_Allct_Rules_Pvt.delete_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_cahv_tbl(i));

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

--dbms_output.put_line('l_return_status in pub is: ' || l_return_status);
--dbms_output.put_line('l_msg_data in pub is: '      || l_msg_data);

    EXIT WHEN (i = lp_cahv_tbl.LAST);
    i := p_cahv_tbl.NEXT(i);
  END LOOP;
END IF;

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_rules_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_rules_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_rules_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      --Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_RULES_PUB','delete_csh_allct_srchs');
      --Fnd_Msg_Pub.count_and_get(
      --       p_count   => x_msg_count
      --      ,p_data    => x_msg_data);

END delete_comb_rules;

END OKL_CSH_ALLCT_RULES_PUB;

/
