--------------------------------------------------------
--  DDL for Package Body OKL_OPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPI_PVT" AS
/* $Header: OKLROPIB.pls 120.2 2006/09/25 09:25:52 dkagrawa noship $ */

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
  -- PROCEDURE insert_pending_int
  ---------------------------------------------------------------------------
  PROCEDURE insert_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id              IN NUMBER,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'insert_pending_int';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;
     l_contract_rec             contract_rec_type;
     l_party_rec                party_rec_type;
     l_contract_found           BOOLEAN := FALSE;

     CURSOR l_oin_csr(cp_contract_id IN NUMBER) IS
     SELECT id
     FROM okl_open_int
     WHERE khr_id = cp_contract_id;
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
    l_oinv_rec.khr_id := p_contract_id;

    --Get contract information
    get_contract(p_contract_id => l_oinv_rec.khr_id
                 ,x_contract_rec => l_contract_rec
                 ,x_return_status => l_return_status);

    --dbms_output.put_line('contract # - ' || l_contract_rec.contract_number);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_oinv_rec.contract_number := l_contract_rec.contract_number;
    l_oinv_rec.contract_type := l_contract_rec.contract_type;
    l_oinv_rec.contract_status := l_contract_rec.contract_status;
    l_oinv_rec.org_id := l_contract_rec.org_id;


    --Get party information
    get_party(p_contract_id => l_oinv_rec.khr_id
              ,x_party_rec => l_party_rec
              ,x_return_status => l_return_status);

    --dbms_output.put_line('party name - ' || l_party_rec.party_name);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_oinv_rec.party_id := l_party_rec.party_id;
    l_oinv_rec.party_name := l_party_rec.party_name;
    l_oinv_rec.party_type := l_party_rec.party_type;

    --Get case information
    get_case(p_contract_id => l_oinv_rec.khr_id
             ,x_cas_id => l_oinv_rec.cas_id
             ,x_case_number => l_oinv_rec.case_number
             ,x_return_status => l_return_status);


    --dbms_output.put_line('case number - ' || l_oinv_rec.case_number);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    FOR cur IN l_oin_csr(p_contract_id) LOOP
      l_oinv_rec.id := cur.id;
      l_contract_found := TRUE;
      EXIT;
    END LOOP;

    IF l_contract_found THEN
      okl_open_int_pub.update_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);
    ELSE
      okl_open_int_pub.insert_open_int(p_api_version => l_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => l_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_data => x_msg_data
                            ,p_oinv_rec => l_oinv_rec
                            ,x_oinv_rec => lx_oinv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    x_oinv_rec := lx_oinv_rec;

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
  END insert_pending_int;

  ---------------------------------------------------------------------------
  -- PROCEDURE process_pending_int
  ---------------------------------------------------------------------------
  PROCEDURE process_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2)AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'process_pending_int';

     l_oinv_rec                 oinv_rec_type;
     lx_oinv_rec                oinv_rec_type;

     l_oipv_rec                 oipv_rec_type;
     lx_oipv_rec                oipv_rec_type;

     l_iohv_rec                 iohv_rec_type;

     l_party_rec                party_rec_type;
     l_contract_rec             contract_rec_type;
     l_out_contract_rec         contract_rec_type;
     l_guarantor_tbl            party_tbl_type;
     i                          NUMBER :=  0;
     l_guarantor_found          BOOLEAN := FALSE;

     CURSOR l_guarantor_csr(cp_khr_id IN NUMBER
                           ,cp_party_id IN NUMBER) IS
     SELECT id
     FROM okl_open_int_prty
     WHERE khr_id = cp_khr_id
     AND party_id = cp_party_id;
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

    --Calling get_party to fill in party attributes
    get_party(p_contract_id => l_oinv_rec.khr_id
             ,x_party_rec => l_party_rec
             ,x_return_status => l_return_status);

    l_oinv_rec.date_of_birth := l_party_rec.date_of_birth;
    l_oinv_rec.place_of_birth := l_party_rec.place_of_birth;
    l_oinv_rec.person_identifier := l_party_rec.person_identifier;
    l_oinv_rec.person_iden_type := l_party_rec.person_iden_type;
    l_oinv_rec.address1 := l_party_rec.address1;
    l_oinv_rec.address2 := l_party_rec.address2;
    l_oinv_rec.address3 := l_party_rec.address3;
    l_oinv_rec.address4 := l_party_rec.address4;
    l_oinv_rec.country := l_party_rec.country;
    l_oinv_rec.city := l_party_rec.city;
    l_oinv_rec.postal_code := l_party_rec.postal_code;
    l_oinv_rec.state := l_party_rec.state;
    l_oinv_rec.province := l_party_rec.province;
    l_oinv_rec.county := l_party_rec.county;
    l_oinv_rec.po_box_number := l_party_rec.po_box_number;
    l_oinv_rec.house_number := l_party_rec.house_number;
    l_oinv_rec.street_suffix := l_party_rec.street_suffix;
    l_oinv_rec.apartment_number := l_party_rec.apartment_number;
    l_oinv_rec.street := l_party_rec.street;
    l_oinv_rec.rural_route_number := l_party_rec.rural_route_number;
    l_oinv_rec.street_number := l_party_rec.street_number;
    l_oinv_rec.building := l_party_rec.building;
    l_oinv_rec.floor := l_party_rec.floor;
    l_oinv_rec.suite := l_party_rec.suite;
    l_oinv_rec.room := l_party_rec.room;
    l_oinv_rec.postal_plus4_code := l_party_rec.postal_plus4_code;

    --Calling get_contract to fill in contract attributes
    get_contract(p_contract_id => l_oinv_rec.khr_id
                ,x_contract_rec => l_contract_rec
                ,x_return_status => l_return_status);


    l_oinv_rec.start_date := l_contract_rec.start_date;
    l_oinv_rec.close_date := l_contract_rec.close_date;
    l_oinv_rec.term_duration := l_contract_rec.term_duration;


    --Calling get_contract_payment_info to fill in contract payment attributes
    get_contract_payment_info(p_contract_rec => l_contract_rec
                ,x_contract_rec => l_out_contract_rec
                ,x_return_status => l_return_status);

    l_oinv_rec.original_amount := l_out_contract_rec.original_amount;
    l_oinv_rec.monthly_payment_amount := l_out_contract_rec.monthly_payment_amount;
    l_oinv_rec.last_payment_date := l_out_contract_rec.last_payment_date;
    l_oinv_rec.delinquency_occurance_date := l_out_contract_rec.delinquency_occurance_date;
    l_oinv_rec.past_due_amount := l_out_contract_rec.past_due_amount;
    l_oinv_rec.remaining_amount := l_out_contract_rec.remaining_amount;
    l_oinv_rec.credit_indicator := l_out_contract_rec.credit_indicator;


    --Calling get_case_owner to fill in case owner attributes
    get_case_owner(p_cas_id => l_oinv_rec.cas_id
                  ,x_owner_resource_id => l_oinv_rec.contact_id
                  ,x_resource_name => l_oinv_rec.contact_name
                  ,x_resource_phone => l_oinv_rec.contact_phone
                  ,x_resource_email => l_oinv_rec.contact_email
                  ,x_return_status  => l_return_status);


    --Update open interface row with new data
    okl_open_int_pub.update_open_int(p_api_version => l_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_data => x_msg_data
                          ,p_oinv_rec => l_oinv_rec
                          ,x_oinv_rec => lx_oinv_rec);

    --dbms_output.put_line('khr_id: ' || lx_oinv_rec.khr_id);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_oinv_rec := lx_oinv_rec;

    --Get guarantors
    get_guarantor(p_contract_id => lx_oinv_rec.khr_id
                  ,x_party_tbl => l_guarantor_tbl
                  ,x_return_status => l_return_status);

    --insert/update guarantors into okl_open_int_prty_v
    --DBMS_OUTPUT.PUT_LINE('GUARANTOR count - ' || l_guarantor_tbl.count);
    FOR i IN 1..l_guarantor_tbl.COUNT LOOP
      l_oipv_rec.khr_id := lx_oinv_rec.khr_id;
      l_oipv_rec.party_id := l_guarantor_tbl(i).party_id;
      l_oipv_rec.party_name := l_guarantor_tbl(i).party_name;
      l_oipv_rec.org_id := lx_oinv_rec.org_id;
      l_oipv_rec.address1 := l_guarantor_tbl(i).address1;
      l_oipv_rec.address2 := l_guarantor_tbl(i).address2;
      l_oipv_rec.address3 := l_guarantor_tbl(i).address3;
      l_oipv_rec.address4 := l_guarantor_tbl(i).address4;
      l_oipv_rec.country := l_guarantor_tbl(i).country;
      l_oipv_rec.city := l_guarantor_tbl(i).city;
      l_oipv_rec.postal_code := l_guarantor_tbl(i).postal_code;
      l_oipv_rec.state := l_guarantor_tbl(i).state;
      l_oipv_rec.province := l_guarantor_tbl(i).province;
      l_oipv_rec.county := l_guarantor_tbl(i).county;
      l_oipv_rec.po_box_number := l_guarantor_tbl(i).po_box_number;
      l_oipv_rec.house_number := l_guarantor_tbl(i).house_number;
      l_oipv_rec.street_suffix := l_guarantor_tbl(i).street_suffix;
      l_oipv_rec.apartment_number := l_guarantor_tbl(i).apartment_number;
      l_oipv_rec.street := l_guarantor_tbl(i).street;
      l_oipv_rec.rural_route_number := l_guarantor_tbl(i).rural_route_number;
      l_oipv_rec.street_number := l_guarantor_tbl(i).street_number;
      l_oipv_rec.building := l_guarantor_tbl(i).building;
      l_oipv_rec.floor := l_guarantor_tbl(i).floor;
      l_oipv_rec.suite := l_guarantor_tbl(i).suite;
      l_oipv_rec.room := l_guarantor_tbl(i).room;
      l_oipv_rec.postal_plus4_code := l_guarantor_tbl(i).postal_plus4_code;

      l_oipv_rec.phone_country_code := l_guarantor_tbl(i).phone_country_code;
      l_oipv_rec.phone_area_code := l_guarantor_tbl(i).phone_area_code;
      l_oipv_rec.phone_number := l_guarantor_tbl(i).phone_number;
      l_oipv_rec.phone_extension := l_guarantor_tbl(i).phone_extension;

      --DBMS_OUTPUT.PUT_LINE('GUARANTOR - ' || l_guarantor_tbl(i).party_name);
      l_guarantor_found := FALSE;
      FOR cur in l_guarantor_csr(l_oipv_rec.khr_id, l_oipv_rec.party_id ) LOOP
        l_guarantor_found := TRUE;
        l_oipv_rec.id := cur.id;
        EXIT;
      END LOOP;

      IF (l_guarantor_found) THEN
        okl_open_int_prty_pub.update_open_int_prty( p_api_version => l_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => l_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               ,p_oipv_rec => l_oipv_rec
                               ,x_oipv_rec => lx_oipv_rec);
        /*
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        */
      ELSE
        --dbms_output.put_line('khr_id : ' || l_oipv_rec.khr_id);
        --dbms_output.put_line('party_id : ' || l_oipv_rec.party_id);
        --dbms_output.put_line('party_name : ' || l_oipv_rec.party_name);

        okl_open_int_prty_pub.insert_open_int_prty( p_api_version => l_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => l_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data
                               ,p_oipv_rec => l_oipv_rec
                               ,x_oipv_rec => lx_oipv_rec);
        /*
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        */
      END IF;
    END LOOP;


    --Get contract asset details
    IF (p_iohv_rec.action = IEX_OPI_PVT.ACTION_TRANSFER_EXT_AGNCY) THEN
      --dbms_OUTPUT.PUT_LINE('Processing assets...');
      process_pending_asset(p_api_version => l_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,p_iohv_rec => l_iohv_rec
                          ,x_return_status => l_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_data => x_msg_data);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
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
   END process_pending_int;

  ---------------------------------------------------------------------------
  -- PROCEDURE process_pending_asset
  ---------------------------------------------------------------------------
  PROCEDURE process_pending_asset(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_iohv_rec                 IN iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'process_pending_asset';
     lx_oiav_tbl                 oiav_tbl_type;
     l_oiav_rec                 oiav_rec_type;
     lx_oiav_rec                 oiav_rec_type;

     i                          NUMBER :=  0;
     l_asset_found              BOOLEAN := FALSE;

     CURSOR l_asset_csr(cp_khr_id IN VARCHAR2
                       ,cp_instance_number IN VARCHAR2) IS
     SELECT id
     FROM okl_open_int_asst
     WHERE khr_id = cp_khr_id
     AND instance_number = cp_instance_number;
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

    --Get contract assets details
    lx_oiav_tbl.delete;
    get_assets(p_contract_id => TO_NUMBER(p_iohv_rec.object1_id1),
               x_oiav_tbl => lx_oiav_tbl,
               x_return_status => l_return_status);

    --dbms_OUTPUT.PUT_LINE('assets found : ' || lx_oiav_tbl.count);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --insert/update assets in open interface assets
    FOR i IN 1..lx_oiav_tbl.count LOOP
      l_oiav_rec := lx_oiav_tbl(i);

      l_asset_found := FALSE;
      --dbms_OUTPUT.PUT_LINE('khr_id : ' || l_oiav_rec.khr_id);
      --dbms_OUTPUT.PUT_LINE('instance_number : ' || l_oiav_rec.instance_number);
      --dbms_OUTPUT.PUT_LINE('asset_id : ' || l_oiav_rec.asset_id);
      FOR cur_asset_csr IN l_asset_csr(l_oiav_rec.khr_id
                                      ,l_oiav_rec.instance_number) LOOP
        l_asset_found := TRUE;
        l_oiav_rec.id := cur_asset_csr.id;
        --dbms_OUTPUT.PUT_LINE('found : ' || l_oiav_rec.instance_number);
      END LOOP;

      IF (l_asset_found) THEN
          --dbms_OUTPUT.PUT_LINE('updating asset');
          okl_open_int_asst_pub.update_open_int_asst (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_oiav_rec                     => l_oiav_rec,
            x_oiav_rec                     => lx_oiav_rec);

          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
      ELSE
          --dbms_OUTPUT.PUT_LINE('inserting asset');
          l_oiav_rec.org_id := p_iohv_rec.org_id;
          okl_open_int_asst_pub.insert_open_int_asst (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_oiav_rec                     => l_oiav_rec,
            x_oiav_rec                     => lx_oiav_rec);
          /*
          --dbms_OUTPUT.PUT_LINE('x_return_status : ' || l_return_status);
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
          --dbms_OUTPUT.PUT_LINE('inserted asset');
          */
      END IF;

    END LOOP;

    -- Processing ends
    l_return_status := Okc_Api.G_RET_STS_SUCCESS;
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
   END process_pending_asset;

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE report_all_credit_bureau
  ---------------------------------------------------------------------------
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
     lx_oinv_rec                 oinv_rec_type;
     lx_iohv_rec                 iohv_rec_type;

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

    -- Get pending records to be processed
    OPEN l_report_all_csr(l_organization_id);
    LOOP
    FETCH l_report_all_csr INTO
              l_oinv_rec.khr_id;
    EXIT WHEN l_report_all_csr%NOTFOUND;

    --find out lessee syndicate flag
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
        p_transfer_days => NULL,
        p_extend_days => NULL,
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
*/

  ---------------------------------------------------------------------------
  -- PROCEDURE get_party
  ---------------------------------------------------------------------------
  PROCEDURE get_party(
     p_contract_id              IN NUMBER,
     x_party_rec                OUT NOCOPY party_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_bill_to_add_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_party_rec                party_rec_type;
     l_bill_to_address_id       HZ_LOCATIONS.LOCATION_ID%TYPE;

     CURSOR l_party_csr(cp_party_id IN NUMBER) IS
     SELECT hp.party_name
           ,hp.party_type
     FROM hz_parties hp
     WHERE hp.party_id = cp_party_id;

     CURSOR l_pp_csr(cp_party_id IN NUMBER) IS
     SELECT hpp.date_of_birth
           ,hpp.place_of_birth
           ,hpp.person_identifier
           ,hpp.person_iden_type
     FROM hz_person_profiles hpp
     WHERE hpp.party_id = cp_party_id;

     CURSOR l_hzl_csr(cp_bill_to_address_id IN NUMBER) IS
     SELECT hzl.address1
           ,hzl.address2
           ,hzl.address3
           ,hzl.address4
           ,hzl.country
           ,hzl.city
           ,hzl.postal_code
           ,hzl.state
           ,hzl.province
           ,hzl.county
           ,hzl.po_box_number
           ,hzl.house_number
           ,hzl.street_suffix
           ,hzl.apartment_number
           ,hzl.street
           ,hzl.rural_route_number
           ,hzl.street_number
           ,hzl.building
           ,hzl.floor
           ,hzl.suite
           ,hzl.room
           ,hzl.postal_plus4_code
     FROM hz_locations hzl
     WHERE hzl.location_id = cp_bill_to_address_id;
  BEGIN
    l_return_status := OKL_CONTRACT_INFO.get_customer(p_contract_id, l_party_rec.party_id);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_INVALID_PARTY);
    END IF;

    OPEN l_party_csr(l_party_rec.party_id);
    FETCH l_party_csr INTO
       l_party_rec.party_name
      ,l_party_rec.party_type;
    CLOSE l_party_csr;

    OPEN l_pp_csr(l_party_rec.party_id);
    FETCH l_pp_csr INTO
       l_party_rec.date_of_birth
      ,l_party_rec.place_of_birth
      ,l_party_rec.person_identifier
      ,l_party_rec.person_iden_type;
    CLOSE l_pp_csr;


    l_bill_to_add_return_status := OKL_CONTRACT_INFO.get_bill_to_address(p_contract_id, l_bill_to_address_id);

    OPEN l_hzl_csr(l_bill_to_address_id);
    FETCH l_hzl_csr INTO
       l_party_rec.address1
      ,l_party_rec.address2
      ,l_party_rec.address3
      ,l_party_rec.address4
      ,l_party_rec.country
      ,l_party_rec.city
      ,l_party_rec.postal_code
      ,l_party_rec.state
      ,l_party_rec.province
      ,l_party_rec.county
      ,l_party_rec.po_box_number
      ,l_party_rec.house_number
      ,l_party_rec.street_suffix
      ,l_party_rec.apartment_number
      ,l_party_rec.street
      ,l_party_rec.rural_route_number
      ,l_party_rec.street_number
      ,l_party_rec.building
      ,l_party_rec.floor
      ,l_party_rec.suite
      ,l_party_rec.room
      ,l_party_rec.postal_plus4_code;
    --dbms_output.put_line('bill to add found');
    CLOSE l_hzl_csr;

    x_party_rec := l_party_rec;
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
  END get_party;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_guarantor
  ---------------------------------------------------------------------------
  PROCEDURE get_guarantor(
     p_contract_id              IN NUMBER,
     x_party_tbl                OUT NOCOPY party_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_guarantor_tbl            party_tbl_type;
     l_guarantor_rec             party_rec_type;
     i                          NUMBER := 0;

     CURSOR l_guarantor_csr(cp_contract_id IN NUMBER) IS
     SELECT hp.party_id
           ,hp.party_name
           ,hl.address1
           ,hl.address2
           ,hl.address3
           ,hl.address4
           ,hl.country
           ,hl.city
           ,hl.postal_code
           ,hl.state
           ,hl.province
           ,hl.county
           ,hl.po_box_number
           ,hl.house_number
           ,hl.street_suffix
           ,hl.apartment_number
           ,hl.street
           ,hl.rural_route_number
           ,hl.street_number
           ,hl.building
           ,hl.floor
           ,hl.suite
           ,hl.room
           ,hl.postal_plus4_code
     FROM  okc_k_party_roles_b opr
          ,hz_parties hp
          ,hz_party_sites hps
          ,hz_locations hl
          ,hz_party_site_uses hpsu
     WHERE opr.dnz_chr_id = cp_contract_id
     AND   opr.rle_code = 'GUARANTOR'
     AND   opr.object1_id1 = hp.party_id
     AND   hp.party_id = hps.party_id
     AND   hps.party_site_id = hpsu.party_site_id
     AND   hpsu.site_use_type = 'BILL_TO'
     AND   hpsu.primary_per_type = 'Y'
     AND   hps.location_id = hl.location_id
     ORDER BY hp.party_id;

     CURSOR l_phone_csr(cp_party_id IN NUMBER) IS
     SELECT phone_country_code
           ,phone_area_code
           ,phone_number
           ,phone_extension
     FROM hz_contact_points
     WHERE owner_table_name = 'HZ_PARTIES'
     AND owner_table_id = cp_party_id
     AND contact_point_type = 'PHONE'
     AND primary_flag = 'Y'
     AND status = 'A';
  BEGIN
    --dbms_output.put_line('getting guarantors for contract ' || p_contract_id);
    OPEN l_guarantor_csr(p_contract_id);
    LOOP
      FETCH l_guarantor_csr INTO
          l_guarantor_rec.party_id
         ,l_guarantor_rec.party_name
         ,l_guarantor_rec.address1
         ,l_guarantor_rec.address2
         ,l_guarantor_rec.address3
         ,l_guarantor_rec.address4
         ,l_guarantor_rec.country
         ,l_guarantor_rec.city
         ,l_guarantor_rec.postal_code
         ,l_guarantor_rec.state
         ,l_guarantor_rec.province
         ,l_guarantor_rec.county
         ,l_guarantor_rec.po_box_number
         ,l_guarantor_rec.house_number
         ,l_guarantor_rec.street_suffix
         ,l_guarantor_rec.apartment_number
         ,l_guarantor_rec.street
         ,l_guarantor_rec.rural_route_number
         ,l_guarantor_rec.street_number
         ,l_guarantor_rec.building
         ,l_guarantor_rec.floor
         ,l_guarantor_rec.suite
         ,l_guarantor_rec.room
         ,l_guarantor_rec.postal_plus4_code;
      EXIT WHEN l_guarantor_csr%NOTFOUND;

      FOR cur_phone IN l_phone_csr(l_guarantor_rec.party_id) LOOP
        l_guarantor_rec.phone_country_code := cur_phone.phone_country_code;
        l_guarantor_rec.phone_area_code := cur_phone.phone_area_code;
        l_guarantor_rec.phone_number := cur_phone.phone_number;
        l_guarantor_rec.phone_extension := cur_phone.phone_extension;
        EXIT;
      END LOOP;

      i := i + 1;
      l_guarantor_tbl(i).party_id := l_guarantor_rec.party_id;
      l_guarantor_tbl(i).party_name := l_guarantor_rec.party_name;
      l_guarantor_tbl(i).address1 := l_guarantor_rec.address1;
      l_guarantor_tbl(i).address2 := l_guarantor_rec.address2;
      l_guarantor_tbl(i).address3 := l_guarantor_rec.address3;
      l_guarantor_tbl(i).address4 := l_guarantor_rec.address4;
      l_guarantor_tbl(i).country := l_guarantor_rec.country;
      l_guarantor_tbl(i).city := l_guarantor_rec.city;
      l_guarantor_tbl(i).postal_code := l_guarantor_rec.postal_code;
      l_guarantor_tbl(i).state := l_guarantor_rec.state;
      l_guarantor_tbl(i).province := l_guarantor_rec.province;
      l_guarantor_tbl(i).county := l_guarantor_rec.county;
      l_guarantor_tbl(i).po_box_number := l_guarantor_rec.po_box_number;
      l_guarantor_tbl(i).house_number := l_guarantor_rec.house_number;
      l_guarantor_tbl(i).street_suffix := l_guarantor_rec.street_suffix;
      l_guarantor_tbl(i).apartment_number := l_guarantor_rec.apartment_number;
      l_guarantor_tbl(i).street := l_guarantor_rec.street;
      l_guarantor_tbl(i).rural_route_number := l_guarantor_rec.rural_route_number;
      l_guarantor_tbl(i).street_number := l_guarantor_rec.street_number;
      l_guarantor_tbl(i).building := l_guarantor_rec.building;
      l_guarantor_tbl(i).floor := l_guarantor_rec.floor;
      l_guarantor_tbl(i).suite := l_guarantor_rec.suite;
      l_guarantor_tbl(i).room := l_guarantor_rec.room;
      l_guarantor_tbl(i).postal_plus4_code := l_guarantor_rec.postal_plus4_code;
      l_guarantor_tbl(i).phone_country_code := l_guarantor_rec.phone_country_code;
      l_guarantor_tbl(i).phone_area_code := l_guarantor_rec.phone_area_code;
      l_guarantor_tbl(i).phone_number := l_guarantor_rec.phone_number;
      l_guarantor_tbl(i).phone_extension := l_guarantor_rec.phone_extension;
    END LOOP;
    CLOSE l_guarantor_csr;

    x_party_tbl := l_guarantor_tbl;
    --dbms_output.put_line('guarantors count ' || x_party_tbl.count);
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_guarantor_csr%ISOPEN THEN
        CLOSE l_guarantor_csr;
      END IF;
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END get_guarantor;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_case
  ---------------------------------------------------------------------------
  PROCEDURE get_case(
     p_contract_id              IN NUMBER,
     x_cas_id                   OUT NOCOPY NUMBER,
     x_case_number              OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_cas_id                   IEX_CASE_OBJECTS.CAS_ID%TYPE;
     l_case_number              IEX_CASES_ALL_B.CASE_NUMBER%TYPE;

     CURSOR l_case_csr(cp_contract_id IN NUMBER) IS
     SELECT ico.cas_id
           ,ica.case_number
     FROM iex_case_objects ico
         ,iex_cases_all_b  ica
     WHERE ico.object_id = cp_contract_id
     AND   ico.cas_id = ica.cas_id
     AND   ica.active_flag = 'Y';
BEGIN
    OPEN l_case_csr(p_contract_id);
    FETCH l_case_csr INTO
       l_cas_id
      ,l_case_number;
    IF l_case_csr%NOTFOUND THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_INVALID_CASE);
      l_return_status := OKC_API.G_RET_STS_ERROR;
      CLOSE l_case_csr;
    ELSE
      CLOSE l_case_csr;
    END IF;
    x_cas_id := l_cas_id;
    x_case_number := l_case_number;
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
  END get_case;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_contract
  ---------------------------------------------------------------------------
  PROCEDURE get_contract(
     p_contract_id              IN NUMBER,
     x_contract_rec             OUT NOCOPY contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_contract_rec             contract_rec_type;

     CURSOR l_khr_csr(cp_contract_id IN NUMBER) IS
     SELECT okhv.contract_number
           ,okhv.scs_code
           ,okhv.sts_code
           ,okhv.start_date
           ,nvl(okhv.date_terminated, okhv.end_date) close_date
           ,okh.term_duration
           ,okhv.authoring_org_id
     FROM okc_k_headers_v okhv
         ,okl_k_headers okh
     WHERE okhv.id = cp_contract_id
     AND   okhv.id = okh.id;

  BEGIN
    l_contract_rec.khr_id := p_contract_id;
    OPEN l_khr_csr(l_contract_rec.khr_id);
    FETCH l_khr_csr INTO
       l_contract_rec.contract_number
      ,l_contract_rec.contract_type
      ,l_contract_rec.contract_status
      ,l_contract_rec.start_date
      ,l_contract_rec.close_date
      ,l_contract_rec.term_duration
      ,l_contract_rec.org_id;
    IF l_khr_csr%NOTFOUND THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_INVALID_CONTRACT);
      CLOSE l_khr_csr;
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
      CLOSE l_khr_csr;
    END IF;
    x_contract_rec := l_contract_rec;
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
  END get_contract;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_contract_payment_info
  ---------------------------------------------------------------------------
  PROCEDURE get_contract_payment_info(
     p_contract_rec             IN contract_rec_type,
     x_contract_rec             OUT NOCOPY contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_contract_rec             contract_rec_type;
     l_security_deposit         NUMBER;
     l_interest_type            NUMBER;

     CURSOR l_khr_past_due_csr(cp_contract_id IN NUMBER) IS
     SELECT sum(nvl(aps.amount_due_remaining, 0)) past_due_amount
     FROM okl_cnsld_ar_strms_b ocas
         ,ar_payment_schedules_all aps
     WHERE ocas.khr_id = cp_contract_id
     AND   ocas.receivables_invoice_id = aps.customer_trx_id
     AND   aps.class = 'INV'
     AND   aps.due_date < sysdate
     AND   nvl(aps.amount_due_remaining, 0) > 0;

     CURSOR l_khr_due_date(cp_contract_id IN NUMBER) IS
     SELECT min(aps.due_date) due_date
     FROM okl_cnsld_ar_strms_b ocas
         ,ar_payment_schedules_all aps
     WHERE ocas.khr_id = cp_contract_id
     AND   ocas.receivables_invoice_id = aps.customer_trx_id
     AND   aps.class = 'INV'
     AND   aps.due_date < sysdate
     AND   nvl(aps.amount_due_remaining, 0) > 0;

     CURSOR l_khr_last_pymt_date(cp_contract_id IN NUMBER) IS
     SELECT min(ara.apply_date) apply_date
     FROM okl_cnsld_ar_strms_b ocas
         ,ar_payment_schedules_all aps
         ,ar_receivable_applications_all ara
     WHERE ocas.khr_id = cp_contract_id
     AND ocas.receivables_invoice_id = aps.customer_trx_id
     AND aps.class = 'INV'
     AND aps.payment_schedule_id = ara.payment_schedule_id
     AND ara.status = 'APP';
  BEGIN
    l_contract_rec := p_contract_rec;

    --Get past due amount
    OPEN l_khr_past_due_csr(l_contract_rec.khr_id);
    FETCH l_khr_past_due_csr INTO
       l_contract_rec.past_due_amount;
    CLOSE l_khr_past_due_csr;

    --Get past due date (date when delinquency occured)
    OPEN l_khr_due_date(l_contract_rec.khr_id);
    FETCH l_khr_due_date INTO
       l_contract_rec.delinquency_occurance_date;
    CLOSE l_khr_due_date;

    --Get last payment date
    OPEN l_khr_last_pymt_date(l_contract_rec.khr_id);
    FETCH l_khr_last_pymt_date INTO
       l_contract_rec.last_payment_date;
    CLOSE l_khr_last_pymt_date;

    --code for getting original_amount
    /*
    l_contract_rec.original_amount := okl_formula_function_pvt.ctrt_capitalamount(
            p_chr_id => l_contract_rec.khr_id,
            p_line_id => NULL);
            */
    l_contract_rec.original_amount := NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_oec(p_chr_id => l_contract_rec.khr_id, p_line_id => NULL),0)
    - NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_tradein(p_chr_id => l_contract_rec.khr_id, p_line_id => NULL),0)
    - NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_capital_reduction(p_chr_id => l_contract_rec.khr_id, p_line_id => NULL),0)
    + NVL(OKL_SEEDED_FUNCTIONS_PVT.contract_fees_capitalized(p_chr_id => l_contract_rec.khr_id, p_line_id => NULL),0);


    --code for getting monthly_payment_amount
    l_return_status := OKL_CONTRACT_INFO.get_rent_security_interest(
                            p_contract_id => l_contract_rec.khr_id,
                            x_advance_rent => l_contract_rec.monthly_payment_amount,
                            x_security_deposit => l_security_deposit,
                            x_interest_type => l_interest_type);

    --code for getting remaining_amount
    l_return_status := OKL_CONTRACT_INFO.get_outstanding_rcvble(
                            p_contract_id => l_contract_rec.khr_id,
                            x_rcvble_amt => l_contract_rec.remaining_amount);

    --code for setting credit_indicator
    IF (SIGN(l_contract_rec.remaining_amount) = -1) THEN
      l_contract_rec.credit_indicator := 'Debit';
    ELSE
      l_contract_rec.credit_indicator := 'Credit';
    END IF;

    x_contract_rec := l_contract_rec;
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
  END get_contract_payment_info;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_case_owner
  ---------------------------------------------------------------------------
  PROCEDURE get_case_owner(
     p_cas_id                    IN NUMBER,
     x_owner_resource_id         OUT NOCOPY NUMBER,
     x_resource_name             OUT NOCOPY VARCHAR2,
     x_resource_phone            OUT NOCOPY VARCHAR2,
     x_resource_email            OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

     CURSOR l_resource_csr(cp_cas_id IN NUMBER) IS
     SELECT ica.owner_resource_id
           ,jre.source_name
           ,jre.source_phone
           ,jre.source_email
     FROM iex_cases_all_b ica
        ,jtf_rs_resource_extns jre
    WHERE ica.cas_id = cp_cas_id
    AND ica.owner_resource_id = jre.resource_id;
  BEGIN
    FOR cur IN l_resource_csr(p_cas_id) LOOP
      x_owner_resource_id := cur.owner_resource_id;
      x_resource_name := cur.source_name;
      x_resource_phone := cur.source_phone;
      x_resource_email := cur.source_email;
      EXIT;
    END LOOP;
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
  END get_case_owner;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_assets
  ---------------------------------------------------------------------------
  PROCEDURE get_assets(
     p_contract_id               IN NUMBER,
     x_oiav_tbl                  OUT NOCOPY oiav_tbl_type,
     x_return_status             OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
     l_oiav_rec                 oiav_rec_type;
     l_oiav_tbl                 oiav_tbl_type;
     i                          NUMBER := 0;

     CURSOR l_top_line_csr(cp_contract_id IN NUMBER) IS
     SELECT ols.lty_code
           ,okl.id
     FROM okc_k_lines_v okl
         ,okc_line_styles_b ols
     WHERE okl.dnz_chr_id = cp_contract_id
     AND okl.lse_id = ols.id
     AND ols.lty_code = 'FREE_FORM1';

     CURSOR l_model_csr(cp_top_line_id IN NUMBER) IS
     SELECT name
           ,description
           ,asset_id
           ,asset_number
           ,original_cost
           ,tag_number
           ,manufacturer_name
           ,model_number
           ,asset_type
     FROM okx_assets_v oka
         ,(select oki.object1_id1
                 ,oki.object1_id2
           FROM okc_k_items_v oki
               ,(SELECT ols.lty_code, okl.id
                 FROM okc_k_lines_v okl
                     ,okc_line_styles_b ols
                 WHERE okl.cle_id = cp_top_line_id
                 AND okl.lse_id = ols.id
                 AND ols.lty_code = 'FIXED_ASSET') fa
           WHERE oki.cle_id = fa.id) oi
     WHERE oka.id1 = TO_NUMBER(oi.object1_id1)
     AND oka.id2 = oi.object1_id2;

     CURSOR l_install_base_csr(cp_top_line_id IN NUMBER) IS
     SELECT oii.instance_number
           ,oii.serial_number
           ,oii.quantity
           ,oii.install_location_id
     FROM okx_install_items_v oii
         ,(SELECT oki.object1_id1
                 ,oki.object1_id2
           FROM okc_k_items_v oki
               ,(SELECT ols.lty_code
                       ,okl.id
                 FROM okc_k_lines_v okl
                     ,okc_line_styles_b ols
                     ,(SELECT ols.lty_code, okl.id
                       FROM okc_k_lines_v okl
                           ,okc_line_styles_b ols
                       WHERE okl.cle_id = cp_top_line_id
                       AND okl.lse_id = ols.id
                       AND ols.lty_code = 'FREE_FORM2') ff2
                 WHERE okl.cle_id = ff2.id
                 AND okl.lse_id = ols.id
                 AND ols.lty_code = 'INST_ITEM') ii
           WHERE oki.cle_id = ii.id) oi
     WHERE id1 = TO_NUMBER(oi.object1_id1)
     AND id2 = oi.object1_id2;

     CURSOR l_location_csr(cp_location_id IN NUMBER) IS
     SELECT hl.country
           ,hl.address1
           ,hl.address2
           ,hl.address3
           ,hl.address4
           ,hl.city
           ,hl.postal_code
           ,hl.state
           ,hl.province
           ,hl.county
           ,hl.po_box_number
           ,hl.house_number
           ,hl.street_suffix
           ,hl.apartment_number
           ,hl.street
           ,hl.rural_route_number
           ,hl.street_number
           ,hl.building
           ,hl.floor
           ,hl.suite
           ,hl.room
           ,hl.postal_plus4_code
     FROM hz_locations hl
         ,(SELECT location_id
           FROM hz_party_sites
           WHERE party_site_id = cp_location_id) hps
     WHERE hl.location_id = hps.location_id;
  BEGIN
    x_oiav_tbl.delete;
    FOR cur_top_line_csr IN l_top_line_csr(p_contract_id) LOOP
      l_oiav_rec.khr_id := p_contract_id;
      FOR cur_model_csr IN l_model_csr(cur_top_line_csr.id) LOOP
        l_oiav_rec.asset_id := cur_model_csr.asset_id;
        l_oiav_rec.asset_number := cur_model_csr.asset_number;
        l_oiav_rec.description := cur_model_csr.description;
        l_oiav_rec.asset_type := cur_model_csr.asset_type;
        l_oiav_rec.manufacturer_name := cur_model_csr.manufacturer_name;
        l_oiav_rec.model_number := cur_model_csr.model_number;
        l_oiav_rec.tag_number := cur_model_csr.tag_number;
        l_oiav_rec.original_cost := cur_model_csr.original_cost;
      END LOOP;

      FOR cur_install_base_csr IN l_install_base_csr(cur_top_line_csr.id) LOOP
        l_oiav_rec.instance_number := cur_install_base_csr.instance_number;
        l_oiav_rec.serial_number := cur_install_base_csr.serial_number;
        l_oiav_rec.quantity := cur_install_base_csr.quantity;
        FOR cur_location_csr in l_location_csr(cur_install_base_csr.install_location_id) LOOP
          l_oiav_rec.country := cur_location_csr.country;
          l_oiav_rec.address1 := cur_location_csr.address1;
          l_oiav_rec.address2 := cur_location_csr.address2;
          l_oiav_rec.address3 := cur_location_csr.address3;
          l_oiav_rec.address4 := cur_location_csr.address4;
          l_oiav_rec.city := cur_location_csr.city;
          l_oiav_rec.postal_code := cur_location_csr.postal_code;
          l_oiav_rec.state := cur_location_csr.state;
          l_oiav_rec.province := cur_location_csr.province;
          l_oiav_rec.county := cur_location_csr.county;
          l_oiav_rec.po_box_number := cur_location_csr.po_box_number;
          l_oiav_rec.house_number := cur_location_csr.house_number;
          l_oiav_rec.street_suffix := cur_location_csr.street_suffix;
          l_oiav_rec.apartment_number := cur_location_csr.apartment_number;
          l_oiav_rec.street := cur_location_csr.street;
          l_oiav_rec.rural_route_number := cur_location_csr.rural_route_number;
          l_oiav_rec.street_number := cur_location_csr.street_number;
          l_oiav_rec.building := cur_location_csr.building;
          l_oiav_rec.floor := cur_location_csr.floor;
          l_oiav_rec.suite := cur_location_csr.suite;
          l_oiav_rec.room := cur_location_csr.room;
          l_oiav_rec.postal_plus4_code := cur_location_csr.postal_plus4_code;
        END LOOP; --location loop
        i := i + 1;
        x_oiav_tbl(i) := l_oiav_rec;
      END LOOP; --install base loop

    END LOOP; --top line loop

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
  END get_assets;




---------------------------------------------------
----------- API BODY-----------------------------
----------------------------------------------------
       ---- Party Merge

       PROCEDURE OKL_OPEN_INT_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS
--
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_OPEN_INT_PARTY_MERGE';
   l_count                      NUMBER(10)   := 0;
--
BEGIN
--
   fnd_file.put_line(fnd_file.log, 'OKL_OPEN_INT.OKL_OPEN_INT_PARTY_MERGE');
--
   arp_message.set_line('OKL_OPEN_INT.OKL_OPEN_INT_PARTY_MERGE()+');

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


--
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_OPEN_INT',FALSE);
--
--
  UPDATE OKL_OPEN_INT opi
  SET opi.party_ID = p_to_fk_id
     ,opi.object_version_number = opi.object_version_number + 1
     ,opi.last_update_date      = SYSDATE
     ,opi.last_updated_by       = arp_standard.profile.user_id
     ,opi.last_update_login     = arp_standard.profile.last_update_login
  WHERE opi.party_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));
--
  exception
    when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
--
	     fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_OPEN_INT for = '|| p_from_id));
--
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_OPEN_INT_PARTY_MERGE ;

END OKL_OPI_PVT;

/
