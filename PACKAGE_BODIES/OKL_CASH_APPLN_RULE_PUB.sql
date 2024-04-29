--------------------------------------------------------
--  DDL for Package Body OKL_CASH_APPLN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_APPLN_RULE_PUB" AS
/* $Header: OKLPCSLB.pls 115.1 2002/12/17 00:02:12 pjgomes noship $ */

  PROCEDURE maint_cash_appln_rule(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_catv_tbl                 IN catv_tbl_type,
     x_catv_tbl                 OUT NOCOPY catv_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_catv_tbl  catv_tbl_type;
    lx_catv_tbl  catv_tbl_type;

BEGIN

SAVEPOINT maint_cash_appln_rule;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_catv_tbl :=  p_catv_tbl;

okl_cash_appln_rule_pvt.maint_cash_appln_rule(
      p_api_version => l_api_version,
      p_init_msg_list => l_init_msg_list,
      p_catv_tbl => lp_catv_tbl,
      x_catv_tbl => lx_catv_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

x_catv_tbl := lx_catv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO maint_cash_appln_rule;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO maint_cash_appln_rule;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO maint_cash_appln_rule;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_APPLN_RULE_PUB','maint_cash_appln_rule');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END maint_cash_appln_rule;

END OKL_CASH_APPLN_RULE_PUB;

/
