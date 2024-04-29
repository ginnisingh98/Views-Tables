--------------------------------------------------------
--  DDL for Package Body IEX_OPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_OPI_PVT" AS
/* $Header: IEXROPIB.pls 120.3 2006/07/13 05:53:12 schekuri noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc AS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version AS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy AS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE report_all_credit_bureau
  ---------------------------------------------------------------------------
  --PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER) AS

     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_name                 CONSTANT VARCHAR2(30) := 'report_all_credit_bureau';

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_rows_processed           NUMBER := 0;
     l_rows_failed              NUMBER := 0;
     l_cust_reported            NUMBER := 0;
     l_cust_not_reported        NUMBER := 0;
     l_syndicate_flag		VARCHAR2(1) := 'N';

     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;

     CURSOR l_report_all_csr(cp_organization_id IN NUMBER) IS
     SELECT id
     FROM okc_k_headers_v
     WHERE authoring_org_id = cp_organization_id
     AND scs_code = 'LEASE';
  BEGIN
    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006


    -- Get pending records to be processed
    OPEN l_report_all_csr(l_organization_id);
    LOOP
    FETCH l_report_all_csr INTO
              l_oinv_rec.khr_id;
    EXIT WHEN l_report_all_csr%NOTFOUND;

    --find out NOCOPY lessee syndicate flag
    l_return_status := OKL_CONTRACT_INFO.get_syndicate_flag(
             p_contract_id => l_oinv_rec.khr_id
            ,x_syndicate_flag => l_syndicate_flag);

    IF NOT ((l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) OR
        (l_return_status = okl_api.G_RET_STS_ERROR)       OR
        (l_syndicate_flag = 'Y')) THEN
      l_cust_reported := l_cust_reported + 1;
      --dbms_output.put_line('report - ' || l_oinv_rec.khr_id);
      iex_open_interface_pub.insert_pending(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_object1_id1 => l_oinv_rec.khr_id,
        p_object1_id2 => '#',
        p_jtot_object1_code => 'OKX_LEASE',
        p_action => IEX_OPI_PVT.ACTION_REPORT_CB,
        p_status => IEX_OPI_PVT.STATUS_PENDING_ALL,
        p_comments => OKC_API.G_MISS_CHAR,
        p_ext_agncy_id => NULL,
        p_review_date => NULL,
        p_recall_date => NULL,
        p_automatic_recall_flag => NULL,
        p_review_before_recall_flag => NULL,
        x_return_status => l_return_status,
        x_msg_count => lx_msg_count,
        x_msg_data => lx_msg_data);

      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_rows_failed := l_rows_failed + 1;
      ELSE
        l_rows_processed := l_rows_processed + 1;
      END IF;
    ELSE
      l_cust_not_reported := l_cust_not_reported + 1;
      --dbms_output.put_line('do not report - ' || l_oinv_rec.id);
    END IF;

    END LOOP;

    CLOSE l_report_all_csr;

    --dbms_output.PUT_LINE('CUSTOMERS REPORTED                              = ' || l_cust_reported);
    --dbms_output.PUT_LINE('CUSTOMERS NOT REPORTED                          = ' || l_cust_not_reported);
    --dbms_output.PUT_LINE('CUSTOMERS TO BE REPORTED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    --dbms_output.PUT_LINE('CUSTOMERS TO BE REPORTED NOT PROCESSED          = ' || l_rows_failed);

    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS REPORTED                              = ' || l_cust_reported);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS NOT REPORTED                          = ' || l_cust_not_reported);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS TO BE REPORTED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS TO BE REPORTED NOT PROCESSED          = ' || l_rows_failed);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_report_all_csr%ISOPEN THEN
        CLOSE l_report_all_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END report_all_credit_bureau;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pending_hst
  ---------------------------------------------------------------------------
  PROCEDURE insert_pending_hst(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_iohv_rec                 IN iohv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'insert_pending_hst';

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;
     l_contract_hst_found       BOOLEAN := FALSE;

     CURSOR l_ioh_csr(cp_object1_id1 IN VARCHAR2
                     ,cp_object1_id2 IN VARCHAR2
                     ,cp_jtot_object1_code IN VARCHAR2
                     ,cp_action IN VARCHAR2
                     ,cp_status IN VARCHAR2) IS
     SELECT id
     FROM iex_open_int_hst
     WHERE jtot_object1_code = cp_jtot_object1_code
     AND object1_id1 = cp_object1_id1
     AND object1_id2 = cp_object1_id2
     AND action = cp_action
     AND status = cp_status;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    /*
    l_iohv_rec.jtot_object1_code := p_iohv_rec.jtot_object1_code;
    l_iohv_rec.object1_id1 := p_iohv_rec.object1_id1;
    l_iohv_rec.object1_id2 := p_iohv_rec.object1_id2;
    l_iohv_rec.action := p_iohv_rec.action;
    l_iohv_rec.status := p_iohv_rec.status;
    l_iohv_rec.comments := p_iohv_rec.comments;
    l_iohv_rec.org_id := p_iohv_rec.org_id;
    */
    l_iohv_rec := p_iohv_rec;
    l_iohv_rec.request_date := sysdate;

    IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
      l_iohv_rec.comments := NULL;
    END IF;


    FOR cur IN l_ioh_csr(l_iohv_rec.object1_id1
                        ,l_iohv_rec.object1_id2
                        ,l_iohv_rec.jtot_object1_code
                        ,l_iohv_rec.action
                        ,l_iohv_rec.status
                        ) LOOP
      l_iohv_rec.id := cur.id;
      l_contract_hst_found := TRUE;
    END LOOP;

    IF l_contract_hst_found THEN
      iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
    ELSE
      iex_open_int_hst_pub.insert_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
    END IF;

    x_iohv_rec := lx_iohv_rec;

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Processing ends

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_pending_hst;

  ---------------------------------------------------------------------------
  -- PROCEDURE process_pending_hst
  ---------------------------------------------------------------------------
  PROCEDURE process_pending_hst(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_iohv_rec                 OUT NOCOPY iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2)AS

     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'process_pending_hst';

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lp_iohv_rec                iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_oinv_rec := p_oinv_rec;
    l_iohv_rec := p_iohv_rec;
    l_iohv_rec.status := STATUS_PROCESSED;
    l_iohv_rec.process_date := SYSDATE;

    --Get external agency to pass case
    IF (l_iohv_rec.action = IEX_OPI_PVT.ACTION_TRANSFER_EXT_AGNCY) THEN
      IF (l_iohv_rec.ext_agncy_id IS NULL) THEN
        get_external_agency(p_oinv_rec => l_oinv_rec
                         ,p_iohv_rec => l_iohv_rec
                         ,x_ext_agncy_id => l_iohv_rec.ext_agncy_id
                         ,x_return_status => l_return_status);

        IF(l_iohv_rec.ext_agncy_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('IEX', 'IEX_EXTERNAL_AGENCY_UNASSIGNED');
          FND_MESSAGE.SET_TOKEN('CASE_ID', TO_CHAR(l_oinv_rec.cas_id));
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET);
        END IF;
      END IF;

      IF(l_iohv_rec.ext_agncy_id IS NOT NULL) THEN
          lp_iohv_rec := l_iohv_rec;
          lp_iohv_rec.id := null;
          lp_iohv_rec.action := ACTION_NOTIFY_EXT_AGNCY;
          lp_iohv_rec.status := STATUS_PROCESSED;
          lp_iohv_rec.request_date := SYSDATE;
          lp_iohv_rec.process_date := SYSDATE;
          lp_iohv_rec.review_date := NULL;
          lp_iohv_rec.recall_date := NULL;
          lp_iohv_rec.automatic_recall_flag := NULL;
          lp_iohv_rec.review_before_recall_flag := NULL;

          iex_open_int_hst_pub.insert_open_int_hst(
            p_api_version => l_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data  => lx_msg_data,
            p_iohv_rec => lp_iohv_rec,
            x_iohv_rec => lx_iohv_rec);
      END IF;

