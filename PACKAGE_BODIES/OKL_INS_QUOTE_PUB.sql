--------------------------------------------------------
--  DDL for Package Body OKL_INS_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INS_QUOTE_PUB" AS
/* $Header: OKLPINQB.pls 120.4 2005/09/19 11:36:22 pagarg noship $ */

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;

----------------------------------------------------
---   Save Quote
----------------------------------------------------
   PROCEDURE save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
	 x_message                      OUT NOCOPY VARCHAR2  )IS
     l_api_version NUMBER ;
     l_init_msg_list VARCHAR2(1) ;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER ;
     l_msg_data VARCHAR2(2000);
     l_ipyv_rec  ipyv_rec_type;
     l_iasset_tbl     iasset_tbl_type;
     l_message   VARCHAR2(2000);
   BEGIN
      SAVEPOINT ins_save_quote;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := px_ipyv_rec;
Okl_Ins_Quote_Pvt.save_quote(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec       ,
	     x_message
 );
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
px_ipyv_rec := l_ipyv_rec ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_save_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_save_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_save_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','save_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
 END save_quote ;

----------------------------------------------------
---   Save Accept Quote
----------------------------------------------------
 PROCEDURE save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN  ipyv_rec_type,
	 x_message                      OUT NOCOPY VARCHAR2  ) IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
l_message   VARCHAR2(2000);
BEGIN
SAVEPOINT ins_save_accept_quote;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := p_ipyv_rec;
Okl_Ins_Quote_Pvt.save_accept_quote(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec       ,
	     x_message
 );
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_save_accept_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_save_accept_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_save_accept_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','save_accept_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END save_accept_quote ;

----------------------------------------------------
---   Accept Quote
----------------------------------------------------
PROCEDURE accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_quote_id                     IN NUMBER ) IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_quote_id  NUMBER ;
BEGIN
SAVEPOINT ins_accept_quote;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_quote_id := p_quote_id;
Okl_Ins_Quote_Pvt.accept_quote(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data,
						 l_quote_id);
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_accept_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_accept_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_accept_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','accept_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END accept_quote;

----------------------------------------------------
---   Create Insurance Stream
----------------------------------------------------
PROCEDURE   create_ins_streams(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         ) IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
BEGIN
SAVEPOINT ins_create_ins_streams;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := p_ipyv_rec;
Okl_Ins_Quote_Pvt.create_ins_streams(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec
 );

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_create_ins_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_create_ins_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_create_ins_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','create_ins_streams');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
 END  create_ins_streams ;

----------------------------------------------------
---   calculate lease premium
----------------------------------------------------
	      PROCEDURE   calc_lease_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
	     x_message                      OUT  NOCOPY VARCHAR2,
         x_iasset_tbl                  OUT NOCOPY  iasset_tbl_type
     )IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
l_iasset_tbl     iasset_tbl_type;
l_message   VARCHAR2(2000);
BEGIN
SAVEPOINT ins_calc_lease_premium;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := px_ipyv_rec;
Okl_Ins_Quote_Pvt.CALC_LEASE_PREMIUM(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec       ,
	     x_message         ,
         x_iasset_tbl      );
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
px_ipyv_rec := l_ipyv_rec ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_calc_lease_premium;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_calc_lease_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_calc_lease_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','calc_lease_premium');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END  calc_lease_premium ;

----------------------------------------------------
---   activate_ins_stream for policy
----------------------------------------------------
PROCEDURE  activate_ins_stream(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY  NUMBER,
     x_msg_data                     OUT NOCOPY  VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         )  IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
BEGIN
SAVEPOINT ins_activate_ins_stream;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := p_ipyv_rec;
Okl_Ins_Quote_Pvt.activate_ins_stream(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec
 );

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_activate_ins_stream;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_activate_ins_stream;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_activate_ins_stream;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','activate_ins_stream');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END activate_ins_stream;

----------------------------------------------------
---   activate_ins_stream for backgroud process
----------------------------------------------------
PROCEDURE  activate_ins_streams(
	errbuf           OUT NOCOPY  VARCHAR2,
	retcode          OUT NOCOPY  NUMBER
 )IS
	BEGIN
		 NULL;
	END activate_ins_streams;

----------------------------------------------------
---   activate_ins_stream for contract
----------------------------------------------------
 PROCEDURE  activate_ins_streams(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT  NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY  NUMBER,
     x_msg_data                     OUT NOCOPY  VARCHAR2,
     p_contract_id                  IN NUMBER
         )IS
 l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_contract_id NUMBER ;
BEGIN
SAVEPOINT activate_ins_streams;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_contract_id := p_contract_id;
Okl_Ins_Quote_Pvt.activate_ins_streams(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
						  ,l_contract_id) ;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO activate_ins_streams;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO activate_ins_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO activate_ins_streams;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','activate_ins_streams');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
 END activate_ins_streams;

----------------------------------------------------
---   activate insurance policy
----------------------------------------------------
PROCEDURE  activate_ins_policy(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ins_policy_id                     IN NUMBER  ) IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ins_policy_id NUMBER ;
BEGIN
SAVEPOINT activate_ins_policy;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ins_policy_id := p_ins_policy_id;
Okl_Ins_Quote_Pvt.activate_ins_policy(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
						  ,l_ins_policy_id) ;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO activate_ins_policy;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO activate_ins_policy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO activate_ins_policy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','activate_ins_policy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END activate_ins_policy;

----------------------------------------------------
---   calculate optional premium
----------------------------------------------------
      PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
	     x_message                      OUT NOCOPY  VARCHAR2,
         x_ipyv_rec                  OUT NOCOPY   ipyv_rec_type
     )IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
