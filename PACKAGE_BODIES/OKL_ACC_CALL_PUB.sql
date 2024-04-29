--------------------------------------------------------
--  DDL for Package Body OKL_ACC_CALL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_CALL_PUB" AS
/* $Header: OKLPACCB.pls 120.3 2007/07/04 09:35:41 vpanwar ship $ */

PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_bpd_acc_rec 					IN  bpd_acc_rec_type)
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN
-- Set API savepoint
  SAVEPOINT create_acc_trans;

	Okl_Acc_Call_Pvt.CREATE_ACC_TRANS(
     	 p_api_version
    	,p_init_msg_list
    	,x_return_status
    	,x_msg_count
    	,x_msg_data
  		,p_bpd_acc_rec
	);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO create_acc_trans;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Acc_Call_Pub','create_acc_trans');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_acc_trans;


PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_bpd_acc_tbl 					IN  bpd_acc_tbl_type)
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN
-- Set API savepoint
  SAVEPOINT create_acc_trans;

	Okl_Acc_Call_Pvt.CREATE_ACC_TRANS(
     	 p_api_version
    	,p_init_msg_list
    	,x_return_status
    	,x_msg_count
    	,x_msg_data
  		,p_bpd_acc_tbl
	);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO create_acc_trans;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Acc_Call_Pub','create_acc_trans');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_acc_trans;



PROCEDURE create_acc_trans_new(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_bpd_acc_rec 					IN  bpd_acc_rec_type
    ,x_tmpl_identify_rec            OUT NOCOPY Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE
    ,x_dist_info_rec                OUT NOCOPY Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE
    ,x_ctxt_val_tbl                 OUT NOCOPY Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE
    ,x_acc_gen_primary_key_tbl      OUT NOCOPY Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY)
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN
-- Set API savepoint
  SAVEPOINT create_acc_trans_new;

	Okl_Acc_Call_Pvt.create_acc_trans_new(
     	 p_api_version
    	,p_init_msg_list
    	,x_return_status
    	,x_msg_count
    	,x_msg_data
  		,p_bpd_acc_rec
        ,x_tmpl_identify_rec
        ,x_dist_info_rec
        ,x_ctxt_val_tbl
        ,x_acc_gen_primary_key_tbl
	);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO create_acc_trans_new;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Acc_Call_Pub','create_acc_trans_new');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_acc_trans_new;


END Okl_Acc_Call_Pub;

/