/*
      --Get number of days to transfer case to external agency
      IF(l_iohv_rec.review_date IS NULL) THEN
        l_iohv_rec.review_date := l_iohv_rec.request_date + fnd_profile.value('IEX_EA_TRANSFER_DAYS');
      END IF;
      */
    END IF;

    iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_data => x_msg_data
                          ,p_iohv_rec => l_iohv_rec
                          ,x_iohv_rec => lx_iohv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_iohv_rec := lx_iohv_rec;

    -- Processing ends
    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END process_pending_hst;

  ---------------------------------------------------------------------------
  -- PROCEDURE process_pending
  ---------------------------------------------------------------------------
  PROCEDURE process_pending(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2) AS

     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_name                 CONSTANT VARCHAR2(30) := 'process_pending';
     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_rows_processed           NUMBER := 0;
     l_rows_failed              NUMBER := 0;

     l_case_passed              VARCHAR2(1) := Okc_Api.G_TRUE;
     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;

     CURSOR l_oin_pend_csr(cp_case_number IN VARCHAR2
                          ,cp_organization_id IN NUMBER) IS
     SELECT OIN.ID,
            OIN.PARTY_ID,
            OIN.PARTY_NAME,
            OIN.PARTY_TYPE,
            OIN.DATE_OF_BIRTH,
            OIN.PLACE_OF_BIRTH,
            OIN.PERSON_IDENTIFIER,
            OIN.PERSON_IDEN_TYPE,
            OIN.COUNTRY,
            OIN.ADDRESS1,
            OIN.ADDRESS2,
            OIN.ADDRESS3,
            OIN.ADDRESS4,
            OIN.CITY,
            OIN.POSTAL_CODE,
            OIN.STATE,
            OIN.PROVINCE,
            OIN.COUNTY,
            OIN.PO_BOX_NUMBER,
            OIN.HOUSE_NUMBER,
            OIN.STREET_SUFFIX,
            OIN.APARTMENT_NUMBER,
            OIN.STREET,
            OIN.RURAL_ROUTE_NUMBER,
            OIN.STREET_NUMBER,
            OIN.BUILDING,
            OIN.FLOOR,
            OIN.SUITE,
            OIN.ROOM,
            OIN.POSTAL_PLUS4_CODE,
            OIN.CAS_ID,
            OIN.CASE_NUMBER,
            OIN.KHR_ID,
            OIN.CONTRACT_NUMBER,
            OIN.CONTRACT_TYPE,
            OIN.CONTRACT_STATUS,
            OIN.ORIGINAL_AMOUNT,
            OIN.START_DATE,
            OIN.CLOSE_DATE,
            OIN.TERM_DURATION,
            OIN.MONTHLY_PAYMENT_AMOUNT,
            OIN.LAST_PAYMENT_DATE,
            OIN.DELINQUENCY_OCCURANCE_DATE,
            OIN.PAST_DUE_AMOUNT,
            OIN.REMAINING_AMOUNT,
            OIN.CREDIT_INDICATOR,
            OIN.NOTIFICATION_DATE,
            OIN.CREDIT_BUREAU_REPORT_DATE,
            OIN.CONTACT_ID,
            OIN.CONTACT_NAME,
            OIN.CONTACT_PHONE,
            OIN.CONTACT_EMAIL,
            OIN.OBJECT_VERSION_NUMBER,
            OIN.ORG_ID,
            OIN.REQUEST_ID,
            OIN.PROGRAM_APPLICATION_ID,
            OIN.PROGRAM_ID,
            OIN.PROGRAM_UPDATE_DATE,
            OIN.ATTRIBUTE_CATEGORY,
            OIN.ATTRIBUTE1,
            OIN.ATTRIBUTE2,
            OIN.ATTRIBUTE3,
            OIN.ATTRIBUTE4,
            OIN.ATTRIBUTE5,
            OIN.ATTRIBUTE6,
            OIN.ATTRIBUTE7,
            OIN.ATTRIBUTE8,
            OIN.ATTRIBUTE9,
            OIN.ATTRIBUTE10,
            OIN.ATTRIBUTE11,
            OIN.ATTRIBUTE12,
            OIN.ATTRIBUTE13,
            OIN.ATTRIBUTE14,
            OIN.ATTRIBUTE15,
            OIN.CREATED_BY,
            OIN.CREATION_DATE,
            OIN.LAST_UPDATED_BY,
            OIN.LAST_UPDATE_DATE,
            OIN.LAST_UPDATE_LOGIN,
            IOH.ID,
            IOH.OBJECT1_ID1,
            IOH.OBJECT1_ID2,
            IOH.JTOT_OBJECT1_CODE,
            IOH.ACTION,
            IOH.STATUS,
            IOH.COMMENTS,
            IOH.REQUEST_DATE,
            IOH.PROCESS_DATE,
            IOH.EXT_AGNCY_ID,
            IOH.REVIEW_DATE,
            IOH.RECALL_DATE
     FROM Okl_Open_Int OIN
          ,Iex_Open_Int_Hst IOH
     WHERE OIN.khr_id = TO_NUMBER(IOH.OBJECT1_ID1)
     AND   IOH.JTOT_OBJECT1_CODE = 'OKX_LEASE'
     AND   ((l_case_passed = Okc_Api.G_FALSE) OR
            (l_case_passed = Okc_Api.G_TRUE AND OIN.case_number = cp_case_number))
     AND   OIN.org_id = cp_organization_id
     AND   ((IOH.STATUS = STATUS_PENDING_AUTO) OR
            (IOH.STATUS = STATUS_PENDING_MANUAL) OR
            (IOH.STATUS = STATUS_PENDING_ALL));
  BEGIN
    --check if case number is passed
    IF (p_case_number = OKC_API.G_MISS_CHAR OR
        p_case_number IS NULL) THEN
      l_case_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('case is not passed');
    END IF;

    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006

    -- Get pending records to be processed
    OPEN l_oin_pend_csr(p_case_number
                       ,l_organization_id);
    LOOP
    FETCH l_oin_pend_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.party_id,
              l_oinv_rec.party_name,
              l_oinv_rec.party_type,
              l_oinv_rec.date_of_birth,
              l_oinv_rec.place_of_birth,
              l_oinv_rec.person_identifier,
              l_oinv_rec.person_iden_type,
              l_oinv_rec.country,
              l_oinv_rec.address1,
              l_oinv_rec.address2,
              l_oinv_rec.address3,
              l_oinv_rec.address4,
              l_oinv_rec.city,
              l_oinv_rec.postal_code,
              l_oinv_rec.state,
              l_oinv_rec.province,
              l_oinv_rec.county,
              l_oinv_rec.po_box_number,
              l_oinv_rec.house_number,
              l_oinv_rec.street_suffix,
              l_oinv_rec.apartment_number,
              l_oinv_rec.street,
              l_oinv_rec.rural_route_number,
              l_oinv_rec.street_number,
              l_oinv_rec.building,
              l_oinv_rec.floor,
              l_oinv_rec.suite,
              l_oinv_rec.room,
              l_oinv_rec.postal_plus4_code,
              l_oinv_rec.cas_id,
              l_oinv_rec.case_number,
              l_oinv_rec.khr_id,
              l_oinv_rec.contract_number,
              l_oinv_rec.contract_type,
              l_oinv_rec.contract_status,
              l_oinv_rec.original_amount,
              l_oinv_rec.start_date,
              l_oinv_rec.close_date,
              l_oinv_rec.term_duration,
              l_oinv_rec.monthly_payment_amount,
              l_oinv_rec.last_payment_date,
              l_oinv_rec.delinquency_occurance_date,
              l_oinv_rec.past_due_amount,
              l_oinv_rec.remaining_amount,
              l_oinv_rec.credit_indicator,
              l_oinv_rec.notification_date,
              l_oinv_rec.credit_bureau_report_date,
              l_oinv_rec.contact_id,
              l_oinv_rec.contact_name,
              l_oinv_rec.contact_phone,
              l_oinv_rec.contact_email,
              l_oinv_rec.object_version_number,
              l_oinv_rec.org_id,
              l_oinv_rec.request_id,
              l_oinv_rec.program_application_id,
              l_oinv_rec.program_id,
              l_oinv_rec.program_update_date,
              l_oinv_rec.attribute_category,
              l_oinv_rec.attribute1,
              l_oinv_rec.attribute2,
              l_oinv_rec.attribute3,
              l_oinv_rec.attribute4,
              l_oinv_rec.attribute5,
              l_oinv_rec.attribute6,
              l_oinv_rec.attribute7,
              l_oinv_rec.attribute8,
              l_oinv_rec.attribute9,
              l_oinv_rec.attribute10,
              l_oinv_rec.attribute11,
              l_oinv_rec.attribute12,
              l_oinv_rec.attribute13,
              l_oinv_rec.attribute14,
              l_oinv_rec.attribute15,
              l_oinv_rec.created_by,
              l_oinv_rec.creation_date,
              l_oinv_rec.last_updated_by,
              l_oinv_rec.last_update_date,
              l_oinv_rec.last_update_login,
              l_iohv_rec.id,
              l_iohv_rec.object1_id1,
              l_iohv_rec.object1_id2,
              l_iohv_rec.jtot_object1_code,
              l_iohv_rec.action,
              l_iohv_rec.status,
              l_iohv_rec.comments,
              l_iohv_rec.request_date,
              l_iohv_rec.process_date,
              l_iohv_rec.ext_agncy_id,
              l_iohv_rec.review_date,
              l_iohv_rec.recall_date;
    EXIT WHEN l_oin_pend_csr%NOTFOUND;
    --dbms_output.put_line('Processing krd_id : ' || l_oinv_rec.khr_id);
    okl_open_interface_pub.process_pending_int(p_api_version => l_api_version
                       ,p_init_msg_list => l_init_msg_list
                       ,p_oinv_rec => l_oinv_rec
                       ,p_iohv_rec => l_iohv_rec
                       ,x_oinv_rec => lx_oinv_rec
                       ,x_return_status => l_return_status
                       ,x_msg_count => lx_msg_count
                       ,x_msg_data => lx_msg_data);

    process_pending_hst(p_api_version => l_api_version
                       ,p_init_msg_list => l_init_msg_list
                       ,p_oinv_rec => lx_oinv_rec
                       ,p_iohv_rec => l_iohv_rec
                       ,x_iohv_rec => lx_iohv_rec
                       ,x_return_status => l_return_status
                       ,x_msg_count => lx_msg_count
                       ,x_msg_data => lx_msg_data);

    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      l_rows_failed := l_rows_failed + 1;
    ELSE
      l_rows_processed := l_rows_processed + 1;
    END IF;
    END LOOP;
    CLOSE l_oin_pend_csr;

    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'ROWS PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'ROWS NOT PROCESSED          = ' || l_rows_failed);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_oin_pend_csr%ISOPEN THEN
        CLOSE l_oin_pend_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
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

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'complete_report_cb';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;

     l_reportCB_process_found  BOOLEAN := FALSE;

     CURSOR l_khr_csr(cp_interface_id IN NUMBER) IS
     SELECT oin.khr_id
           ,oin.org_id
           ,ioh.id
           ,ioh.object1_id1
           ,ioh.object1_id2
           ,ioh.jtot_object1_code
     FROM okl_open_int oin
         ,iex_open_int_hst ioh
     WHERE oin.id = cp_interface_id
     AND oin.khr_id = TO_NUMBER(ioh.object1_id1)
     AND ioh.jtot_object1_code = 'OKX_LEASE'
     AND ioh.action = ACTION_REPORT_CB
     AND ioh.status = STATUS_PROCESSED;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_oinv_rec.id := p_interface_id;

    FOR cur IN l_khr_csr(p_interface_id) LOOP
      l_iohv_rec.object1_id1 := cur.object1_id1;
      l_iohv_rec.object1_id2 := cur.object1_id2;
      l_iohv_rec.jtot_object1_code := cur.jtot_object1_code;
      l_iohv_rec.org_id := cur.org_id;
      l_reportCB_process_found := TRUE;
      --dbms_output.put_line('inside loop - ' || l_oihv_rec.khr_id);
      EXIT;
    END LOOP;

    IF (l_reportCB_process_found) THEN
      l_oinv_rec.id := p_interface_id;
      l_oinv_rec.credit_bureau_report_date := p_report_date;

      l_iohv_rec.request_date := p_report_date;
      l_iohv_rec.process_date := p_report_date;
      l_iohv_rec.comments := p_comments;

      IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
        l_iohv_rec.comments := NULL;
      END IF;

      l_iohv_rec.action := ACTION_REPORT_CB;
      l_iohv_rec.status := STATUS_COMPLETE;

      okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      iex_open_int_hst_pub.insert_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;
    ELSE
       OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_INVALID_ACTION_STATUS);
       l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;
    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END complete_report_cb;

  ---------------------------------------------------------------------------
  -- PROCEDURE complete_notify
  ---------------------------------------------------------------------------
  PROCEDURE complete_notify(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_hst_id                   IN NUMBER,
     p_notification_date        IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'complete_notify';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    get_hst_info(p_hst_id => p_hst_id
                ,x_action => l_action
                ,x_status => l_status
                ,x_return_status => l_return_status);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_INVALID_ACTION_STATUS);
    END IF;

    IF ((l_action = ACTION_NOTIFY_CUST) AND
        (l_status = STATUS_PROCESSED)) THEN
      l_oinv_rec.id := p_interface_id;
      l_oinv_rec.notification_date := p_notification_date;

      l_iohv_rec.id := p_hst_id;
      l_iohv_rec.comments := p_comments;

      IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
        l_iohv_rec.comments := NULL;
      END IF;

      l_iohv_rec.status := STATUS_COMPLETE;
      l_iohv_rec.process_date := p_notification_date;

      okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;
     ELSE
       OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_INVALID_ACTION_STATUS);
       l_return_status := okl_api.G_RET_STS_ERROR;
     END IF;
    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END complete_notify;

  ---------------------------------------------------------------------------
  -- PROCEDURE complete_transfer
  ---------------------------------------------------------------------------
  PROCEDURE complete_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_transfer_date            IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'complete_transfer';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;

     l_transfer_process_found  BOOLEAN := FALSE;

     CURSOR l_khr_csr(cp_interface_id IN NUMBER) IS
     SELECT oin.khr_id
           ,oin.org_id
           ,ioh.id
           ,ioh.object1_id1
           ,ioh.object1_id2
           ,ioh.jtot_object1_code
     FROM okl_open_int oin
         ,iex_open_int_hst ioh
     WHERE oin.id = cp_interface_id
     AND oin.khr_id = TO_NUMBER(ioh.object1_id1)
     AND ioh.jtot_object1_code = 'OKX_LEASE'
     AND ioh.action = ACTION_TRANSFER_EXT_AGNCY
     AND ioh.status = STATUS_PROCESSED;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_oinv_rec.id := p_interface_id;

    FOR cur IN l_khr_csr(p_interface_id) LOOP
      l_iohv_rec.object1_id1 := cur.object1_id1;
      l_iohv_rec.object1_id2 := cur.object1_id2;
      l_iohv_rec.jtot_object1_code := cur.jtot_object1_code;
      l_iohv_rec.org_id := cur.org_id;
      l_transfer_process_found := TRUE;
      --dbms_output.put_line('inside loop - ' || l_oihv_rec.khr_id);
      EXIT;
    END LOOP;

    IF (l_transfer_process_found) THEN
      l_oinv_rec.id := p_interface_id;
      l_oinv_rec.external_agency_transfer_date := p_transfer_date;

      l_iohv_rec.request_date := p_transfer_date;
      l_iohv_rec.process_date := p_transfer_date;
      l_iohv_rec.comments := p_comments;

      IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
        l_iohv_rec.comments := NULL;
      END IF;

      l_iohv_rec.action := ACTION_TRANSFER_EXT_AGNCY;
      l_iohv_rec.status := STATUS_COMPLETE;
      --l_iohv_rec.transfer_days := null;
      --l_iohv_rec.extend_days := null;


      okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      iex_open_int_hst_pub.insert_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;
    ELSE
       OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_INVALID_ACTION_STATUS);
       l_return_status := okl_api.G_RET_STS_ERROR;
    END IF;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END complete_transfer;

  ---------------------------------------------------------------------------
  -- PROCEDURE complete_notify_ext_agncy
  ---------------------------------------------------------------------------
  PROCEDURE complete_notify_ext_agncy(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_hst_id                   IN NUMBER,
     p_notification_date        IN DATE,
     p_comments                 IN VARCHAR2 ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'complete_notify_ext_agncy';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    get_hst_info(p_hst_id => p_hst_id
                ,x_action => l_action
                ,x_status => l_status
                ,x_return_status => l_return_status);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_INVALID_ACTION_STATUS);
    END IF;

    IF ((l_action = ACTION_NOTIFY_EXT_AGNCY) AND
        (l_status = STATUS_PROCESSED)) THEN
      /*
      l_oinv_rec.id := p_interface_id;
      l_oinv_rec.notification_date := p_notification_date;
      */

      l_iohv_rec.id := p_hst_id;
      l_iohv_rec.comments := p_comments;

      IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
        l_iohv_rec.comments := NULL;
      END IF;

      l_iohv_rec.status := STATUS_COMPLETE;
      l_iohv_rec.process_date := p_notification_date;

      /*
      okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;
      */

      iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;
     ELSE
       OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                           ,p_msg_name     => G_INVALID_ACTION_STATUS);
       l_return_status := okl_api.G_RET_STS_ERROR;
     END IF;
    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END complete_notify_ext_agncy;

  ---------------------------------------------------------------------------
  -- PROCEDURE recall_transfer
  ---------------------------------------------------------------------------
  PROCEDURE recall_transfer(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_interface_id             IN NUMBER,
     p_recall_date              IN DATE,
     p_comments                 IN VARCHAR2 ,
     p_ext_agncy_id             IN NUMBER ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'recall_transfer';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_iohv_rec                 iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;
     lp_iohv_rec                iohv_rec_type;

     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;
     l_ext_agncy_id             IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;

     CURSOR l_khr_csr(cp_interface_id IN NUMBER) IS
     SELECT oin.khr_id
           ,oin.org_id
           ,oin.referral_number
           ,ioh.id
           ,ioh.object1_id1
           ,ioh.object1_id2
           ,ioh.jtot_object1_code
           ,ioh.ext_agncy_id
     FROM okl_open_int oin
         ,iex_open_int_hst ioh
     WHERE oin.id = cp_interface_id
     AND oin.khr_id = TO_NUMBER(ioh.object1_id1)
     AND ioh.jtot_object1_code = 'OKX_LEASE'
     AND ioh.action = ACTION_TRANSFER_EXT_AGNCY
     AND (ioh.status = STATUS_PROCESSED
          OR ioh.status = STATUS_NOTIFIED);
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_oinv_rec.id := p_interface_id;
    l_oinv_rec.external_agency_recall_date := p_recall_date;

    FOR cur_khr_csr IN l_khr_csr(p_interface_id) LOOP
      l_oinv_rec.referral_number := cur_khr_csr.referral_number;
      l_iohv_rec.id := cur_khr_csr.id;
      l_iohv_rec.object1_id1 := cur_khr_csr.object1_id1;
      l_iohv_rec.object1_id2 := cur_khr_csr.object1_id2;
      l_iohv_rec.jtot_object1_code := cur_khr_csr.jtot_object1_code;
      EXIT;
    END LOOP;
    l_iohv_rec.comments := p_comments;

    IF l_iohv_rec.comments = OKC_API.G_MISS_CHAR THEN
      l_iohv_rec.comments := NULL;
    END IF;

    l_iohv_rec.status := STATUS_RECALLED;
    l_iohv_rec.process_date := p_recall_date;

    l_oinv_rec.referral_number := nvl(l_oinv_rec.referral_number, 0) + 1;
    okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    IF (p_ext_agncy_id = OKC_API.G_MISS_NUM) THEN
      l_ext_agncy_id := NULL;
    ELSE
      l_ext_agncy_id := p_ext_agncy_id;
    END IF;

    iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    l_iohv_rec := lx_iohv_rec;

    lp_iohv_rec := l_iohv_rec;
    lp_iohv_rec.id := null;
    lp_iohv_rec.action := ACTION_NOTIFY_RECALL;
    lp_iohv_rec.status := STATUS_PROCESSED;
    lp_iohv_rec.request_date := SYSDATE;
    lp_iohv_rec.process_date := SYSDATE;
    lp_iohv_rec.review_date := NULL;
    lp_iohv_rec.recall_date := NULL;
    lp_iohv_rec.automatic_recall_flag := NULL;
    lp_iohv_rec.review_before_recall_flag := NULL;

    iex_open_int_hst_pub.insert_open_int_hst(
            p_api_version => l_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data  => lx_msg_data,
            p_iohv_rec => lp_iohv_rec,
            x_iohv_rec => lx_iohv_rec);

/*
    iex_open_interface_pub.insert_pending(
          p_api_version => l_api_version,
          p_init_msg_list => l_init_msg_list,
          p_object1_id1 => l_iohv_rec.object1_id1,
          p_object1_id2 => l_iohv_rec.object1_id2,
          p_jtot_object1_code => l_iohv_rec.jtot_object1_code,
          p_action => ACTION_NOTIFY_EXT_AGNCY,
          p_status => STATUS_PROCESSED,
          p_comments => p_comments,
          p_ext_agncy_id => l_iohv_rec.ext_agncy_id,
          p_review_date => NULL,
          p_recall_date => NULL,
          p_automatic_recall_flag => NULL,
          p_review_before_recall_flag => NULL,
          x_return_status => l_return_status,
          x_msg_count => lx_msg_count,
          x_msg_data => lx_msg_data);

    l_iohv_rec := lx_iohv_rec;
    l_iohv_rec.process_date := SYSDATE;

    iex_open_int_hst_pub.update_open_int_hst(
          p_api_version => l_api_version,
          p_init_msg_list => l_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count => lx_msg_count,
          x_msg_data  => lx_msg_data,
          p_iohv_rec => l_iohv_rec,
          x_iohv_rec => lx_iohv_rec);
*/

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
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

     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'review_transfer';

     l_recall                   VARCHAR2(1) := Okc_Api.G_FALSE;
     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lp_iohv_rec                iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;
     l_task_name                JTF_TASKS_VL.TASK_NAME%TYPE;
     l_description              JTF_TASKS_VL.DESCRIPTION%TYPE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
      l_recall := OKC_API.G_FALSE;

      l_oinv_rec := p_oinv_rec;
      l_iohv_rec := p_iohv_rec;
      --check whether contract is to be recalled
      get_contract_recall(p_oinv_rec => l_oinv_rec,
                          p_iohv_rec => l_iohv_rec,
                          x_recall => l_recall,
                          x_return_status => l_return_status);

      IF (l_recall = OKC_API.G_TRUE) THEN
        l_iohv_rec.status := STATUS_NOTIFIED;
        l_iohv_rec.process_date := SYSDATE;
        --l_iohv_rec.comments := p_comments;

        iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => l_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => lx_msg_count
                            ,x_msg_data => lx_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);

         x_oinv_rec := lx_oinv_rec;
         x_iohv_rec := lx_iohv_rec;
         l_iohv_rec := lx_iohv_rec;

         lp_iohv_rec := l_iohv_rec;
         lp_iohv_rec.id := null;
         lp_iohv_rec.action := ACTION_RECALL_NOTICE;
         lp_iohv_rec.status := STATUS_PROCESSED;
         lp_iohv_rec.request_date := SYSDATE;
         lp_iohv_rec.process_date := SYSDATE;
         lp_iohv_rec.review_date := NULL;
         --lp_iohv_rec.recall_date := NULL;
         lp_iohv_rec.automatic_recall_flag := NULL;
         lp_iohv_rec.review_before_recall_flag := NULL;

         iex_open_int_hst_pub.insert_open_int_hst(
            p_api_version => l_api_version,
            p_init_msg_list => l_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data  => lx_msg_data,
            p_iohv_rec => lp_iohv_rec,
            x_iohv_rec => lx_iohv_rec);

        l_task_name   := 'Oracle Collections Review Transfer to External Agency';
        l_description := 'Oracle Collections Review contract before recalling from external agency to which it is transferred.';
        create_followup(p_api_version => l_api_version,
                      p_init_msg_list => l_init_msg_list,
                      p_oinv_rec => l_oinv_rec,
                      p_iohv_rec => l_iohv_rec,
                      p_task_name => l_task_name,
                      p_description => l_description,
                      x_return_status => l_return_status,
                      x_msg_count => lx_msg_count,
                      x_msg_data => lx_msg_data);
      END IF;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END review_transfer;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_followup
  ---------------------------------------------------------------------------
  PROCEDURE create_followup(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     p_task_name                IN VARCHAR2,
     p_description              IN VARCHAR2,
     p_start_date               IN DATE ,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_followup';

     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(32767);

     l_task_id               NUMBER;
     l_task_name             varchar2(80) ;
     l_task_type_id          NUMBER ;
     l_task_type             varchar2(30) ;
     l_task_status_id        NUMBER ;
     l_task_status           varchar2(30) ;
     l_description           varchar2(4000);
     l_task_priority_name    varchar2(30) ;
     l_task_priority_id      number;
     l_owner_id              number;
     l_owner                 varchar2(4000);
     l_owner_type_code       varchar2(4000);
     l_customer_id           number;
     l_address_id            number;
     l_start_date            date;

     l_contract_id      OKL_OPEN_INT.KHR_ID%TYPE;
     l_contract_number  OKL_OPEN_INT.CONTRACT_NUMBER%TYPE;

     v_miss_task_assign_tbl     Jtf_Tasks_Pub.TASK_ASSIGN_TBL;
     v_miss_task_depends_tbl    Jtf_Tasks_Pub.TASK_DEPENDS_TBL;
     v_miss_task_rsrc_req_tbl   Jtf_Tasks_Pub.TASK_RSRC_REQ_TBL;
     v_miss_task_refer_tbl      Jtf_Tasks_Pub.TASK_REFER_TBL;
     v_miss_task_dates_tbl      Jtf_Tasks_Pub.TASK_DATES_TBL;
     v_miss_task_notes_tbl      Jtf_Tasks_Pub.TASK_NOTES_TBL;
     v_miss_task_recur_rec      Jtf_Tasks_Pub.TASK_RECUR_REC;
     v_miss_task_contacts_tbl   Jtf_Tasks_Pub.TASK_CONTACTS_TBL;

     CURSOR l_oin_csr(cp_contract_id IN NUMBER) IS
     SELECT contract_number
     ,party_id
     FROM OKL_OPEN_INT
     WHERE khr_id = cp_contract_id;

     CURSOR l_task_type_csr IS
     SELECT TASK_TYPE_ID,
            NAME
     FROM JTF_TASK_TYPES_VL
     WHERE NAME = 'Follow up action';

     CURSOR l_task_status_csr IS
     SELECT TASK.task_status_id,
           TASK.name
     FROM  jtf_task_statuses_vl TASK
     WHERE TRUNC(SYSDATE)
     BETWEEN TRUNC(NVL(TASK.start_date_active, SYSDATE))
     AND TRUNC(NVL(TASK.end_date_active, SYSDATE))
     AND TASK.name = 'Open';

     CURSOR l_case_owner_csr(cp_case_id IN NUMBER) IS
     SELECT owner_resource_id
     FROM iex_cases_all_b
     WHERE cas_id = cp_case_id;

     CURSOR l_task_priority_csr IS
     SELECT task_priority_id,
     name
     FROM jtf_task_priorities_vl
     WHERE TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
     AND TRUNC(NVL(end_date_active, SYSDATE))
     AND name = 'High';

  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts

    --get the contract number, customer_id
    l_contract_id := p_oinv_rec.khr_id;
    OPEN  l_oin_csr(l_contract_id);
    FETCH l_oin_csr INTO  l_contract_number, l_customer_id;
    CLOSE l_oin_csr;

    --get the task type name, task type id
    OPEN l_task_type_csr;
    FETCH l_task_type_csr INTO l_task_type_id, l_task_type;
    CLOSE l_task_type_csr;

    --get task status id, task status name
    OPEN l_task_status_csr;
    FETCH l_task_status_csr INTO l_task_status_id, l_task_status;
    CLOSE l_task_status_csr;

    --get task priority id, task priority name
    OPEN l_task_priority_csr;
    FETCH l_task_priority_csr INTO l_task_priority_id, l_task_priority_name;
    CLOSE l_task_priority_csr;

    --l_task_name   := 'Oracle Collections Review Transfer to External Agency';
    l_task_name := p_task_name;
    l_task_status := 'Open';
    l_task_type   := 'Follow up action';
    --l_description := 'Oracle Collections Review contract before recalling from external agency to which it is transferred.';
    l_description := p_description;
    l_owner_type_code := 'RS_EMPLOYEE';
    l_start_date := p_start_date;

    --Use the foll query to get an employee resource
    --select resource_id, first_name, last_name from jtf_rs_emp_dtls_vl to test
    --Right now it is hard coded
    --set the value to the case owner resource id
    OPEN l_case_owner_csr(p_oinv_rec.cas_id);
    FETCH l_case_owner_csr INTO l_owner_id;
    CLOSE l_case_owner_csr;

    --l_owner_id := 100000803;

    Jtf_Tasks_Pub.CREATE_TASK(
                              P_API_VERSION            => p_api_version,
                              P_INIT_MSG_LIST          => Okc_Api.g_true,
                              P_COMMIT                 => Okc_Api.g_true,
                              P_TASK_ID                => NULL,
                              P_TASK_NAME              => l_task_name,
                              P_TASK_TYPE_NAME         => l_task_type,
                              P_TASK_TYPE_ID           => l_task_type_id,
                              P_DESCRIPTION            => l_description,
                              P_TASK_STATUS_NAME       => l_task_status,
                              P_TASK_STATUS_ID         => l_task_status_id,
                              P_TASK_PRIORITY_NAME     => l_task_priority_name,
                              P_TASK_PRIORITY_ID       => l_task_priority_id,
                              p_owner_type_name        => Null,
                              P_OWNER_TYPE_CODE        => l_owner_type_code,
                              P_OWNER_ID               => l_owner_id,
                              P_OWNER_TERRITORY_ID     => NULL,
                              p_assigned_by_name       => NULL,
                              P_ASSIGNED_BY_ID         => NULL,
                              p_customer_number        => NULL,
                              P_CUSTOMER_ID            => l_customer_id,
                              p_cust_account_number    => NULL,
                              P_CUST_ACCOUNT_ID        => NULL,
                              P_ADDRESS_ID             => NULL,
                              p_address_number         => NULL,
                              P_PLANNED_START_DATE     => l_start_date,
                              P_PLANNED_END_DATE       => NULL,
                              P_SCHEDULED_START_DATE   => NULL,
                              P_SCHEDULED_END_DATE     => NULL,
                              P_ACTUAL_START_DATE      => NULL,
                              P_ACTUAL_END_DATE        => NULL,
                              P_TIMEZONE_ID            => NULL,
                              p_timezone_name          => NULL,
                              P_SOURCE_OBJECT_TYPE_CODE => 'IEX_K_HEADER',
                              P_SOURCE_OBJECT_ID        => l_contract_id,
                              P_SOURCE_OBJECT_NAME      => l_contract_number,
                              P_DURATION                => NULL,
                              P_DURATION_UOM            => NULL,
                              P_PLANNED_EFFORT          => NULL,
                              P_PLANNED_EFFORT_UOM      => NULL,
                              P_ACTUAL_EFFORT           => NULL,
                              P_ACTUAL_EFFORT_UOM       => NULL,
                              P_PERCENTAGE_COMPLETE     => NULL,
                              P_REASON_CODE             => NULL,
                              P_PRIVATE_FLAG            => NULL,
                              P_PUBLISH_FLAG            => NULL,
                              P_RESTRICT_CLOSURE_FLAG   => NULL,
                              P_MULTI_BOOKED_FLAG       => NULL,
                              P_MILESTONE_FLAG          => NULL,
                              P_HOLIDAY_FLAG            => NULL,
                              P_BILLABLE_FLAG           => NULL,
                              P_BOUND_MODE_CODE         => NULL,
                              P_SOFT_BOUND_FLAG         => NULL,
                              P_WORKFLOW_PROCESS_ID     => Null,
                              P_NOTIFICATION_FLAG       => NULL,
                              P_NOTIFICATION_PERIOD     => NULL,
                              P_NOTIFICATION_PERIOD_UOM => NULL,
                              p_parent_task_number      => NULL,
                              P_PARENT_TASK_ID          => NULL,
                              P_ALARM_START             => NULL,
                              P_ALARM_START_UOM         => NULL,
                              P_ALARM_ON                => NULL,
                              P_ALARM_COUNT             => NULL,
                              P_ALARM_INTERVAL          => NULL,
                              P_ALARM_INTERVAL_UOM      => NULL,
                              P_PALM_FLAG               => NULL,
                              P_WINCE_FLAG              => NULL,
                              P_LAPTOP_FLAG             => NULL,
                              P_DEVICE1_FLAG            => NULL,
                              P_DEVICE2_FLAG            => NULL,
                              P_DEVICE3_FLAG            => NULL,
                              P_COSTS                   => NULL,
                              P_CURRENCY_CODE           => NULL,
                              P_ESCALATION_LEVEL        => NULL,
                              p_task_assign_tbl        => v_miss_task_assign_tbl,
                              p_task_depends_tbl       => v_miss_task_depends_tbl,
                              p_task_rsrc_req_tbl      => v_miss_task_rsrc_req_tbl,
                              p_task_refer_tbl         => v_miss_task_refer_tbl,
                              p_task_dates_tbl         => v_miss_task_dates_tbl,
                              p_task_notes_tbl         => v_miss_task_notes_tbl,
                              p_task_recur_rec         => v_miss_task_recur_rec,
                              p_task_contacts_tbl      => v_miss_task_contacts_tbl,
                              x_return_status          => x_return_status,
                              x_msg_count              => x_msg_count,
                              x_msg_data               => x_msg_data,
                              x_task_id                => l_task_id,
                              P_ATTRIBUTE1             => NULL,
                              P_ATTRIBUTE2             => NULL,
                              P_ATTRIBUTE3             => NULL,
                              P_ATTRIBUTE4             => NULL,
                              P_ATTRIBUTE5             => NULL,
                              P_ATTRIBUTE6             => NULL,
                              P_ATTRIBUTE7             => NULL,
                              P_ATTRIBUTE8             => NULL,
                              P_ATTRIBUTE9             => NULL,
                              P_ATTRIBUTE10            => NULL,
                              P_ATTRIBUTE11            => NULL,
                              P_ATTRIBUTE12            => NULL,
                              P_ATTRIBUTE13            => NULL,
                              P_ATTRIBUTE14            => NULL,
                              P_ATTRIBUTE15            => NULL,
                              P_ATTRIBUTE_CATEGORY     => NULL );


    --Begin bug#5246309 schekuri 29-Jun-2006
    --Added log message when failed.
    IF x_return_status<>fnd_api.g_ret_sts_success THEN
       IF l_owner_id IS NULL THEN
          fnd_file.put_line(FND_FILE.LOG, ' Task creation failed due to invalid owner for contract '||l_contract_number);
       ELSE
	  fnd_file.put_line(FND_FILE.LOG, ' Task creation failed for contract '||l_contract_number);
       END IF;
    END IF;
    --End bug#5246309 schekuri 29-Jun-2006

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(G_APP_NAME, G_TASK_CREATION_FAILURE);
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(G_APP_NAME, G_TASK_CREATION_FAILURE);
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_followup;

  ---------------------------------------------------------------------------
  -- PROCEDURE notify_customer
  ---------------------------------------------------------------------------
  PROCEDURE notify_customer(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_party_id                 IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2) AS

     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_name                 CONSTANT VARCHAR2(30) := 'notify_customer';
     l_rows_processed           NUMBER := 0;
     l_rows_failed              NUMBER := 0;
     l_cust_notified            NUMBER := 0;
     l_cust_not_notified        NUMBER := 0;

     /*
     l_bind_var                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     l_bind_val                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     l_bind_var_type            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     */

     l_bind_tbl                 IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL;

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;

     l_case_number              OKL_OPEN_INT.CASE_NUMBER%TYPE;
     l_contract_id              OKL_OPEN_INT.KHR_ID%TYPE;
     l_party_id                 HZ_PARTIES.PARTY_ID%TYPE;
     l_email                    HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
     l_subject                  VARCHAR2(2000);
     l_content_id               JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
     l_from                     VARCHAR2(2000);
     l_agent_id                 NUMBER;
     l_request_id               NUMBER;
     l_task_name                JTF_TASKS_VL.TASK_NAME%TYPE;
     l_description              JTF_TASKS_VL.DESCRIPTION%TYPE;
     l_start_date               Date;

     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;
     l_party_passed             VARCHAR2(1) := Okc_Api.G_TRUE;
     l_case_passed              VARCHAR2(1) := Okc_Api.G_TRUE;

     CURSOR l_notify_csr(cp_case_number IN VARCHAR2
                        ,cp_party_id IN NUMBER
                        ,cp_organization_id IN NUMBER) IS
     SELECT OIN.ID,
            OIN.KHR_ID,
            OIN.CAS_ID,
            OIN.PARTY_ID,
            OIN.PARTY_NAME,
            IOH.ID
     FROM Okl_Open_Int OIN
          ,Iex_Open_Int_Hst IOH
     WHERE OIN.khr_id = TO_NUMBER(IOH.object1_id1)
     AND   IOH.jtot_object1_code = 'OKX_LEASE'
     AND   (IOH.ACTION = ACTION_NOTIFY_CUST)
     AND   (IOH.STATUS = STATUS_PROCESSED)
     AND   ((l_case_passed = Okc_Api.G_FALSE) OR
            (l_case_passed = Okc_Api.G_TRUE AND OIN.case_number = cp_case_number))
     AND   ((l_party_passed = Okc_Api.G_FALSE) OR
            (l_party_passed = Okc_Api.G_TRUE AND OIN.party_id = cp_party_id))
     AND   (OIN.org_id = cp_organization_id);
    l_contact_destination         varchar2(240);  -- bug 3955222
    l_contact_party_id            number; -- bug 3955222
  BEGIN
    --check to see that contract id is passed when email is passed
    IF NOT (p_email = OKC_API.G_MISS_CHAR OR p_email IS NULL) THEN
      IF (p_case_number = OKC_API.G_MISS_CHAR OR p_case_number IS NULL) THEN
        RAISE G_INVALID_PARAMETERS;
      END IF;
    END IF;

    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006

    /*
    l_organization_id := okl_context.get_okc_org_id;
    --dbms_output.put_line('org is : ' || l_organization_id);

    --check if organization_id is null, set it from the profile
    IF (l_organization_id IS NULL) THEN
      --dbms_output.put_line('org is not set');
      okl_context.set_okc_org_context(null,null);
      --dbms_output.put_line('org is now set');
      l_organization_id := okl_context.get_okc_org_id;
      --dbms_output.put_line('org is : ' || l_organization_id);
    END IF;
    */

    --check if  case nbr is passed
    IF (p_case_number = OKC_API.G_MISS_CHAR OR
        p_case_number IS NULL) THEN
        l_case_passed := Okc_Api.G_FALSE;
    END IF;

    --check if party_id is passed
    IF (p_party_id = OKC_API.G_MISS_NUM OR
        p_party_id IS NULL) THEN
        l_party_passed := Okc_Api.G_FALSE;
    END IF;

    l_subject := p_subject;
    l_content_id := p_content_id;
    l_agent_id := NVL(p_agent_id, FND_GLOBAL.USER_ID);
    l_from := p_from;

    --if suject is null get subject
    IF (l_subject = OKC_API.G_MISS_CHAR OR
        l_subject IS NULL) THEN
    	l_subject := fnd_profile.value('IEX_CB_NOTIFY_CUST_EMAIL_SUBJECT');
    END IF;
    --dbms_output.put_line('l_subject : ' || l_subject);

    --if content_id is null get content_id
    IF (l_content_id = OKC_API.G_MISS_NUM OR
        l_content_id IS NULL) THEN
    	l_content_id := to_number(fnd_profile.value('IEX_CB_NOTIFY_CUST_TEMPLATE'));
    END IF;
    --dbms_output.put_line('l_content_id : ' || l_content_id);

    --if from is null get subject
    IF (l_from = OKC_API.G_MISS_CHAR OR
        l_from IS NULL) THEN
    	l_from := fnd_profile.value('IEX_CB_NOTIFY_CUST_EMAIL_FROM');
    END IF;
    --dbms_output.put_line('l_from : ' || l_from);


    OPEN l_notify_csr(p_case_number
                     ,p_party_id
                     ,l_organization_id);
    LOOP
      FETCH l_notify_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.khr_id,
              l_oinv_rec.cas_id,
              l_oinv_rec.party_id,
              l_oinv_rec.party_name,
              l_iohv_rec.id;
      EXIT WHEN l_notify_csr%NOTFOUND;

      l_party_id := l_oinv_rec.party_id;
      l_contract_id := l_oinv_rec.khr_id;
      l_email := p_email;

      IF ((l_email = OKC_API.G_MISS_CHAR) OR (l_email IS NULL)) THEN
        get_party_email(p_party_id => l_oinv_rec.party_id
                       ,x_email => l_email
                       ,x_return_status => l_return_status);
      END IF;

      IF NOT ((l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) OR
              (l_return_status = okl_api.G_RET_STS_ERROR)       OR
              (l_email = OKC_API.G_MISS_CHAR) OR (l_email IS NULL)) THEN
        l_cust_notified := l_cust_notified + 1;

        /*
        l_bind_var(1) := 'p_contract_id';
        l_bind_val(1) := l_contract_id;
        l_bind_var_type(1) := 'NUMBER';
        */
        l_bind_tbl(1).KEY_NAME := 'p_contract_id';
        l_bind_tbl(1).KEY_TYPE := 'NUMBER';
        l_bind_tbl(1).KEY_VALUE := l_contract_id;

        --call fulfillment
        /*
        OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_agent_id => l_agent_id,
                              p_content_id => l_content_id,
                              p_from => l_from,
                              p_subject => l_subject,
                              p_email => l_email,
                              p_bind_var => l_bind_var,
                              p_bind_val => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              p_commit => okl_api.G_FALSE,
                              x_request_id => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count => lx_msg_count,
                              x_msg_data => lx_msg_data);
                              */

         IEX_DUNNING_PVT.Send_Fulfillment(p_api_version => l_api_version,
                           p_init_msg_list => FND_API.G_TRUE,
                           p_commit => FND_API.G_TRUE,
                           p_FULFILLMENT_BIND_TBL => l_bind_tbl,
                           p_template_id => l_content_id,
                           p_method => 'EMAIL',
                           p_party_id => l_party_id,
                           p_user_id  => l_agent_id,
                           p_email => l_email,
                           x_return_status => l_return_status,
                           x_msg_count => lx_msg_count,
                           x_msg_data => lx_msg_data,
                           x_REQUEST_ID => l_request_id
                         , x_contact_destination      => l_contact_destination  -- bug 3955222
                         , x_contact_party_id         => l_contact_party_id  -- bug 3955222
                     );
        /*
        --dbms_output.put_line('p_api_version => ' || l_api_version ||
	                              ' p_agent_id => ' || l_agent_id ||
	                              ' p_content_id => ' || l_content_id);
        --dbms_output.put_line(' p_subject => ' || l_subject ||
	                              ' p_email => ' || l_email);
	--dbms_output.put_line(' p_bind_var => ' || l_bind_var(1) ||
	                              ' p_bind_val => ' || l_bind_val(1) ||
	                              ' p_bind_var_type => ' || l_bind_var_type(1));
        --dbms_output.put_line(' party name => ' || l_oinv_rec.party_name ||
	                              ' x_return_status => ' || l_return_status);
        */

        IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          complete_notify(
	       p_api_version => l_api_version,
	       p_init_msg_list => okl_api.G_TRUE,
	       p_interface_id => l_oinv_rec.id,
	       p_hst_id => l_iohv_rec.id,
	       p_notification_date => SYSDATE,
	       p_comments => OKC_API.G_MISS_CHAR,
	       x_return_status => l_return_status,
	       x_msg_count => lx_msg_count,
	       x_msg_data => lx_msg_data);
          l_rows_processed := l_rows_processed + 1;

          l_task_name   := 'Oracle Collections Review Contract';
          l_description := 'Oracle Collections Review contract for reporting to credit bureau';
          l_start_date := sysdate + to_number(fnd_profile.value('IEX_CB_NOTIFY_GRACE_DAYS'));
          create_followup(p_api_version => l_api_version,
                      p_init_msg_list => okl_api.G_TRUE,
                      p_oinv_rec => l_oinv_rec,
                      p_iohv_rec => l_iohv_rec,
                      p_task_name => l_task_name,
                      p_description => l_description,
                      p_start_date => l_start_date,
                      x_return_status => l_return_status,
                      x_msg_count => lx_msg_count,
                      x_msg_data => lx_msg_data);
        ELSE
          FND_MESSAGE.SET_NAME('IEX', 'IEX_INVALID_FULFILLMENT_SETUP');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET );
          l_rows_failed := l_rows_failed + 1;
        END IF;
      ELSE
        l_cust_not_notified := l_cust_not_notified + 1;
        --dbms_output.put_line('do not report - ' || l_oinv_rec.id);
      END IF;
    END LOOP;

    --dbms_output.PUT_LINE('CUSTOMERS NOTIFIED                              = ' || l_cust_notified);
    --dbms_output.PUT_LINE('CUSTOMERS NOT NOTIFIED                          = ' || l_cust_not_notified);
    --dbms_output.PUT_LINE('CUSTOMERS TO BE NOTIFIED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    --dbms_output.PUT_LINE('CUSTOMERS TO BE NOTIFIED NOT PROCESSED          = ' || l_rows_failed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS NOTIFIED                              = ' || l_cust_notified);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS NOT NOTIFIED                          = ' || l_cust_not_notified);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS TO BE NOTIFIED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CUSTOMERS TO BE NOTIFIED NOT PROCESSED          = ' || l_rows_failed);

    COMMIT;
  EXCEPTION
    WHEN G_INVALID_PARAMETERS THEN
      errbuf   := 'G_INVALID_PARAMETERS';
      retcode  := 1;
      FND_MESSAGE.SET_NAME('IEX', 'IEX_MISSING_EMAIL_CASE');
      --dbms_output.put_line(FND_MESSAGE.GET);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET );
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF l_notify_csr%ISOPEN THEN
        CLOSE l_notify_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END notify_customer;

  ---------------------------------------------------------------------------
  -- PROCEDURE notify_recall_external_agency
  ---------------------------------------------------------------------------
  PROCEDURE notify_recall_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2) AS

     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_recall                   VARCHAR2(1) := Okc_Api.G_FALSE;
     l_delinquency_status       IEX_DEL_STATUSES.DEL_STATUS%TYPE;

     l_api_name                 CONSTANT VARCHAR2(30) := 'notify_recall_external_agency';
     l_ext_agncy_contracts_notified       NUMBER := 0;

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lp_iohv_rec                iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_case_number              OKL_OPEN_INT.CASE_NUMBER%TYPE;
     l_ext_agncy_id             IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
     --l_extend_days              IEX_OPEN_INT_HST.EXTEND_DAYS%TYPE;
     l_task_name                JTF_TASKS_VL.TASK_NAME%TYPE;
     l_description              JTF_TASKS_VL.DESCRIPTION%TYPE;

     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;
     l_case_passed              VARCHAR2(1) := Okc_Api.G_TRUE;
     l_ext_agncy_passed         VARCHAR2(1) := Okc_Api.G_TRUE;

     CURSOR l_recall_csr(cp_case_number IN VARCHAR2
                        ,cp_ext_agncy_id IN NUMBER
                        ,cp_organization_id IN NUMBER) IS
     SELECT OIN.ID,
            OIN.KHR_ID,
            OIN.CAS_ID,
            IOH.ID,
            IOH.OBJECT1_ID1,
            IOH.OBJECT1_ID2,
            IOH.JTOT_OBJECT1_CODE,
            IOH.ACTION,
            IOH.STATUS,
            IOH.REQUEST_DATE,
            IOH.PROCESS_DATE,
            IOH.EXT_AGNCY_ID,
            IOH.REVIEW_BEFORE_RECALL_FLAG
     FROM Okl_Open_Int OIN
          ,Iex_Open_Int_Hst IOH
     WHERE OIN.khr_id = TO_NUMBER(IOH.object1_id1)
     AND   IOH.jtot_object1_code = 'OKX_LEASE'
     AND   (IOH.ACTION = ACTION_TRANSFER_EXT_AGNCY)
     AND   (IOH.STATUS = STATUS_PROCESSED)
     AND   (TRUNC(IOH.REVIEW_DATE) = TRUNC(SYSDATE))
     AND   ((l_case_passed = Okc_Api.G_FALSE) OR
            (l_case_passed = Okc_Api.G_TRUE AND OIN.case_number = cp_case_number))
     AND   ((l_ext_agncy_passed = Okc_Api.G_FALSE) OR
            (l_ext_agncy_passed = Okc_Api.G_TRUE AND IOH.ext_agncy_id = cp_ext_agncy_id))
     AND   (OIN.org_id = cp_organization_id);
  BEGIN
    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006

    --check if case number is passed
    IF (p_case_number = OKC_API.G_MISS_CHAR OR
        p_case_number IS NULL) THEN
      l_case_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('contract is not passed');
    END IF;

    --check if ext_agncy_id is passed
    IF (p_ext_agncy_id = OKC_API.G_MISS_NUM OR
        p_ext_agncy_id IS NULL) THEN
      l_ext_agncy_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('ext_agncy is not passed');
    END IF;

    --l_extend_days := fnd_profile.value('IEX_EA_RECALL_GRACE_DAYS');

    OPEN l_recall_csr(p_case_number
                     ,p_ext_agncy_id
                     ,l_organization_id);
    LOOP
      FETCH l_recall_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.khr_id,
              l_oinv_rec.cas_id,
              l_iohv_rec.id,
              l_iohv_rec.object1_id1,
              l_iohv_rec.object1_id2,
              l_iohv_rec.jtot_object1_code,
              l_iohv_rec.action,
              l_iohv_rec.status,
              l_iohv_rec.request_date,
              l_iohv_rec.process_date,
              l_iohv_rec.ext_agncy_id,
              l_iohv_rec.review_before_recall_flag;

      EXIT WHEN l_recall_csr%NOTFOUND;

      l_iohv_rec.comments := p_comments;
      review_transfer(
        p_api_version => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_oinv_rec => l_oinv_rec,
        p_iohv_rec => l_iohv_rec,
        x_oinv_rec => lx_oinv_rec,
        x_iohv_rec => lx_iohv_rec,
        x_return_status => l_return_status,
        x_msg_count => lx_msg_count,
        x_msg_data => lx_msg_data);

      IF(l_return_status = fnd_api.g_ret_sts_success) THEN
        l_ext_agncy_contracts_notified := l_ext_agncy_contracts_notified + 1;
      END IF;

