--------------------------------------------------------
--  DDL for Package Body IEX_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_OPEN_INTERFACE_PUB" AS
/* $Header: IEXPOPIB.pls 120.2 2004/12/16 16:21:44 jsanju ship $ */

---------------------------------------------------------------------------
-- PROCEDURE report_all_credit_bureau
---------------------------------------------------------------------------
PG_DEBUG NUMBER(2);

PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER) AS
lx_errbuf            VARCHAR2(2000);
lx_retcode           NUMBER;
BEGIN
iex_opi_pvt.report_all_credit_bureau(
    errbuf => lx_errbuf,
    retcode => lx_retcode);


errbuf := lx_errbuf;
retcode := lx_retcode;
END report_all_credit_bureau;

---------------------------------------------------------------------------
-- PROCEDURE insert_pending
---------------------------------------------------------------------------
PROCEDURE insert_pending(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2,
     p_object1_id1              IN VARCHAR2,
     p_object1_id2              IN VARCHAR2,
     p_jtot_object1_code        IN VARCHAR2,
     p_action                   IN VARCHAR2,
     p_status                   IN VARCHAR2,
     p_comments                 IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_review_date              IN DATE,
     p_recall_date              IN DATE,
     p_automatic_recall_flag    IN VARCHAR2,
     p_review_before_recall_flag    IN VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

lp_iohv_rec iohv_rec_type;
lx_iohv_rec iohv_rec_type;

lp_oinv_rec oinv_rec_type;
lx_oinv_rec oinv_rec_type;

l_object1_id1 IEX_OPEN_INT_HST.OBJECT1_ID1%TYPE;
l_object1_id2 IEX_OPEN_INT_HST.OBJECT1_ID2%TYPE;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;
l_action IEX_OPEN_INT_HST.ACTION%TYPE;
l_status IEX_OPEN_INT_HST.STATUS%TYPE;
l_comments IEX_OPEN_INT_HST.COMMENTS%TYPE;
l_ext_agncy_id IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
l_review_date IEX_OPEN_INT_HST.REVIEW_DATE%TYPE;
l_recall_date IEX_OPEN_INT_HST.RECALL_DATE%TYPE;
l_automatic_recall_flag IEX_OPEN_INT_HST.AUTOMATIC_RECALL_FLAG%TYPE;
l_review_before_recall_flag IEX_OPEN_INT_HST.REVIEW_BEFORE_RECALL_FLAG%TYPE;

BEGIN

SAVEPOINT insert_pending;


l_api_version := p_api_version;
l_init_msg_list := p_init_msg_list;
l_object1_id1 := p_object1_id1;
l_object1_id2 := p_object1_id2;
l_jtot_object1_code := p_jtot_object1_code;
l_action := p_action;
l_status := p_status;
l_comments := p_comments;
l_ext_agncy_id := p_ext_agncy_id;
l_review_date := p_review_date;
l_recall_date := p_recall_date;
l_automatic_recall_flag := p_automatic_recall_flag;
l_review_before_recall_flag := p_review_before_recall_flag;

IF(l_ext_agncy_id = OKL_API.G_MISS_NUM OR l_ext_agncy_id IS NULL) THEN
  l_ext_agncy_id := NULL;
END IF;

IF(l_review_date = OKL_API.G_MISS_DATE OR l_review_date IS NULL) THEN
  l_review_date := NULL;
END IF;

IF(l_recall_date = OKL_API.G_MISS_DATE OR l_recall_date IS NULL) THEN
  l_recall_date := NULL;
END IF;

IF(l_automatic_recall_flag = OKL_API.G_MISS_CHAR OR l_automatic_recall_flag IS NULL) THEN
  l_automatic_recall_flag := NULL;
END IF;

IF(l_review_before_recall_flag = OKL_API.G_MISS_CHAR OR l_review_before_recall_flag IS NULL) THEN
  l_review_before_recall_flag := NULL;
END IF;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --processing for 'contracts'
  --insert into open interface table
  okl_open_interface_pub.insert_pending_int(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_contract_id => to_number(l_object1_id1),
     x_oinv_rec => lx_oinv_rec,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);

  IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Copy value of OUT NOCOPY variable in the IN record type
  lp_oinv_rec := lx_oinv_rec;
END IF;

--Code here for other types of objects i.e. objects other than contracts

--populate the history record
lp_iohv_rec.jtot_object1_code := l_jtot_object1_code;
lp_iohv_rec.object1_id1 := l_object1_id1;
lp_iohv_rec.object1_id2 := l_object1_id2;
lp_iohv_rec.action := l_action;
lp_iohv_rec.status := l_status;
lp_iohv_rec.comments := l_comments;
lp_iohv_rec.ext_agncy_id := l_ext_agncy_id;
lp_iohv_rec.review_date := l_review_date;
lp_iohv_rec.recall_date := l_recall_date;
lp_iohv_rec.automatic_recall_flag := l_automatic_recall_flag;
lp_iohv_rec.review_before_recall_flag := l_review_before_recall_flag;
lp_iohv_rec.org_id := lp_oinv_rec.org_id;

iex_opi_pvt.insert_pending_hst(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_iohv_rec => lp_iohv_rec,
     x_iohv_rec => lx_iohv_rec,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_rec := lx_iohv_rec;


--Assign value to OUT NOCOPY variables
--x_iohv_rec  := lx_iohv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_pending;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_pending;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO insert_pending;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','insert_pending_int');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_pending;


---------------------------------------------------------------------------
-- PROCEDURE process_pending
---------------------------------------------------------------------------
PROCEDURE process_pending(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2) AS

lx_errbuf           VARCHAR2(2000);
lx_retcode          NUMBER;
l_case_number       OKL_OPEN_INT.CASE_NUMBER%TYPE;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;

BEGIN

l_jtot_object1_code := p_jtot_object1_code;
l_case_number := p_case_number;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --call concurrent process for contracts
  iex_opi_pvt.process_pending(
     errbuf => lx_errbuf,
     retcode => lx_retcode,
     p_case_number => l_case_number);
END IF;

--Code here for other types of objects i.e. objects other than contracts

errbuf := lx_errbuf;
retcode := lx_retcode;
END process_pending;

---------------------------------------------------------------------------
-- PROCEDURE complete_report_cb
---------------------------------------------------------------------------
PROCEDURE complete_report_cb(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_report_date              IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

l_interface_id OKL_OPEN_INT.ID%TYPE;
l_report_date  OKL_OPEN_INT.CREDIT_BUREAU_REPORT_DATE%TYPE;
l_comments     IEX_OPEN_INT_HST.COMMENTS%TYPE;

BEGIN

SAVEPOINT complete_report_cb;


l_api_version := p_api_version;
l_init_msg_list := p_init_msg_list;
l_interface_id := p_interface_id;
l_report_date := p_report_date;
l_comments := p_comments;


iex_opi_pvt.complete_report_cb(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_interface_id => l_interface_id,
     p_report_date => l_report_date,
     p_comments => l_comments,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--Assign value to OUT NOCOPY variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO complete_report_cb;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO complete_report_cb;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO complete_report_cb;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','complete_report_cb');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END complete_report_cb;

---------------------------------------------------------------------------
-- PROCEDURE complete_transfer
---------------------------------------------------------------------------
PROCEDURE complete_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2,
     p_interface_id             IN NUMBER,
     p_transfer_date            IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

l_interface_id OKL_OPEN_INT.ID%TYPE;
l_transfer_date  OKL_OPEN_INT.EXTERNAL_AGENCY_TRANSFER_DATE%TYPE;
l_comments     IEX_OPEN_INT_HST.COMMENTS%TYPE;

BEGIN

SAVEPOINT complete_transfer;


l_api_version := p_api_version;
l_init_msg_list := p_init_msg_list;
l_interface_id := p_interface_id;
l_transfer_date := p_transfer_date;
l_comments := p_comments;

iex_opi_pvt.complete_transfer(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_interface_id => l_interface_id,
     p_transfer_date => l_transfer_date,
     p_comments => l_comments,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--Assign value to OUT NOCOPY variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO complete_transfer;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO complete_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO complete_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','complete_transfer');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END complete_transfer;

---------------------------------------------------------------------------
-- PROCEDURE recall_transfer
---------------------------------------------------------------------------
PROCEDURE recall_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
     p_interface_id             IN NUMBER,
     p_recall_date              IN DATE,
     p_comments                 IN VARCHAR2 DEFAULT NULL,
     p_ext_agncy_id             IN NUMBER DEFAULT NULL,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

l_interface_id OKL_OPEN_INT.ID%TYPE;
l_recall_date  OKL_OPEN_INT.EXTERNAL_AGENCY_RECALL_DATE%TYPE;
l_comments     IEX_OPEN_INT_HST.COMMENTS%TYPE;
l_ext_agncy_id IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;

BEGIN

SAVEPOINT recall_transfer;


l_api_version := p_api_version;
l_init_msg_list := p_init_msg_list;
l_interface_id := p_interface_id;
l_recall_date := p_recall_date;
l_comments := p_comments;

iex_opi_pvt.recall_transfer(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_interface_id => l_interface_id,
     p_recall_date => l_recall_date,
     p_comments => l_comments,
     p_ext_agncy_id => l_ext_agncy_id,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_count);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--Assign value to OUT NOCOPY variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','recall_transfer');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END recall_transfer;

---------------------------------------------------------------------------
-- PROCEDURE review_transfer
---------------------------------------------------------------------------
PROCEDURE review_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
lx_msg_count NUMBER ;
lx_msg_data VARCHAR2(2000);

l_oinv_rec                 oinv_rec_type;
lx_oinv_rec                oinv_rec_type;
l_iohv_rec                 iohv_rec_type;
lx_iohv_rec                iohv_rec_type;
BEGIN

SAVEPOINT review_transfer;


l_api_version := p_api_version;
l_init_msg_list := p_init_msg_list;
l_oinv_rec := p_oinv_rec;
l_iohv_rec := p_iohv_rec;

iex_opi_pvt.review_transfer(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_oinv_rec => l_oinv_rec,
        p_iohv_rec => l_iohv_rec,
        x_oinv_rec => lx_oinv_rec,
        x_iohv_rec => lx_iohv_rec,
        x_return_status => l_return_status,
        x_msg_count => lx_msg_count,
        x_msg_data => lx_msg_data);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--Assign value to OUT NOCOPY variables
x_return_status := l_return_status ;
x_oinv_rec := lx_oinv_rec;
x_iohv_rec := lx_iohv_rec;
x_msg_count := lx_msg_count ;
x_msg_data := lx_msg_data ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := lx_msg_count ;
      x_msg_data := lx_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := lx_msg_count ;
      x_msg_data := lx_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO recall_transfer;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := lx_msg_count ;
      x_msg_data := lx_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','review_transfer');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END review_transfer;

---------------------------------------------------------------------------
-- PROCEDURE notify_customer
---------------------------------------------------------------------------
PROCEDURE notify_customer(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_party_id                 IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2) AS

lx_errbuf           VARCHAR2(2000);
lx_retcode          NUMBER;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;
l_case_number       OKL_OPEN_INT.CASE_NUMBER%TYPE;
l_party_id          HZ_PARTIES.PARTY_ID%TYPE;
l_email             HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
l_subject           VARCHAR2(2000);
l_content_id        JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
l_from              VARCHAR2(2000);
l_agent_id          NUMBER;
BEGIN

l_jtot_object1_code := p_jtot_object1_code;
l_case_number := p_case_number;
l_party_id := p_party_id;
l_email := p_email;
l_subject := p_subject;
l_content_id := p_content_id;
l_from := p_from;
l_agent_id := p_agent_id;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --call concurrent process for contracts
  iex_opi_pvt.notify_customer(
     errbuf => lx_errbuf,
     retcode => lx_retcode,
     p_case_number => l_case_number,
     p_party_id => l_party_id,
     p_agent_id => l_agent_id,
     p_content_id => l_content_id,
     p_from => l_from,
     p_subject => l_subject,
     p_email => l_email);
END IF;

--Code here for other types of objects i.e. objects other than contracts

errbuf := lx_errbuf;
retcode := lx_retcode;
END notify_customer;

---------------------------------------------------------------------------
-- PROCEDURE notify_recall_external_agency
---------------------------------------------------------------------------
PROCEDURE notify_recall_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2) AS

lx_errbuf           VARCHAR2(2000);
lx_retcode          NUMBER;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;
l_case_number       OKL_OPEN_INT.CASE_NUMBER%TYPE;

l_ext_agncy_id      IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
l_comments          IEX_OPEN_INT_HST.COMMENTS%TYPE;
BEGIN

l_jtot_object1_code := p_jtot_object1_code;
l_case_number := p_case_number;
l_ext_agncy_id := p_ext_agncy_id;
l_comments := p_comments;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --call concurrent process for contracts
  iex_opi_pvt.notify_recall_external_agency(
     errbuf => lx_errbuf,
     retcode => lx_retcode,
     p_case_number => l_case_number,
     p_ext_agncy_id => l_ext_agncy_id,
     p_comments => l_comments);
END IF;

--Code here for other types of objects i.e. objects other than contracts

errbuf := lx_errbuf;
retcode := lx_retcode;
END notify_recall_external_agency;

---------------------------------------------------------------------------
-- PROCEDURE notify_external_agency
---------------------------------------------------------------------------

PROCEDURE notify_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2) AS

lx_errbuf           VARCHAR2(2000);
lx_retcode          NUMBER;
l_case_number       OKL_OPEN_INT.CASE_NUMBER%TYPE;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;

l_ext_agncy_id      IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
l_email             HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
l_subject           VARCHAR2(2000);
l_content_id        JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
l_from              VARCHAR2(2000);
l_agent_id          NUMBER;
BEGIN

l_jtot_object1_code := p_jtot_object1_code;
l_case_number := p_case_number;
l_ext_agncy_id := p_ext_agncy_id;
l_email := p_email;
l_subject := p_subject;
l_content_id := p_content_id;
l_from := p_from;
l_agent_id := p_agent_id;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --call concurrent process for contracts
  iex_opi_pvt.notify_external_agency(
     errbuf => lx_errbuf,
     retcode => lx_retcode,
     p_case_number => l_case_number,
     p_ext_agncy_id => l_ext_agncy_id,
     p_agent_id => l_agent_id,
     p_content_id => l_content_id,
     p_from => l_from,
     p_subject => l_subject,
     p_email => l_email);
END IF;

--Code here for other types of objects i.e. objects other than contracts

errbuf := lx_errbuf;
retcode := lx_retcode;
END notify_external_agency;

---------------------------------------------------------------------------
-- PROCEDURE recall_from_external_agency
---------------------------------------------------------------------------

PROCEDURE recall_from_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_jtot_object1_code        IN VARCHAR2,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2) AS

lx_errbuf           VARCHAR2(2000);
lx_retcode          NUMBER;
l_case_number       OKL_OPEN_INT.CASE_NUMBER%TYPE;
l_jtot_object1_code IEX_OPEN_INT_HST.JTOT_OBJECT1_CODE%TYPE;

l_ext_agncy_id      IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
l_comments          IEX_OPEN_INT_HST.COMMENTS%TYPE;
BEGIN

l_jtot_object1_code := p_jtot_object1_code;
l_case_number := p_case_number;
l_ext_agncy_id := p_ext_agncy_id;
l_comments := p_comments;

IF (l_jtot_object1_code = 'OKX_LEASE') THEN
  --call concurrent process for contracts
  iex_opi_pvt.recall_from_external_agency(
     errbuf => lx_errbuf,
     retcode => lx_retcode,
     p_case_number => l_case_number,
     p_ext_agncy_id => l_ext_agncy_id,
     p_comments => l_comments);
END IF;

--Code here for other types of objects i.e. objects other than contracts

errbuf := lx_errbuf;
retcode := lx_retcode;

END recall_from_external_agency;
BEGIN
PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
END iex_open_interface_pub;

/