lx_ipyv_rec  ipyv_rec_type;
l_message   VARCHAR2(2000);
BEGIN
SAVEPOINT ins_calc_optional_premium;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := p_ipyv_rec;

Okl_Ins_Quote_Pvt.CALC_optional_PREMIUM(
         l_api_version     ,
		 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec       ,
	     x_message         ,
         lx_ipyv_rec      );
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_ipyv_rec := lx_ipyv_rec ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_calc_optional_premium;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_calc_optional_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_calc_optional_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','calc_optional_premium');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END  calc_optional_premium ;

---------------------------------------------------------------------------
-- Start of comments
--skgautam
-- Function Name        : calc_total_premium
--workflow
-- Description          :Calculates the total premium
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Comments
---------------------------------------------------------------------------
-- Added as part of fix of bug:3967640

PROCEDURE calc_total_premium(p_api_version                  IN NUMBER,
                             p_init_msg_list                IN VARCHAR2 ,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_pol_qte_id                   IN  VARCHAR2,
                             x_total_premium                OUT NOCOPY NUMBER) IS

l_api_version       NUMBER ;
l_init_msg_list     VARCHAR2(1) ;
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(2000);
l_pol_qte_id        VARCHAR2(100);
lx_total_premium     NUMBER;

BEGIN
SAVEPOINT ins_calc_total_premium;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_pol_qte_id := p_pol_qte_id;

OKL_INS_QUOTE_PVT.calc_total_premium(l_api_version ,
                             l_init_msg_list ,
                             l_return_status ,
                             l_msg_count ,
                             l_msg_data  ,
                             l_pol_qte_id ,
                             lx_total_premium );

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_total_premium := lx_total_premium;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ins_calc_total_premium;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ins_calc_total_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ins_calc_total_premium;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','calc_total_premium');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END  calc_total_premium ;
--------------------------

      PROCEDURE   create_third_prt_ins(
         p_api_version                   IN NUMBER,
	 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
         x_ipyv_rec                  OUT NOCOPY   ipyv_rec_type
     )IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_ipyv_rec  ipyv_rec_type;
lx_ipyv_rec  ipyv_rec_type;

BEGIN
SAVEPOINT create_third_prt_ins;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_ipyv_rec  := p_ipyv_rec;

Okl_Ins_Quote_Pvt.create_third_prt_ins(
         l_api_version     ,
	 l_init_msg_list   ,
         l_return_status   ,
         l_msg_count       ,
         l_msg_data        ,
         l_ipyv_rec       ,
         lx_ipyv_rec      );
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_ipyv_rec := lx_ipyv_rec ;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_third_prt_ins;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_third_prt_ins;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_third_prt_ins;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INS_QUOTE_PUB','create_third_prt_ins');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END  create_third_prt_ins ;
-----------------------------------

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : crt_lseapp_thrdprt_ins
  -- Description    : Wrapper on Create Third Party Insurance for Lease Application.
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : 19-Sep-2005:Bug 4567777 PAGARG new procedures for Lease
  --                  Application Functionality.
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE crt_lseapp_thrdprt_ins(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type,
     x_ipyv_rec                     OUT NOCOPY  ipyv_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'CRT_LSEAPP_THRDPRT_INS';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_ipyv_rec               ipyv_rec_type;
    lx_ipyv_rec              ipyv_rec_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_INS_QUOTE_PUB.CRT_LSEAPP_THRDPRT_INS';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_ipyv_rec  := p_ipyv_rec;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_INS_QUOTE_PVT.CRT_LSEAPP_THRDPRT_INS');
    END IF;

    OKL_INS_QUOTE_PVT.crt_lseapp_thrdprt_ins(
        l_api_version
       ,OKL_API.G_FALSE
       ,l_return_status
       ,x_msg_count
       ,x_msg_data
       ,l_ipyv_rec
       ,lx_ipyv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_INS_QUOTE_PVT.CRT_LSEAPP_THRDPRT_INS');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_INS_QUOTE_PVT.CRT_LSEAPP_THRDPRT_INS'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_ipyv_rec := lx_ipyv_rec ;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END crt_lseapp_thrdprt_ins;

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : lseapp_thrdprty_to_ctrct
  -- Description    : Wrapper to attach Third Party Insurance to contract created
  --                  from Lease Application..
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : 19-Sep-2005:Bug 4567777 PAGARG new procedures for Lease
  --                  Application Functionality.
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE lseapp_thrdprty_to_ctrct(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_lakhr_id                     IN  NUMBER,
     x_ipyv_rec                     OUT NOCOPY ipyv_rec_type)
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'LSEAPP_THRDPRTY_TO_CTRCT';
    l_return_status          VARCHAR2(1);

    -- Record/Table Type Declarations
    l_lakhr_id               NUMBER;
    lx_ipyv_rec              ipyv_rec_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_INS_QUOTE_PUB.LSEAPP_THRDPRTY_TO_CTRCT';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_lakhr_id  := p_lakhr_id;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_INS_QUOTE_PVT.LSEAPP_THRDPRTY_TO_CTRCT');
    END IF;

    OKL_INS_QUOTE_PVT.lseapp_thrdprty_to_ctrct(
        l_api_version
       ,OKL_API.G_FALSE
       ,l_return_status
       ,x_msg_count
       ,x_msg_data
       ,l_lakhr_id
       ,lx_ipyv_rec);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_INS_QUOTE_PVT.LSEAPP_THRDPRTY_TO_CTRCT');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_INS_QUOTE_PVT.LSEAPP_THRDPRTY_TO_CTRCT'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_ipyv_rec := lx_ipyv_rec ;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END lseapp_thrdprty_to_ctrct;

END OKL_INS_QUOTE_PUB;

/