/*
      l_recall := OKC_API.G_FALSE;

      --check whether contract is to be recalled
      get_contract_recall(p_oinv_rec => l_oinv_rec,
                          p_iohv_rec => l_iohv_rec,
                          x_recall => l_recall,
                          x_return_status => l_return_status);

      IF (l_recall = OKC_API.G_TRUE) THEN
        l_iohv_rec.status := STATUS_NOTIFIED;
        l_iohv_rec.process_date := SYSDATE;
        l_iohv_rec.comments := p_comments;

        iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => l_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => lx_msg_count
                            ,x_msg_data => lx_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);

         l_iohv_rec := lx_iohv_rec;

         lp_iohv_rec := l_iohv_rec;
         lp_iohv_rec.id := null;
         lp_iohv_rec.action := ACTION_RECALL_NOTICE;
         lp_iohv_rec.status := STATUS_PROCESSED;
         lp_iohv_rec.request_date := SYSDATE;
         lp_iohv_rec.process_date := SYSDATE;
         lp_iohv_rec.review_date := NULL;
         --lp_iohv_rec.recall_date := NULL;
         lp_iohv_rec.automatic_recall_flag := NULL;
         lp_iohv_rec.review_before_recall_flag := NULL;

         iex_open_int_hst_pub.insert_open_int_hst(
            p_api_version => l_api_version,
            p_init_msg_list => l_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data  => lx_msg_data,
            p_iohv_rec => lp_iohv_rec,
            x_iohv_rec => lx_iohv_rec);

        l_task_name   := 'Oracle Collections Review Transfer to External Agency';
        l_description := 'Oracle Collections Review contract before recalling from external agency to which it is transferred.';
        create_followup(p_api_version => l_api_version,
                      p_init_msg_list => l_init_msg_list,
                      p_oinv_rec => l_oinv_rec,
                      p_iohv_rec => l_iohv_rec,
                      p_task_name => l_task_name,
                      p_description => l_description,
                      x_return_status => l_return_status,
                      x_msg_count => lx_msg_count,
                      x_msg_data => lx_msg_data);
        l_ext_agncy_contracts_notified := l_ext_agncy_contracts_notified + 1;
      END IF;
*/
      /*
      IF(NVL(l_iohv_rec.review_before_recall_flag, 'N') = 'Y') THEN
        l_task_name   := 'Oracle Collections Review Transfer to External Agency';
        l_description := 'Oracle Collections Review contract before recalling from external agency to which it is transferred.';
        create_followup(p_api_version => l_api_version,
                      p_init_msg_list => l_init_msg_list,
                      p_oinv_rec => l_oinv_rec,
                      p_iohv_rec => l_iohv_rec,
                      p_task_name => l_task_name,
                      p_description => l_description,
                      x_return_status => l_return_status,
                      x_msg_count => lx_msg_count,
                      x_msg_data => lx_msg_data);
      ELSE
        --check whether contract is to be recalled
        get_contract_recall(p_oinv_rec => l_oinv_rec,
                          p_iohv_rec => l_iohv_rec,
                          x_recall => l_recall,
                          x_return_status => l_return_status);

        IF (l_recall = OKC_API.G_TRUE) THEN
          l_iohv_rec.status := STATUS_NOTIFIED;
          l_iohv_rec.process_date := SYSDATE;
          l_iohv_rec.comments := p_comments;

          iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => l_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => lx_msg_count
                            ,x_msg_data => lx_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);

          --dbms_output.PUT_LINE('update status : ' || l_return_status);

          iex_open_interface_pub.insert_pending(
            p_api_version => l_api_version,
            p_init_msg_list => l_init_msg_list,
            p_object1_id1 => l_iohv_rec.object1_id1,
            p_object1_id2 => l_iohv_rec.object1_id2,
            p_jtot_object1_code => l_iohv_rec.jtot_object1_code,
            p_action => IEX_OPI_PVT.ACTION_NOTIFY_EXT_AGNCY,
            p_status => IEX_OPI_PVT.STATUS_PROCESSED,
            p_comments => p_comments,
            p_ext_agncy_id => NULL,
            p_review_date => NULL,
            p_recall_date => NULL,
            p_automatic_recall_flag => NULL,
            p_review_before_recall_flag => NULL,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data => lx_msg_data);
            --dbms_output.PUT_LINE('insert status : ' || l_return_status);

          lp_iohv_rec := lx_iohv_rec;
          lp_iohv_rec.ext_agncy_id := l_iohv_rec.ext_agncy_id;
          lp_iohv_rec.process_date := SYSDATE;

          iex_open_int_hst_pub.update_open_int_hst(
            p_api_version => l_api_version,
            p_init_msg_list => l_init_msg_list,
            x_return_status => l_return_status,
            x_msg_count => lx_msg_count,
            x_msg_data  => lx_msg_data,
            p_iohv_rec => lp_iohv_rec,
            x_iohv_rec => lx_iohv_rec);
            l_ext_agncy_contracts_notified := l_ext_agncy_contracts_notified + 1;
        ELSE
          --check delinquency status of the contract
          get_contract_delinquency_stat(p_oinv_rec => l_oinv_rec,
	                              p_iohv_rec => l_iohv_rec,
	                              x_delinquency_status => l_delinquency_status,
                                      x_return_status => l_return_status);

          IF (l_delinquency_status = CASE_STATUS_CURRENT) THEN
            l_iohv_rec.status := STATUS_COLLECTED;
            l_iohv_rec.process_date := SYSDATE;

            iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => l_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => lx_msg_count
                            ,x_msg_data => lx_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);
          ELSE
            l_iohv_rec.process_date := SYSDATE;

            iex_open_int_hst_pub.update_open_int_hst(p_api_version => l_api_version
                            ,p_init_msg_list => l_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => lx_msg_count
                            ,x_msg_data => lx_msg_data
                            ,p_iohv_rec => l_iohv_rec
                            ,x_iohv_rec => lx_iohv_rec);

          END IF;
        END IF;
      END IF;
      */
    END LOOP;

    --dbms_output.PUT_LINE('CONTRACTS NOTIFIED ABOUT RECALL                              = ' || l_ext_agncy_contracts_notified);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CONTRACTS NOTIFIED ABOUT RECALL                              = ' || l_ext_agncy_contracts_notified);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_recall_csr%ISOPEN THEN
        CLOSE l_recall_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END notify_recall_external_agency;

  ---------------------------------------------------------------------------
  -- PROCEDURE notify_external_agency
  ---------------------------------------------------------------------------
  PROCEDURE notify_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_agent_id                 IN NUMBER,
     p_content_id               IN VARCHAR2,
     p_from                     IN  VARCHAR2,
     p_subject                  IN VARCHAR2,
     p_email                    IN VARCHAR2) AS

     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     lx_message                 VARCHAR2(2000);
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_name                 CONSTANT VARCHAR2(30) := 'notify_external_agency';
     l_rows_processed           NUMBER := 0;
     l_rows_failed              NUMBER := 0;
     l_ext_agncy_notified          NUMBER := 0;
     l_ext_agncy_not_notified      NUMBER := 0;

     l_bind_var                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     l_bind_val                 JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
     l_bind_var_type            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;

     l_case_number              OKL_OPEN_INT.CASE_NUMBER%TYPE;
     l_contract_id              OKL_OPEN_INT.KHR_ID%TYPE;
     l_ext_agncy_id             IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
     l_email                    HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
     l_subject                  VARCHAR2(2000);
     l_content_id               JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
     l_from                     VARCHAR2(2000);
     l_agent_id                 NUMBER;
     l_request_id               NUMBER;

     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;
     l_ext_agncy_passed         VARCHAR2(1) := Okc_Api.G_TRUE;
     l_case_passed              VARCHAR2(1) := Okc_Api.G_TRUE;

     CURSOR l_notify_csr(cp_case_number IN VARCHAR2
                        ,cp_ext_agncy_id IN NUMBER
                        ,cp_organization_id IN NUMBER) IS
     SELECT OIN.ID,
            OIN.KHR_ID,
            IOH.ID,
            IOH.EXT_AGNCY_ID
     FROM Okl_Open_Int OIN
          ,Iex_Open_Int_Hst IOH
     WHERE OIN.khr_id = TO_NUMBER(IOH.object1_id1)
     AND   IOH.jtot_object1_code = 'OKX_LEASE'
     AND   (IOH.ACTION = ACTION_NOTIFY_EXT_AGNCY)
     AND   (IOH.STATUS = STATUS_PROCESSED)
     AND   ((l_case_passed = Okc_Api.G_FALSE) OR
            (l_case_passed = Okc_Api.G_TRUE AND OIN.case_number = cp_case_number))
     AND   ((l_ext_agncy_passed = Okc_Api.G_FALSE) OR
            (l_ext_agncy_passed = Okc_Api.G_TRUE AND IOH.ext_agncy_id = cp_ext_agncy_id))
     AND   (OIN.org_id = cp_organization_id);
  BEGIN
    --check to see that case number is passed when email is passed
    IF NOT (p_email = OKC_API.G_MISS_CHAR OR p_email IS NULL) THEN
      IF (p_case_number = OKC_API.G_MISS_CHAR OR p_case_number IS NULL) THEN
        RAISE G_INVALID_PARAMETERS;
      END IF;
    END IF;

    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006

    /*
    l_organization_id := okl_context.get_okc_org_id;
    --dbms_output.put_line('org is : ' || l_organization_id);

    --check if organization_id is null, set it from the profile
    IF (l_organization_id IS NULL) THEN
      --dbms_output.put_line('org is not set');
      okl_context.set_okc_org_context(null,null);
      --dbms_output.put_line('org is now set');
      l_organization_id := okl_context.get_okc_org_id;
      --dbms_output.put_line('org is : ' || l_organization_id);
    END IF;
    */

    --check if contract_id is passed
    IF (p_case_number = OKC_API.G_MISS_CHAR OR
        p_case_number IS NULL) THEN
      l_case_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('contract is not passed');
    END IF;

    --check if p_ext_agncy_id is passed
    IF (p_ext_agncy_id = OKC_API.G_MISS_NUM OR
        p_ext_agncy_id IS NULL) THEN
      l_ext_agncy_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('ext_agncy is not passed');
    END IF;

    l_subject := p_subject;
    l_content_id := p_content_id;
    l_agent_id := NVL(p_agent_id, FND_GLOBAL.USER_ID);
    l_from := p_from;


    --if suject is null get subject
    IF (l_subject = OKC_API.G_MISS_CHAR OR
        l_subject IS NULL) THEN
    	l_subject := fnd_profile.value('IEX_EA_NOTIFY_VENDOR_EMAIL_SUBJECT');
    END IF;
    --dbms_output.put_line('l_subject : ' || l_subject);

    --if content_id is null get content_id
    IF (l_content_id = OKC_API.G_MISS_NUM OR
        l_content_id IS NULL) THEN
    	l_content_id := to_number(fnd_profile.value('IEX_EA_NOTIFY_VENDOR_TEMPLATE'));
    END IF;
    --dbms_output.put_line('l_content_id : ' || l_content_id);

    --if from is null get subject
    IF (l_from = OKC_API.G_MISS_CHAR OR
        l_from IS NULL) THEN
    	l_from := fnd_profile.value('IEX_EA_NOTIFY_VENDOR_EMAIL_FROM');
    END IF;
    --dbms_output.put_line('l_from : ' || l_from);


    OPEN l_notify_csr(p_case_number
                     ,p_ext_agncy_id
                     ,l_organization_id);
    LOOP
      FETCH l_notify_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.khr_id,
              l_iohv_rec.id,
              l_iohv_rec.ext_agncy_id;
      EXIT WHEN l_notify_csr%NOTFOUND;

      l_ext_agncy_id := l_iohv_rec.ext_agncy_id;
      l_contract_id := l_oinv_rec.khr_id;
      l_email := p_email;

      IF ((l_email = OKC_API.G_MISS_CHAR) OR (l_email IS NULL)) THEN
        get_ext_agncy_email(p_ext_agncy_id => l_iohv_rec.ext_agncy_id
                       ,x_email => l_email
                       ,x_return_status => l_return_status);
      END IF;

      IF NOT ((l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) OR
              (l_return_status = okl_api.G_RET_STS_ERROR)       OR
              (l_email = OKC_API.G_MISS_CHAR) OR (l_email IS NULL)) THEN
        l_ext_agncy_notified := l_ext_agncy_notified + 1;

        /*
        l_bind_var(1) := 'p_contract_id';
        l_bind_val(1) := l_contract_id;
        l_bind_var_type(1) := 'NUMBER';

        --call fulfillment
        OKL_FULFILLMENT_PUB.create_fulfillment (
                              p_api_version => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_agent_id => l_agent_id,
                              p_content_id => l_content_id,
                              p_from => l_from,
                              p_subject => l_subject,
                              p_email => l_email,
                              p_bind_var => l_bind_var,
                              p_bind_val => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              p_commit => okl_api.G_FALSE,
                              x_request_id => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count => lx_msg_count,
                              x_msg_data => lx_msg_data);
        */

        /*
        --dbms_output.put_line('p_api_version => ' || l_api_version ||
	                              ' p_agent_id => ' || l_agent_id ||
	                              ' p_content_id => ' || l_content_id);
        --dbms_output.put_line(' p_subject => ' || l_subject ||
	                              ' p_email => ' || l_email);
	--dbms_output.put_line(' p_bind_var => ' || l_bind_var(1) ||
	                              ' p_bind_val => ' || l_bind_val(1) ||
	                              ' p_bind_var_type => ' || l_bind_var_type(1));
        --dbms_output.put_line(' party name => ' || l_oinv_rec.party_name ||
	                              ' x_return_status => ' || l_return_status);
        */

        IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
          complete_notify_ext_agncy(
                              p_api_version => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_interface_id => l_oinv_rec.id,
                              p_hst_id => l_iohv_rec.id,
                              p_notification_date => SYSDATE,
                              p_comments => null,
                              x_return_status => l_return_status,
                              x_msg_count => lx_msg_count,
                              x_msg_data => lx_msg_data);

          l_rows_processed := l_rows_processed + 1;
        ELSE
          FND_MESSAGE.SET_NAME('IEX', 'IEX_INVALID_FULFILLMENT_SETUP');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET );
          l_rows_failed := l_rows_failed + 1;
        END IF;
      ELSE
        l_ext_agncy_not_notified := l_ext_agncy_not_notified + 1;
        --dbms_output.put_line('do not report - ' || l_oinv_rec.id);
      END IF;
    END LOOP;

    --dbms_output.PUT_LINE('EXT AGNCYS NOTIFIED                              = ' || l_ext_agncy_notified);
    --dbms_output.PUT_LINE('EXT AGNCYS NOT NOTIFIED                          = ' || l_ext_agncy_not_notified);
    --dbms_output.PUT_LINE('EXT AGNCYS TO BE NOTIFIED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    --dbms_output.PUT_LINE('EXT AGNCYS TO BE NOTIFIED NOT PROCESSED          = ' || l_rows_failed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'EXT AGNCYS NOTIFIED                              = ' || l_ext_agncy_notified);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'EXT AGNCYS NOT NOTIFIED                          = ' || l_ext_agncy_not_notified);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'EXT AGNCYS TO BE NOTIFIED PROCESSED SUCCESSFULLY = ' || l_rows_processed);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'EXT AGNCYS TO BE NOTIFIED NOT PROCESSED          = ' || l_rows_failed);

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_notify_csr%ISOPEN THEN
        CLOSE l_notify_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END notify_external_agency;

  ---------------------------------------------------------------------------
  -- PROCEDURE recall_from_external_agency
  ---------------------------------------------------------------------------
  PROCEDURE recall_from_external_agency(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER,
     p_case_number              IN VARCHAR2,
     p_ext_agncy_id             IN NUMBER,
     p_comments                 IN VARCHAR2) AS

     l_api_name                 CONSTANT VARCHAR2(30) := 'recall_from_external_agency';
     l_api_version              CONSTANT NUMBER := 1;
     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);

     l_case_number              OKL_OPEN_INT.CASE_NUMBER%TYPE;
     l_contract_id              OKL_OPEN_INT.KHR_ID%TYPE;
     l_ext_agncy_id             HZ_PARTIES.PARTY_ID%TYPE;

     l_contracts_recalled       NUMBER := 0;
     l_rows_failed              NUMBER := 0;

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     lp_iohv_rec                iohv_rec_type;
     lx_iohv_rec                iohv_rec_type;

     l_organization_id          HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE;
     l_case_passed              VARCHAR2(1) := Okc_Api.G_TRUE;
     l_ext_agncy_passed         VARCHAR2(1) := Okc_Api.G_TRUE;

     CURSOR l_recall_csr(cp_case_number IN VARCHAR2
                        ,cp_ext_agncy_id IN NUMBER
                        ,cp_organization_id IN NUMBER) IS
     SELECT OIN.ID,
            OIN.KHR_ID,
            IOH.ID,
            IOH.OBJECT1_ID1,
            IOH.OBJECT1_ID2,
            IOH.JTOT_OBJECT1_CODE,
            IOH.EXT_AGNCY_ID
     FROM Okl_Open_Int OIN
          ,Iex_Open_Int_Hst IOH
     WHERE OIN.khr_id = TO_NUMBER(IOH.object1_id1)
     AND   IOH.jtot_object1_code = 'OKX_LEASE'
     AND   (IOH.ACTION = ACTION_TRANSFER_EXT_AGNCY)
     AND   (IOH.STATUS = STATUS_NOTIFIED OR IOH.STATUS = STATUS_PROCESSED)
     AND   (TRUNC(IOH.RECALL_DATE) = TRUNC(SYSDATE))
     AND   (NVL(IOH.AUTOMATIC_RECALL_FLAG,'N') = 'Y')
     AND   ((l_case_passed = Okc_Api.G_FALSE) OR
            (l_case_passed = Okc_Api.G_TRUE AND OIN.case_number = cp_case_number))
     AND   ((l_ext_agncy_passed = Okc_Api.G_FALSE) OR
            (l_ext_agncy_passed = Okc_Api.G_TRUE AND IOH.ext_agncy_id = cp_ext_agncy_id))
     AND   (OIN.org_id = cp_organization_id);
  BEGIN
    --get organization id
    --Begin Bug#5373556 schekuri 12-Jul-2006
    l_organization_id := mo_global.get_current_org_id;
    --l_organization_id := fnd_profile.value('ORG_ID');
    --End Bug#5373556 schekuri 12-Jul-2006

    --check if case number is passed
    IF (p_case_number = OKC_API.G_MISS_CHAR OR
        p_case_number IS NULL) THEN
      l_case_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('contract is not passed');
    END IF;

    --check if party_id is passed
    IF (p_ext_agncy_id = OKC_API.G_MISS_NUM OR
        p_ext_agncy_id IS NULL) THEN
      l_ext_agncy_passed := Okc_Api.G_FALSE;
      --dbms_output.put_line('ext_agncy is not passed');
    END IF;

    OPEN l_recall_csr(p_case_number
                     ,p_ext_agncy_id
                     ,l_organization_id);
    LOOP
      FETCH l_recall_csr INTO
              l_oinv_rec.id,
              l_oinv_rec.khr_id,
              l_iohv_rec.id,
              l_iohv_rec.object1_id1,
              l_iohv_rec.object1_id2,
              l_iohv_rec.jtot_object1_code,
              l_iohv_rec.ext_agncy_id;
      EXIT WHEN l_recall_csr%NOTFOUND;

      recall_transfer(p_api_version => l_api_version
                     ,p_init_msg_list => l_init_msg_list
                     ,p_interface_id => l_oinv_rec.id
                     ,p_recall_date => SYSDATE
                     ,p_comments => p_comments
                     ,x_return_status => l_return_status
                     ,x_msg_count => lx_msg_count
                     ,x_msg_data => lx_msg_data);

      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_rows_failed := l_rows_failed + 1;
      ELSE
        l_contracts_recalled := l_contracts_recalled + 1;
      END IF;
    END LOOP;

    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CONTRACTS RECALLED SUCCESSFULLY  = ' || l_contracts_recalled);
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'CONTRACTS FAILED RECALL  = ' || l_rows_failed);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_recall_csr%ISOPEN THEN
        CLOSE l_recall_csr;
      END IF;
      errbuf   := substr(SQLERRM, 1, 200);
      retcode  := 1;
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
      ROLLBACK;
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END recall_from_external_agency;
  ---------------------------------------------------------------------------
  -- PROCEDURE get_hst_info
  ---------------------------------------------------------------------------
  PROCEDURE get_hst_info(
     p_hst_id                   IN NUMBER,
     x_action                   OUT NOCOPY VARCHAR2,
     x_status                   OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_action                   IEX_OPEN_INT_HST.ACTION%TYPE;
     l_status                   IEX_OPEN_INT_HST.STATUS%TYPE;

     CURSOR l_hst_csr(cp_hst_id IN NUMBER) IS
     SELECT action
           ,status
     FROM IEX_OPEN_INT_HST
     WHERE id = cp_hst_id;
  BEGIN
    OPEN l_hst_csr(p_hst_id);
    FETCH l_hst_csr INTO
       l_action
      ,l_status;
    CLOSE l_hst_csr;
    x_action := l_action;
    x_status := l_status;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_hst_info;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_party_email
  ---------------------------------------------------------------------------
  PROCEDURE get_party_email(
     p_party_id                 IN NUMBER,
     x_email                    OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     CURSOR l_prty_email_csr(cp_party_id IN NUMBER) IS
     SELECT email_address
     FROM hz_contact_points
     WHERE owner_table_name = 'HZ_PARTIES'
     AND owner_table_id = cp_party_id
     AND contact_point_type = 'EMAIL'
     AND primary_flag = 'Y'
     AND status = 'A';

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_email                    HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
  BEGIN
    OPEN l_prty_email_csr(p_party_id);
    FETCH l_prty_email_csr INTO
        l_email;
    CLOSE l_prty_email_csr;

    x_email := l_email;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_party_email;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_ext_agncy_email
  ---------------------------------------------------------------------------
  PROCEDURE get_ext_agncy_email(
     p_ext_agncy_id            IN NUMBER,
     x_email                    OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_email                    PO_VENDOR_SITES_ALL.EMAIL_ADDRESS%TYPE;

     CURSOR l_ext_agncy_email_csr(cp_ext_agncy_id IN NUMBER) IS
     SELECT pvs.email_address
     FROM   iex_ext_agncy_b iea
            ,po_vendor_sites_all pvs
     WHERE  iea.external_agency_id = cp_ext_agncy_id
     AND iea.vendor_site_id = pvs.vendor_site_id;
  BEGIN
    OPEN l_ext_agncy_email_csr(p_ext_agncy_id);
    FETCH l_ext_agncy_email_csr
    INTO l_email;
    CLOSE l_ext_agncy_email_csr;

    x_email := l_email;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_ext_agncy_email;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_external_agency
  ---------------------------------------------------------------------------
  PROCEDURE get_external_agency(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_ext_agncy_id             OUT NOCOPY NUMBER,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     l_ext_agncy_id             IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_score_id                 IEX_SCORES.SCORE_ID%TYPE;
     l_score_value              IEX_SCORE_HISTORIES.SCORE_VALUE%TYPE;
     l_score_found              BOOLEAN := FALSE;

     TYPE ext_agncy_tbl_type IS TABLE OF IEX_OPEN_INT_HST.EXT_AGNCY_ID%TYPE
     INDEX BY BINARY_INTEGER;

     l_exclude_ext_agncy_tbl ext_agncy_tbl_type;
     l_ext_agncy_tbl ext_agncy_tbl_type;

     i NUMBER := 0;
     j NUMBER := 0;

     CURSOR l_score_csr(cp_case_id IN NUMBER
                       ,cp_score_id IN NUMBER
                       ,cp_creation_date IN DATE) IS
     SELECT score_value
     FROM   IEX_SCORE_HISTORIES
     WHERE  score_object_id = cp_case_id
     AND    score_object_code = 'IEX_CASES'
     AND    score_id = cp_score_id
     AND    TRUNC(creation_date) = TRUNC(cp_creation_date)
     ORDER BY creation_date DESC;

     CURSOR l_ext_agncy_csr(cp_score_value IN NUMBER) IS
     SELECT external_agency_id
     FROM   iex_ext_agncy_b
     WHERE  rank >= cp_score_value
     AND SYSDATE BETWEEN effective_start_date AND nvl(effective_end_date, SYSDATE)
     ORDER BY rank ASC;

     CURSOR l_exclude_ext_agncy_csr(cp_object1_id1 IN NUMBER) IS
     SELECT ext_agncy_id
           ,status
           ,process_date
     FROM   iex_open_int_hst
     WHERE  object1_id1 = cp_object1_id1
     AND    object1_id2 = '#'
     AND    jtot_object1_code = 'OKX_LEASE'
     AND    action = ACTION_TRANSFER_EXT_AGNCY
     AND    (status = STATUS_PROCESSED
             OR status = STATUS_RECALLED)
     ORDER BY process_date DESC;
  BEGIN
    l_oinv_rec := p_oinv_rec;
    l_iohv_rec := p_iohv_rec;

    --get score engine to score cases
    l_score_id := to_number(fnd_profile.value('IEX_EA_SCORE_ID'));
    --DBMS_OUTPUT.PUT_LINE('Score Engine Id : ' || l_score_id);

    --get score if a case has been previously scored on the same day
    FOR cur_score IN l_score_csr(l_oinv_rec.cas_id
                          ,l_score_id
                          ,l_iohv_rec.process_date) LOOP
      l_score_value := cur_score.score_value;
      l_score_found := TRUE;
      EXIT;
    END LOOP;

    --if not previously scored on the same day, call scoring engine for object type = IEX_CASES
    IF NOT(l_score_found) THEN
      --score the case by calling IEX_SCORE_NEW_PVT.scoreObject
      l_score_value := IEX_SCORE_NEW_PVT.scoreObject(p_commit => FND_API.G_TRUE,
                     P_OBJECT_ID => l_oinv_rec.cas_id,
                     P_OBJECT_TYPE => 'IEX_CASES',
                     P_SCORE_ID => l_score_id);
      --if score value is null set a message appropriately
    END IF;

    --get external agencies to exlude for case assignment
    FOR cur_exclude_ext_agncy IN l_exclude_ext_agncy_csr(l_iohv_rec.object1_id1) LOOP
      IF (cur_exclude_ext_agncy.status = STATUS_RECALLED) THEN
        j := j + 1;
        l_exclude_ext_agncy_tbl(j) := cur_exclude_ext_agncy.ext_agncy_id;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('exclude_ext_agncy_tbl.count: ' || l_exclude_ext_agncy_tbl.count);

    --get external agencies eligible for case assignment
    FOR cur_ext_agncy IN l_ext_agncy_csr(l_score_value) LOOP
      i := i + 1;
      l_ext_agncy_tbl(i) := cur_ext_agncy.external_agency_id;
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('l_ext_agncy_tbl.count: ' || l_ext_agncy_tbl.count);

    --Eliminate agencies(from which the case has been previously recalled)from
    --the list of eligible agencies
    i := l_ext_agncy_tbl.first;
    WHILE (i IS NOT NULL) LOOP
      j := l_exclude_ext_agncy_tbl.first;
      WHILE (j IS NOT NULL) LOOP
        IF (l_ext_agncy_tbl(i) = l_exclude_ext_agncy_tbl(j)) THEN
          l_ext_agncy_tbl.delete(i);
          EXIT;
        END IF;
        j := l_exclude_ext_agncy_tbl.next(j);
      END LOOP;

      i := l_ext_agncy_tbl.next(i);
    END LOOP;


    --DBMS_OUTPUT.PUT_LINE('after elimination l_ext_agncy_tbl.count: ' || l_ext_agncy_tbl.count);
    l_ext_agncy_id := l_ext_agncy_tbl(l_ext_agncy_tbl.first);

    x_ext_agncy_id := l_ext_agncy_id;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_external_agency;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_contract_recall
  ---------------------------------------------------------------------------
  PROCEDURE get_contract_recall(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_recall                    OUT NOCOPY VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2) AS

     l_return_status             VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_recall                    VARCHAR2(1) := Okc_Api.G_TRUE;

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     l_score_id                 IEX_SCORES.SCORE_ID%TYPE;
     l_score_value              IEX_SCORE_HISTORIES.SCORE_VALUE%TYPE;
     l_score_value_previous     IEX_SCORE_HISTORIES.SCORE_VALUE%TYPE;

     CURSOR l_score_csr(cp_case_id IN NUMBER
                       ,cp_score_id IN NUMBER
                       ,cp_creation_date IN DATE) IS
     SELECT score_value
     FROM   IEX_SCORE_HISTORIES
     WHERE  score_object_id = cp_case_id
     AND    score_object_code = 'IEX_CASES'
     AND    score_id = cp_score_id
     AND    TRUNC(creation_date) = TRUNC(cp_creation_date)
     ORDER BY creation_date DESC;
  BEGIN
    l_oinv_rec := p_oinv_rec;
    l_iohv_rec := p_iohv_rec;

    --get score engine to score cases
    l_score_id := to_number(fnd_profile.value('IEX_EA_SCORE_ID'));

    --get score of the case when assigned to externalagency previously
    FOR cur_score IN l_score_csr(l_oinv_rec.cas_id
                          ,l_score_id
                          ,l_iohv_rec.process_date) LOOP
      l_score_value_previous := cur_score.score_value;
      EXIT;
    END LOOP;

    --score the case by calling IEX_SCORE_NEW_PVT.scoreObject
    l_score_value := IEX_SCORE_NEW_PVT.scoreObject(p_commit => FND_API.G_TRUE,
                     P_OBJECT_ID => l_oinv_rec.cas_id,
                     P_OBJECT_TYPE => 'IEX_CASES',
                     P_SCORE_ID => l_score_id);

    IF ((nvl(l_score_value,0) - nvl(l_score_value_previous,0)) >= to_number(fnd_profile.value('IEX_EA_SCORE_DIFF_FOR_RECALL'))) THEN
      l_recall := Okc_Api.G_FALSE;
    END IF;

    x_recall := l_recall;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_contract_recall;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_contract_delinquency_stat
  ---------------------------------------------------------------------------
  PROCEDURE get_contract_delinquency_stat(
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_delinquency_status       OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status             VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_delinquency_status        IEX_DEL_STATUSES.DEL_STATUS%TYPE;

     l_oinv_rec                 oinv_rec_type;
     l_iohv_rec                 iohv_rec_type;
     l_score_id                 IEX_SCORES.SCORE_ID%TYPE;
     l_score_found              BOOLEAN := FALSE;
     l_score_value              IEX_SCORE_HISTORIES.SCORE_VALUE%TYPE;

     CURSOR l_score_csr(cp_case_id IN NUMBER
                       ,cp_score_id IN NUMBER
                       ,cp_creation_date IN DATE) IS
     SELECT score_value
     FROM   IEX_SCORE_HISTORIES
     WHERE  score_object_id = cp_case_id
     AND    score_object_code = 'IEX_CASES'
     AND    score_id = cp_score_id
     AND    TRUNC(creation_date) = TRUNC(cp_creation_date)
     ORDER BY creation_date DESC;

     CURSOR l_del_status_csr(cp_score_id IN NUMBER
                            ,cp_score_value IN NUMBER) IS
     SELECT del_status
     FROM IEX_DEL_STATUSES
     WHERE score_id = cp_score_id
     AND   cp_score_value BETWEEN score_value_low AND score_value_high;
  BEGIN
    l_oinv_rec := p_oinv_rec;
    l_iohv_rec := p_iohv_rec;

    --get score engine to score cases
    l_score_id := to_number(fnd_profile.value('IEX_EA_SCORE_ID'));

    --get score of the case when assigned to externalagency previously
    FOR cur_score IN l_score_csr(l_oinv_rec.cas_id
                          ,l_score_id
                          ,l_iohv_rec.process_date) LOOP
      l_score_value := cur_score.score_value;
      l_score_found := TRUE;
      EXIT;
    END LOOP;

    --if score is not found, score the case by calling IEX_SCORE_NEW_PVT.scoreObject
    IF NOT(l_score_found) THEN
      l_score_value := IEX_SCORE_NEW_PVT.scoreObject(p_commit => FND_API.G_TRUE,
                     P_OBJECT_ID => l_oinv_rec.cas_id,
                     P_OBJECT_TYPE => 'IEX_CASES',
                     P_SCORE_ID => l_score_id);
    END IF;

    --get delinquency status
    FOR cur_del_status IN l_del_status_csr(l_score_id
                                          ,l_score_value) LOOP
      l_delinquency_status := cur_del_status.del_status;
      EXIT;
    END LOOP;

    x_delinquency_status := l_delinquency_status;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_contract_delinquency_stat;
END IEX_OPI_PVT;

/
