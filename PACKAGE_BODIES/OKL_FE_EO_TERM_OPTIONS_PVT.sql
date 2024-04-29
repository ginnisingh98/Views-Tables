--------------------------------------------------------
--  DDL for Package Body OKL_FE_EO_TERM_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_EO_TERM_OPTIONS_PVT" AS
/* $Header: OKLREOTB.pls 120.12 2008/03/28 22:07:26 asahoo noship $ */

-- exceptions used
G_EXCEPTION_EO_NOTFOUND         exception;
G_EXCEPTION_VERSION_NOTFOUND    exception;
INVALID_START_DATE              exception;
EXCEPTION_ITEM_REPEAT           exception;

rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
rosetta_g_mistake_date2 date := to_date('01/01/-4711', 'MM/DD/SYYYY');
rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

-- this is to workaround the JDBC bug regarding IN DATE of value GMiss
function rosetta_g_miss_date_in_map(d date) return date as
begin
  if (d = rosetta_g_mistake_date or d=rosetta_g_mistake_date2) then return fnd_api.g_miss_date; end if;
  return d;
end;


PROCEDURE get_item_lines(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_end_of_term_id   IN  NUMBER,
                            p_version          IN  VARCHAR2,
                            x_eto_tbl          OUT NOCOPY okl_eto_tbl) AS

l_end_of_term_ver_id NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'get_item_lines';
i                    NUMBER :=0;

CURSOR eo_term_exists IS
select 1 from okl_fe_eo_terms_all_b
where end_of_term_id= p_end_of_term_id;

CURSOR eo_term_ver_csr(p_end_of_term_id NUMBER, p_version VARCHAR2) IS
select end_of_term_ver_id from okl_fe_eo_term_vers
where end_of_term_id= p_end_of_term_id and version_number= p_version;

CURSOR eo_term_objects_csr(p_end_of_term_ver_id NUMBER) IS
SELECT  END_OF_TERM_OBJ_ID,
        OBJECT_VERSION_NUMBER,
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        CATEGORY_SET_ID,
        CATEGORY_ID,
        RESI_CATEGORY_SET_ID,
        END_OF_TERM_VER_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_EO_TERM_OBJECTS WHERE END_OF_TERM_VER_ID = p_end_of_term_ver_id;

BEGIN
    -- Check if the po id exists
    OPEN eo_term_exists;
    IF eo_term_exists%NOTFOUND THEN
        RAISE G_EXCEPTION_EO_NOTFOUND;
    ELSE
        CLOSE eo_term_exists;
    END IF;

    -- Get the version id of the po for a particular version
    OPEN eo_term_ver_csr(p_end_of_term_id, p_version) ;
    IF eo_term_ver_csr%NOTFOUND THEN
        RAISE G_EXCEPTION_VERSION_NOTFOUND;
    ELSE
        FETCH eo_term_ver_csr INTO l_end_of_term_ver_id;
        CLOSE eo_term_ver_csr;
    END IF;

    -- fetch the lines
    FOR eot_objects_tbl IN  eo_term_objects_csr(l_end_of_term_ver_id)
    LOOP
        x_eto_tbl(i).END_OF_TERM_OBJ_ID     := eot_objects_tbl.END_OF_TERM_OBJ_ID;
        x_eto_tbl(i).OBJECT_VERSION_NUMBER  := eot_objects_tbl.OBJECT_VERSION_NUMBER;
        x_eto_tbl(i).ORGANIZATION_ID        := eot_objects_tbl.ORGANIZATION_ID;
        x_eto_tbl(i).INVENTORY_ITEM_ID      := eot_objects_tbl.INVENTORY_ITEM_ID;
        x_eto_tbl(i).CATEGORY_SET_ID        := eot_objects_tbl.CATEGORY_SET_ID;
        x_eto_tbl(i).CATEGORY_ID            := eot_objects_tbl.CATEGORY_ID;
        x_eto_tbl(i).RESI_CATEGORY_SET_ID   := eot_objects_tbl.RESI_CATEGORY_SET_ID;
        x_eto_tbl(i).END_OF_TERM_VER_ID     := eot_objects_tbl.END_OF_TERM_VER_ID;
        x_eto_tbl(i).ATTRIBUTE_CATEGORY     := eot_objects_tbl.ATTRIBUTE_CATEGORY;
        x_eto_tbl(i).ATTRIBUTE1             := eot_objects_tbl.ATTRIBUTE1;
        x_eto_tbl(i).ATTRIBUTE2             := eot_objects_tbl.ATTRIBUTE2;
        x_eto_tbl(i).ATTRIBUTE3             := eot_objects_tbl.ATTRIBUTE3;
        x_eto_tbl(i).ATTRIBUTE4             := eot_objects_tbl.ATTRIBUTE4;
        x_eto_tbl(i).ATTRIBUTE5             := eot_objects_tbl.ATTRIBUTE5;
        x_eto_tbl(i).ATTRIBUTE6             := eot_objects_tbl.ATTRIBUTE6;
        x_eto_tbl(i).ATTRIBUTE7             := eot_objects_tbl.ATTRIBUTE7;
        x_eto_tbl(i).ATTRIBUTE8             := eot_objects_tbl.ATTRIBUTE8;
        x_eto_tbl(i).ATTRIBUTE9             := eot_objects_tbl.ATTRIBUTE9;
        x_eto_tbl(i).ATTRIBUTE10            := eot_objects_tbl.ATTRIBUTE10;
        x_eto_tbl(i).ATTRIBUTE11            := eot_objects_tbl.ATTRIBUTE11;
        x_eto_tbl(i).ATTRIBUTE12            := eot_objects_tbl.ATTRIBUTE12;
        x_eto_tbl(i).ATTRIBUTE13            := eot_objects_tbl.ATTRIBUTE13;
        x_eto_tbl(i).ATTRIBUTE14            := eot_objects_tbl.ATTRIBUTE14;
        x_eto_tbl(i).ATTRIBUTE15            := eot_objects_tbl.ATTRIBUTE15;
        x_eto_tbl(i).CREATED_BY             := eot_objects_tbl.CREATED_BY;
        x_eto_tbl(i).CREATION_DATE          := eot_objects_tbl.CREATION_DATE;
        x_eto_tbl(i).LAST_UPDATED_BY        := eot_objects_tbl.LAST_UPDATED_BY;
        x_eto_tbl(i).LAST_UPDATE_DATE       := eot_objects_tbl.LAST_UPDATE_DATE;
        x_eto_tbl(i).LAST_UPDATE_LOGIN      := eot_objects_tbl.LAST_UPDATE_LOGIN;
        i := i+1;
    END LOOP;

exception
    when G_EXCEPTION_EO_NOTFOUND then
        IF eo_term_exists%ISOPEN THEN
            CLOSE eo_term_exists;
        END IF;
        -- have to set that the po is not found
        x_return_status := OKL_API.G_RET_STS_ERROR;
    when G_EXCEPTION_VERSION_NOTFOUND THEN
        IF eo_term_ver_csr%ISOPEN THEN
            CLOSE eo_term_ver_csr;
        END IF;
        -- have to set the message that version is not found
        x_return_status := OKL_API.G_RET_STS_ERROR;
    when others then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PVT'
        );
END get_item_lines;
-- Get the values of the Purchase Options
PROCEDURE get_eo_term_values(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_end_of_term_id   IN NUMBER,
                            p_version          IN VARCHAR2,
                            x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS
l_end_of_term_ver_id NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'get_purchase_option_values';
i                    NUMBER :=0;

CURSOR eot_exists IS
select 1 from okl_fe_eo_terms_all_b
where end_of_term_id= p_end_of_term_id;

CURSOR end_of_term_ver_csr(p_end_of_term_id NUMBER, p_po_version VARCHAR2) IS
select end_of_term_ver_id from okl_fe_eo_term_vers
where end_of_term_id= p_end_of_term_id and version_number= p_version;

CURSOR eo_term_values_csr(p_version_id NUMBER) IS
SELECT  END_OF_TERM_VALUE_ID,
        OBJECT_VERSION_NUMBER,
        EOT_TERM,
        EOT_VALUE,
        END_OF_TERM_VER_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_EO_TERM_VALUES WHERE end_OF_TERM_VER_ID = p_version_id;

BEGIN
    -- Check if the po id exists
    OPEN eot_exists;
    IF eot_exists%NOTFOUND THEN
        RAISE G_EXCEPTION_EO_NOTFOUND;
    ELSE
        CLOSE eot_exists;
    END IF;

    -- Get the version id of the po for a particular version
    OPEN end_of_term_ver_csr(p_end_of_term_id, p_version) ;
    IF end_of_term_ver_csr%NOTFOUND THEN
        RAISE G_EXCEPTION_VERSION_NOTFOUND;
    ELSE
        FETCH end_of_term_ver_csr INTO l_end_of_term_ver_id;
        CLOSE end_of_term_ver_csr;
    END IF;

    -- fetch the lines
    FOR eot_values_tbl IN  eo_term_values_csr(l_end_of_term_ver_id)
    LOOP
        x_etv_tbl(i).END_OF_TERM_VALUE_ID   := eot_values_tbl.END_OF_TERM_VALUE_ID;
        x_etv_tbl(i).OBJECT_VERSION_NUMBER  := eot_values_tbl.OBJECT_VERSION_NUMBER;
        x_etv_tbl(i).EOT_TERM               := eot_values_tbl.EOT_TERM;
        x_etv_tbl(i).EOT_VALUE              := eot_values_tbl.EOT_VALUE;
        x_etv_tbl(i).END_OF_TERM_VER_ID      := eot_values_tbl.END_OF_TERM_VER_ID;
        x_etv_tbl(i).ATTRIBUTE_CATEGORY     := eot_values_tbl.ATTRIBUTE_CATEGORY;
        x_etv_tbl(i).ATTRIBUTE1             := eot_values_tbl.ATTRIBUTE1;
        x_etv_tbl(i).ATTRIBUTE2             := eot_values_tbl.ATTRIBUTE2;
        x_etv_tbl(i).ATTRIBUTE3             := eot_values_tbl.ATTRIBUTE3;
        x_etv_tbl(i).ATTRIBUTE4             := eot_values_tbl.ATTRIBUTE4;
        x_etv_tbl(i).ATTRIBUTE5             := eot_values_tbl.ATTRIBUTE5;
        x_etv_tbl(i).ATTRIBUTE6             := eot_values_tbl.ATTRIBUTE6;
        x_etv_tbl(i).ATTRIBUTE7             := eot_values_tbl.ATTRIBUTE7;
        x_etv_tbl(i).ATTRIBUTE8             := eot_values_tbl.ATTRIBUTE8;
        x_etv_tbl(i).ATTRIBUTE9             := eot_values_tbl.ATTRIBUTE9;
        x_etv_tbl(i).ATTRIBUTE10            := eot_values_tbl.ATTRIBUTE10;
        x_etv_tbl(i).ATTRIBUTE11            := eot_values_tbl.ATTRIBUTE11;
        x_etv_tbl(i).ATTRIBUTE12            := eot_values_tbl.ATTRIBUTE12;
        x_etv_tbl(i).ATTRIBUTE13            := eot_values_tbl.ATTRIBUTE13;
        x_etv_tbl(i).ATTRIBUTE14            := eot_values_tbl.ATTRIBUTE14;
        x_etv_tbl(i).ATTRIBUTE15            := eot_values_tbl.ATTRIBUTE15;
        x_etv_tbl(i).CREATED_BY             := eot_values_tbl.CREATED_BY;
        x_etv_tbl(i).CREATION_DATE          := eot_values_tbl.CREATION_DATE;
        x_etv_tbl(i).LAST_UPDATED_BY        := eot_values_tbl.LAST_UPDATED_BY;
        x_etv_tbl(i).LAST_UPDATE_DATE       := eot_values_tbl.LAST_UPDATE_DATE;
        x_etv_tbl(i).LAST_UPDATE_LOGIN      := eot_values_tbl.LAST_UPDATE_LOGIN;
        i := i+1;
    END LOOP;
EXCEPTION
    when G_EXCEPTION_EO_NOTFOUND then
        IF eot_exists%ISOPEN THEN
            CLOSE eot_exists;
        END IF;
        -- have to set that the po is not found
        x_return_status := OKL_API.G_RET_STS_ERROR;
    when G_EXCEPTION_VERSION_NOTFOUND THEN
        IF end_of_term_ver_csr%ISOPEN THEN
            CLOSE end_of_term_ver_csr;
        END IF;
        -- have to set the message that version is not found
        x_return_status := OKL_API.G_RET_STS_ERROR;
    when others then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PVT'
        );

END get_eo_term_values;

-- Get the Purchase Option Header, Version, values and Values
PROCEDURE get_end_of_term_option(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_eot_id           IN  NUMBER,
                            p_version          IN  VARCHAR2,
                            x_ethv_rec         OUT NOCOPY okl_ethv_rec,
                            x_eve_rec          OUT NOCOPY okl_eve_rec,
                            x_eto_tbl          OUT NOCOPY okl_eto_tbl,
                            x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS

l_record_flag BOOLEAN:= false;
l_api_name VARCHAR2(3):='get_end_of_term_option';

CURSOR eot_hdr_csr(p_eot_id   NUMBER) IS
SELECT  END_OF_TERM_ID,
        OBJECT_VERSION_NUMBER,
        END_OF_TERM_NAME,
        END_OF_TERM_DESC,
        ORG_ID,
        CURRENCY_CODE,
        EOT_TYPE_CODE,
        PRODUCT_ID,
        CATEGORY_TYPE_CODE,
        ORIG_END_OF_TERM_ID,
        STS_CODE,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_EO_TERMS_V WHERE END_OF_TERM_ID=p_eot_id;

CURSOR eot_version_csr(p_eot_id NUMBER, p_eot_version VARCHAR2) IS
SELECT  END_OF_TERM_VER_ID,
        OBJECT_VERSION_NUMBER,
        VERSION_NUMBER,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE,
        STS_CODE,
        END_OF_TERM_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_EO_TERM_VERS WHERE END_OF_TERM_ID= p_eot_id and version_number=p_eot_version;
BEGIN

    -- get the end of term header
    OPEN eot_hdr_csr(p_eot_id);
    FETCH eot_hdr_csr INTO x_ethv_rec;
    CLOSE eot_hdr_csr;

    -- get the end of term versions
    OPEN eot_version_csr(p_eot_id, p_version);
    FETCH eot_version_csr INTO x_eve_rec;
    CLOSE eot_version_csr;

    -- get the Purchase Option lines
    get_item_lines( p_api_version,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_eot_id,
                    p_version,
                    x_eto_tbl);

    -- get the Purchase Option Values
    get_eo_term_values(
                    p_api_version,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_eot_id,
                    p_version,
                    x_etv_tbl);



exception
    when others then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
            l_api_name,
            G_PKG_NAME,
            'OTHERS',
            x_msg_count,
            x_msg_data,
            '_PVT'
        );

END get_end_of_term_option;
--viselvar 4604059 start
-- Checks if the percent values lie in the range 0-100
PROCEDURE validate_percent_values(p_etv_tbl IN okl_etv_tbl) IS
BEGIN
  FOR i IN p_etv_tbl.FIRST..p_etv_tbl.LAST
  LOOP
    IF p_etv_tbl(i).eot_value > 100 THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                        p_msg_name      => 'OKL_INVALID_VALUE',
                        p_token1        => OKL_API.G_COL_NAME_TOKEN,
                        p_token1_value  => 'Term ' || p_etv_tbl(i).eot_term );
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;
  END LOOP;
END;
--viselvar 4604059 end
-- Function to validate if the chosen objects (items, item categories or residual categorie sets)
-- are available in item residuals
FUNCTION val_avail_item_residual(
    p_version_id IN NUMBER
    )RETURN VARCHAR2 IS

-- cursor to fetch the objects for that particular version
CURSOR eot_objects_csr(p_version_id IN NUMBER) IS
SELECT end_of_term_obj_id,
       inventory_item_id ,
       organization_id,
       category_set_id,
       category_id,
       resi_category_set_id
FROM OKL_FE_EO_TERM_OBJECTS
WHERE end_of_term_ver_id = p_version_id;

-- cursor to fetch the residual type and the currency from the header
CURSOR eot_hdr_csr(p_version_id IN NUMBER) IS
SELECT  end_of_term_id,
        eot_type_code,
        currency_code,
        category_type_code
FROM OKL_FE_EO_TERM_VERS_V
WHERE end_of_term_ver_id = p_version_id;

-- cursor to see id the records are available
CURSOR count_csr(p_version_id IN NUMBER,l_eot_type_code IN VARCHAR2, l_currency_code IN VARCHAR2) IS
SELECT count(*) FROM(
SELECT inventory_item_id ,
       organization_id,
       category_set_id,
       category_id,
       resi_category_set_id
FROM OKL_FE_EO_TERM_OBJECTS
WHERE end_of_term_ver_id = p_version_id
MINUS
SELECT inventory_item_id ,
       organization_id,
       category_set_id,
       category_id,
       resi_category_set_id
FROM OKL_FE_ITEM_RESIDUAL_ALL
WHERE (residual_type_code= 'PERCENT' and
residual_type_code=l_eot_type_code ) OR (residual_type_code = 'AMOUNT' and
residual_type_code=l_eot_type_code and currency_code =l_currency_code)
);

CURSOR source_meaning_csr(source_code IN VARCHAR2) IS
SELECT meaning from fnd_lookups where lookup_type='OKL_SOURCE_TYPES'
and lookup_code=source_code;

l_eto_tbl         okl_eto_tbl;
i                 NUMBER := 1;
l_end_of_term_id  NUMBER;
l_end_of_type_code VARCHAR2(30);
l_currency_code    VARCHAR2(30);
l_return_status   VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
l_count           NUMBER;
l_category_type_code VARCHAR2(30);
l_type_meaning    VARCHAR2(30);

BEGIN

  -- fetch the residual type and the currency from the header
  OPEN eot_hdr_csr(p_version_id);
  FETCH eot_hdr_csr INTO l_end_of_term_id, l_end_of_type_code, l_currency_code, l_category_type_code;
  CLOSE eot_hdr_csr;

  IF (l_end_of_type_code = 'RESIDUAL_AMOUNT' OR l_end_of_type_code = 'RESIDUAL_PERCENT') THEN
  -- fetch the objects for the given version number
  FOR l_objects_rec IN eot_objects_csr(p_version_id) LOOP
    l_eto_tbl(i).end_of_term_obj_id := l_objects_rec.end_of_term_obj_id;
    l_eto_tbl(i).inventory_item_id  := l_objects_rec.inventory_item_id;
    l_eto_tbl(i).category_set_id    := l_objects_rec.category_set_id;
    l_eto_tbl(i).category_id        := l_objects_rec.category_id;
    l_eto_tbl(i).resi_category_set_id:= l_objects_rec.resi_category_set_id;
    i:= i+1;
  END LOOP;

  IF (l_end_of_type_code = 'RESIDUAL_AMOUNT') THEN
    l_end_of_type_code:='AMOUNT';
  ELSIF(l_end_of_type_code = 'RESIDUAL_PERCENT') THEN
    l_end_of_type_code:='PERCENT';
  END IF;

  OPEN count_csr(p_version_id,l_end_of_type_code,l_currency_code);
  FETCH count_csr INTO l_count;
  CLOSE count_csr;

  OPEN source_meaning_csr(l_category_type_code);
  FETCH source_meaning_csr INTO l_type_meaning;
  CLOSE source_meaning_csr;

  IF (l_count <> 0) THEN
     l_return_status := OKL_API.G_RET_STS_ERROR;
     OKL_API.SET_MESSAGE(p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_FE_VALIDATE_EOT',
                         p_token1        => 'SOURCE',
                         p_token1_value  => l_type_meaning);
   END IF;

  END IF;
  return l_return_status;
  -- have to set a message
END val_avail_item_residual;

-- Method to end date the referenced Lease Rate Set that uses this PO version
PROCEDURE calculate_start_date(
                        p_api_version    IN  NUMBER,
                        p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        p_eve_rec        IN  okl_eve_rec,
                        x_cal_eff_from   OUT NOCOPY DATE) IS

-- cursor to calculate the maximum end date referenced in quote
-- the cursor to be modified as the quotes table is not finalized
CURSOR qq_date_csr(p_eot_version_id IN NUMBER) IS
SELECT max(expected_start_date) FROM okl_quick_quotes_b WHERE end_of_term_option_id=p_eot_version_id;

CURSOR lq_date_csr(p_eot_version_id IN NUMBER) IS
SELECT max(expected_start_date) FROM okl_lease_quotes_b WHERE end_of_term_option_id=p_eot_version_id;

CURSOR lrs_qq_date_csr(p_eot_version_id IN NUMBER) IS
SELECT max(expected_start_date) FROM okl_quick_quotes_b WHERE rate_card_id in
(select rate_set_version_id from OKL_FE_RATE_SET_VERSIONS where end_of_term_ver_id = p_eot_version_id);

CURSOR lrs_lq_date_csr(p_eot_version_id IN NUMBER) IS
SELECT max(expected_start_date) FROM okl_lease_quotes_b WHERE rate_card_id in
(select rate_set_version_id from OKL_FE_RATE_SET_VERSIONS where end_of_term_ver_id = p_eot_version_id);

-- cursor to fetch the start date and the end of the previous version
CURSOR prev_ver_csr(p_eot_id IN NUMBER, p_ver_number IN VARCHAR2) IS
SELECT effective_from_date, effective_to_date FROM okl_fe_eo_term_vers where end_of_term_id= p_eot_id
AND version_number= p_ver_number-1;

TYPE l_start_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

l_eve_rec       okl_eve_rec := p_eve_rec;
l_api_name      VARCHAR2(40):= 'calculate_end_date';
l_api_version   NUMBER      := 1.0;
l_eff_from      DATE;
l_eff_to        DATE;
l_start_date    l_start_date_type;
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_max_start_date DATE;
i               NUMBER;

BEGIN
    l_return_status := OKL_API.start_activity(l_api_name
                           ,g_pkg_name
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN prev_ver_csr(l_eve_rec.end_of_term_id, l_eve_rec.version_number);
    FETCH prev_ver_csr INTO l_eff_from, l_eff_to;

    IF (prev_ver_csr%FOUND) THEN
      -- if the effective to date of the previous version is not null

      IF (l_eff_to IS NOT NULL) THEN
        l_max_start_date := l_eff_to + 1;
      ELSE
        l_max_start_date := l_eff_from + 1;
      END IF;
    ELSE
       l_max_start_date:= okl_api.g_miss_date;
    END IF;
    CLOSE prev_ver_csr;

    IF (l_eff_to is null) THEN
        -- calculate the maximum start date
        OPEN qq_date_csr(l_eve_rec.end_of_term_ver_id);
        FETCH qq_date_csr INTO l_start_date(1);
        CLOSE qq_date_csr;

        OPEN lq_date_csr(l_eve_rec.end_of_term_ver_id);
        FETCH lq_date_csr INTO l_start_date(2);
        CLOSE lq_date_csr;

        OPEN lrs_qq_date_csr(l_eve_rec.end_of_term_ver_id);
        FETCH lrs_qq_date_csr INTO l_start_date(3);
        CLOSE lrs_qq_date_csr;

        OPEN lrs_lq_date_csr(l_eve_rec.end_of_term_ver_id);
        FETCH lrs_lq_date_csr INTO l_start_date(3);
        CLOSE lrs_lq_date_csr;

	FOR i IN l_start_date.FIRST .. l_start_date.LAST LOOP
            IF (l_start_date(i) IS NOT NULL AND (l_start_date(i)+1) > l_max_start_date) THEN
            l_max_start_date:= l_start_date(i)+1;
            END IF;
        END LOOP;
    END IF;


    -- assign the max start date to the out parameter
    x_cal_eff_from := l_max_start_date;

    --end activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := l_return_status;


exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
END calculate_start_date;

-- Create a End of Term option
PROCEDURE insert_end_of_term_option(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_ethv_rec         IN  okl_ethv_rec,
                            p_eve_rec          IN  okl_eve_rec,
                            p_eto_tbl          IN  okl_eto_tbl,
                            p_etv_tbl          IN  okl_etv_tbl,
                            x_ethv_rec         OUT NOCOPY okl_ethv_rec,
                            x_eve_rec          OUT NOCOPY okl_eve_rec,
                            x_eto_tbl          OUT NOCOPY okl_eto_tbl,
                            x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS

    l_api_name      CONSTANT VARCHAR2(40)   := 'insert_end_of_term_option';
    l_api_version   CONSTANT NUMBER         := 1.0;
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ethv_rec      okl_ethv_rec:= p_ethv_rec;
    l_eve_rec       okl_eve_rec := p_eve_rec;
    l_eto_tbl       okl_eto_tbl := p_eto_tbl;
    l_etv_tbl       okl_etv_tbl := p_etv_tbl;
    i               NUMBER;
    l_dummy_var     VARCHAR2(1):='?';

    CURSOR eot_unique_chk(p_name  IN  varchar2) IS
      SELECT 'x'
      FROM   okl_fe_eo_terms_v
      WHERE  end_of_term_name = UPPER(p_name);



BEGIN
    l_return_status := OKL_API.start_activity(l_api_name
                           ,g_pkg_name
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN eot_unique_chk(l_ethv_rec.end_of_term_name);
    FETCH eot_unique_chk INTO l_dummy_var ;
    CLOSE eot_unique_chk;

    -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_DUPLICATE_NAME'
                         ,p_token1       =>  'NAME'
                         ,p_token1_value =>  l_ethv_rec.end_of_term_name);
       RAISE okl_api.g_exception_error;

    END IF;

    --Added category_type_code condition by dcshanmu for bug 6699555
    IF ((l_ethv_rec.eot_type_code ='AMOUNT' OR l_ethv_rec.eot_type_code ='PERCENT') AND (l_ethv_rec.category_type_code <> 'NONE')) THEN
      IF (l_etv_tbl.COUNT = 0) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_ST_IRS_RESIDUALS_MISSING');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    l_eve_rec.effective_to_date := rosetta_g_miss_date_in_map(l_eve_rec.effective_to_date);

    -- set the header properties
    l_ethv_rec.end_of_term_name := upper(l_ethv_rec.end_of_term_name);
    l_ethv_rec.STS_CODE:='NEW';
    l_ethv_rec.effective_from_date := l_eve_rec.effective_from_date;
    l_ethv_rec.effective_to_date := l_eve_rec.effective_to_date;
    -- viselvar 4604059 start
    IF (l_ethv_rec.eot_type_code ='PERCENT' or l_ethv_rec.eot_type_code ='RESIDUAL_PERCENT') THEN
      l_ethv_rec.currency_code:= null;
    END IF;
    -- viselvar 4604059 end

    -- insert the header record
    okl_eth_pvt.insert_row(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_ethv_rec       => l_ethv_rec,
                            x_ethv_rec       => x_ethv_rec
                            );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set the version record attributes
    l_eve_rec.VERSION_NUMBER := '1';
    l_eve_rec.STS_CODE:= 'NEW';
    l_eve_rec.END_OF_TERM_ID := x_ethv_rec.END_OF_TERM_ID;

    -- insert the version record into the table
    okl_eve_pvt.insert_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_eve_rec       => l_eve_rec,
                            x_eve_rec       => x_eve_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Added if condition by dcshanmu for bug 6699555
    --Objects and Term Values table will not be present for source type 'NONE'
    IF(l_ethv_rec.category_type_code <> 'NONE') THEN

	    --populate the foreign key for the lines table
	    IF (l_eto_tbl.COUNT >0) then
		i:= l_eto_tbl.FIRST;
		LOOP
		    l_eto_tbl(i).END_OF_TERM_VER_ID  := x_eve_rec.END_OF_TERM_VER_ID;
		    EXIT WHEN (i= l_eto_tbl.LAST);
		    i := l_eto_tbl.NEXT(i);
		END LOOP;
	    END IF;
	    -- insert the lines record into the database
	    okl_eto_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_eto_tbl       => l_eto_tbl,
				    x_eto_tbl       => x_eto_tbl);

	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
		raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
		raise OKL_API.G_EXCEPTION_ERROR;
	    END IF;

	    -- populate the foreign key for the values table
	    IF (l_etv_tbl.COUNT > 0) then
		i:= l_etv_tbl.FIRST;
		LOOP
		    l_etv_tbl(i).END_OF_TERM_VER_ID := x_eve_rec.END_OF_TERM_VER_ID;
		    EXIT WHEN (i= l_etv_tbl.LAST);
		    i:= l_etv_tbl.NEXT(i);
		END LOOP;
		IF (x_ethv_rec.eot_type_code ='AMOUNT' OR x_ethv_rec.eot_type_code ='PERCENT' ) THEN
		--viselvar 4604059 start
		-- validate the Values of terms
		IF x_ethv_rec.eot_type_code = 'PERCENT' THEN
		  validate_percent_values(l_etv_tbl);
		END IF;
		--viselvar 4604059 end
		-- insert the values record into the database
		okl_etv_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_etv_tbl       => l_etv_tbl,
				    x_etv_tbl       => x_etv_tbl);

		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
		  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
		  raise OKL_API.G_EXCEPTION_ERROR;
		END IF;

		END IF;
	    END IF;
    END IF; --Added by dcshanmu for bug 6699555

exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');


END insert_end_of_term_option;

PROCEDURE update_end_of_term_option(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_eve_rec          IN  okl_eve_rec,
                            p_eto_tbl          IN  okl_eto_tbl,
                            p_etv_tbl          IN  okl_etv_tbl,
                            x_eve_rec          OUT NOCOPY okl_eve_rec,
                            x_eto_tbl          OUT NOCOPY okl_eto_tbl,
                            x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS

l_eve_rec   okl_eve_rec := p_eve_rec;
l_eto_tbl   okl_eto_tbl := p_eto_tbl;
l_etv_tbl   okl_etv_tbl := p_etv_tbl;
l_ethv_rec  okl_ethv_rec;
x_ethv_rec  okl_ethv_rec;
i               NUMBER:= 0;
l_api_name      VARCHAR2(40) := 'update_end_of_term_option';
l_api_version   NUMBER := 1.0;
l_init_msg_list VARCHAR2(1):= p_init_msg_list;
residual_type   VARCHAR2(30);
l_eff_from      DATE;
l_eff_to        DATE;
l_lat_act_ver   VARCHAR2(24);
cal_eff_from    DATE;
x_obj_tbl       invalid_object_tbl;
j               NUMBER;
lp_lrtv_tbl     okl_lrs_id_tbl;

CURSOR latest_active_ver_csr(p_eot_id IN NUMBER) IS
SELECT max(version_number) FROM okl_fe_eo_term_vers
WHERE end_of_term_id=p_eot_id and sts_code='ACTIVE';

l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
cal_end_date DATE;
BEGIN
    l_return_status := OKL_API.start_activity(l_api_name
                           ,g_pkg_name
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);

    l_eve_rec.effective_to_date := rosetta_g_miss_date_in_map(l_eve_rec.effective_to_date);

    -- assign the in records to the out records
    x_eve_rec := p_eve_rec;
    x_eto_tbl := p_eto_tbl;
    x_etv_tbl := p_etv_tbl;

    IF (l_eve_rec.version_number >1 and l_eve_rec.STS_CODE ='NEW') THEN
        calculate_start_date(
                  l_api_version
                 ,l_init_msg_list
                 ,l_return_status
                 ,x_msg_count
                 ,x_msg_data
                 ,l_eve_rec
                 ,cal_eff_from);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF ( l_eve_rec.effective_from_date < cal_eff_from ) THEN
            RAISE INVALID_START_DATE;
        END IF;
    END IF;

    -- if the status of the version is new, then the version record can be modified
    -- objects can be modified or added
    -- term value pairs can be added or modified
    IF (l_eve_rec.STS_CODE='NEW') THEN
        IF (l_eve_rec.VERSION_NUMBER = 1) THEN
            l_ethv_rec.end_of_term_id := l_eve_rec.end_of_term_id;
            l_ethv_rec.effective_from_date := l_eve_rec.effective_from_date;
            okl_eth_pvt.update_row(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_ethv_rec       => l_ethv_rec,
                            x_ethv_rec       => x_ethv_rec
                            );
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            END IF;

        END IF;
        -- update the version record
        okl_eve_pvt.update_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_eve_rec       => l_eve_rec,
                            x_eve_rec       => x_eve_rec);

        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
        END IF;

       --Added if condition by dcshanmu for bug 6699555
       --Objects and Term Values table will not be present for source type 'NONE'
       --Commenting out the check for 'NONE' condition as UI is not passing the value
       --This check is already done UI layer. Fix for bug#6892431
       -- IF(l_ethv_rec.category_type_code <> 'NONE') THEN

		-- update the lines table
		IF (l_eto_tbl.COUNT >0) then
		    i := l_eto_tbl.FIRST;
		    LOOP
		    IF (l_eto_tbl(i).END_OF_TERM_OBJ_ID is not null) THEN
			okl_eto_pvt.update_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_eto_rec       => l_eto_tbl(i),
				    x_eto_rec       => x_eto_tbl(i));

			IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
			    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
			    raise OKL_API.G_EXCEPTION_ERROR;
			END IF;

		    ELSIF (l_eto_tbl(i).END_OF_TERM_OBJ_ID is null ) THEN

			l_eto_tbl(i).END_OF_TERM_VER_ID  := x_eve_rec.END_OF_TERM_VER_ID;

			okl_eto_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_eto_rec       => l_eto_tbl(i),
				    x_eto_rec       => x_eto_tbl(i));

			IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
			    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
			    raise OKL_API.G_EXCEPTION_ERROR;
			END IF;

		    END IF;
		    EXIT WHEN (i= l_eto_tbl.LAST);
		    i := l_eto_tbl.NEXT(i);
		    END LOOP;
		END IF;
		-- update the values table
		IF (l_etv_tbl.COUNT >0) then
		    i := l_etv_tbl.FIRST;
		    --viselvar 4604059 start
		    -- validate the Values of terms
		    IF x_ethv_rec.eot_type_code = 'PERCENT' THEN
		       validate_percent_values(l_etv_tbl);
		    END IF;
		    --viselvar 4604059 end
		    LOOP
		    IF (l_etv_tbl(i).END_OF_TERM_VALUE_ID is not null) THEN
			okl_etv_pvt.update_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_etv_rec       => l_etv_tbl(i),
				    x_etv_rec       => x_etv_tbl(i));
			IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
			    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
			    raise OKL_API.G_EXCEPTION_ERROR;
			END IF;

		    ELSIF (l_etv_tbl(i).END_OF_TERM_VALUE_ID is null) THEN
			l_etv_tbl(i).END_OF_TERM_VER_ID  := x_eve_rec.END_OF_TERM_VER_ID;

			okl_etv_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_etv_rec       => l_etv_tbl(i),
				    x_etv_rec       => x_etv_tbl(i));

			IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
			    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
			    raise OKL_API.G_EXCEPTION_ERROR;
			END IF;

		    END IF;
		    EXIT WHEN (i= l_etv_tbl.LAST);
		    i := l_etv_tbl.NEXT(i);
		END LOOP;

	    END IF;
    --END IF; --Added by dcshanmu for bug 6699555. Commenting out the END IF.

    ELSIF (l_eve_rec.STS_CODE = 'ACTIVE') THEN
        OPEN latest_active_ver_csr(l_eve_rec.END_OF_TERM_ID);
        FETCH latest_active_ver_csr INTO l_lat_act_ver;
        CLOSE latest_active_ver_csr;

    IF (l_eve_rec.effective_to_date IS NOT NULL) THEN
         -- end date the lease rate set versions
         INVALID_OBJECTS(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_version_id    => l_eve_rec.end_of_term_ver_id,
                        x_obj_tbl       => x_obj_tbl
                        );

         IF (x_obj_tbl.COUNT >0) THEN
            FOR j IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
               lp_lrtv_tbl(j) := x_obj_tbl(j).obj_id;
            END LOOP;

            okl_lease_rate_Sets_pvt.enddate_lease_rate_set(
             p_api_version
            ,p_init_msg_list
            ,l_return_status
            ,x_msg_count
            ,x_msg_data
            ,lp_lrtv_tbl
            ,l_eve_rec.effective_to_date
            );
          END IF;
     END IF;
        IF (l_eve_rec.version_number = l_lat_act_ver) THEN
            -- update the header record
            -- viselvar 4604059 start
            l_ethv_rec.EFFECTIVE_TO_DATE := l_eve_rec.EFFECTIVE_TO_DATE;
            -- viselvar 4604059 end
            l_ethv_rec.END_OF_TERM_ID:= l_eve_rec.end_of_term_id;
            okl_eth_pvt.update_row(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_ethv_rec       => l_ethv_rec,
                            x_ethv_rec       => x_ethv_rec
                            );
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- update the version record
            okl_eve_pvt.update_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_eve_rec       => l_eve_rec,
                            x_eve_rec       => x_eve_rec);

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END IF;

        --Added if condition by dcshanmu for bug 6699555
        --Objects table will not be present for source type 'NONE'
        --Commenting out the check for 'NONE' condition as UI is not passing the value
        --This check is already done UI layer. Fix for bug#6892431
        --IF(l_ethv_rec.category_type_code <> 'NONE') THEN

	 -- add only objects if the status is active
         FOR i IN l_eto_tbl.FIRST .. l_eto_tbl.LAST LOOP
          IF (l_eto_tbl(i).END_OF_TERM_OBJ_ID IS NULL) THEN
            l_eto_tbl(i).END_OF_TERM_VER_ID  := l_eve_rec.END_OF_TERM_VER_ID;
            okl_eto_pvt.insert_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_eto_rec       => l_eto_tbl(i),
                            x_eto_rec       => x_eto_tbl(i));

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;
         END LOOP;
	--END IF; --Added by dcshanmu for bug 6699555 Commenting out END IF.
    END IF;

    exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');

    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');

END update_end_of_term_option;

-- create version for the end of term option
PROCEDURE create_version(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_eve_rec          IN  okl_eve_rec,
                            p_eto_tbl          IN  okl_eto_tbl,
                            p_etv_tbl          IN  okl_etv_tbl,
                            x_eve_rec          OUT NOCOPY okl_eve_rec,
                            x_eto_tbl          OUT NOCOPY okl_eto_tbl,
                            x_etv_tbl          OUT NOCOPY okl_etv_tbl) AS

l_eve_rec   okl_eve_rec := p_eve_rec;
l_eto_tbl   okl_eto_tbl := p_eto_tbl;
l_etv_tbl   okl_etv_tbl := p_etv_tbl;
l_ethv_rec  okl_ethv_rec;
x_ethv_rec  okl_ethv_rec;
l_prev_ver_rec  okl_eve_rec;
x_prev_ver_rec  okl_eve_rec;
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
residual_type   VARCHAR2(30);
i               NUMBER := 0;
l_api_name      VARCHAR2(40) := 'create_version';
l_api_version   NUMBER := 1.0;
l_cal_eff_from  DATE;

BEGIN
    l_return_status := OKL_API.start_activity(l_api_name
                           ,g_pkg_name
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);

    l_eve_rec.effective_to_date := rosetta_g_miss_date_in_map(l_eve_rec.effective_to_date);
    calculate_start_date(
                 p_api_version   ,
                 p_init_msg_list ,
                 l_return_status ,
                 x_msg_count     ,
                 x_msg_data      ,
                 l_eve_rec       ,
                 l_cal_eff_from );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_eve_rec.effective_from_date < l_cal_eff_from ) THEN
        RAISE INVALID_START_DATE;
    END IF;

    l_ethv_rec.sts_code:= 'UNDER_REVISION';
    l_ethv_rec.end_of_term_id  := l_eve_rec.end_of_term_id;

    okl_eth_pvt.update_row(
                            p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => l_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_ethv_rec       => l_ethv_rec,
                            x_ethv_rec       => x_ethv_rec
                            );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- insert the version record into the table
    okl_eve_pvt.insert_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => l_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_eve_rec       => l_eve_rec,
                            x_eve_rec       => x_eve_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --Added if condition by dcshanmu for bug 6699555
   --Objects and Term Values table will not be present for source type 'NONE'
   -- asahoo l_ethv_rec.category_code is not passed from UI. Hence getting from x_ethv_rec for bug#6892431
   IF(x_ethv_rec.category_type_code <> 'NONE') THEN

	    --populate the foreign key for the lines table
	    IF (l_eto_tbl.COUNT >0) then
		i:= l_eto_tbl.FIRST;
		LOOP
		    l_eto_tbl(i) := p_eto_tbl(i);
		    l_eto_tbl(i).END_OF_TERM_VER_ID  := x_eve_rec.END_OF_TERM_VER_ID;
		    EXIT WHEN (i= l_eto_tbl.LAST);
		    i := l_eto_tbl.NEXT(i);
		END LOOP;
	    END IF;
	    -- insert the lines record into the database
	    okl_eto_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_eto_tbl       => l_eto_tbl,
				    x_eto_tbl       => x_eto_tbl);
	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
		raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
		raise OKL_API.G_EXCEPTION_ERROR;
	    END IF;

	    -- populate the foreign key for the values table
	    IF (l_etv_tbl.COUNT > 0) then
		i:= l_etv_tbl.FIRST;
		LOOP
		    l_etv_tbl(i) := p_etv_tbl(i);
		    l_etv_tbl(i).END_OF_TERM_VER_ID := x_eve_rec.END_OF_TERM_VER_ID;
		    EXIT WHEN (i= l_etv_tbl.LAST);
		    i:= l_etv_tbl.NEXT(i);
		END LOOP;
	    END IF;
	    --viselvar 4604059 start
	    -- validate the Values of terms
	    IF x_ethv_rec.eot_type_code = 'PERCENT' THEN
		validate_percent_values(l_etv_tbl);
	    END IF;
	    --viselvar 4604059 end
	    -- insert the values record into the database
	    okl_etv_pvt.insert_row(
				    p_api_version   => p_api_version,
				    p_init_msg_list => p_init_msg_list,
				    x_return_status => l_return_status,
				    x_msg_count     => x_msg_count,
				    x_msg_data      => x_msg_data,
				    p_etv_tbl       => l_etv_tbl,
				    x_etv_tbl       => x_etv_tbl);

	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
		raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
		raise OKL_API.G_EXCEPTION_ERROR;
	    END IF;

	END IF; --Added by dcshanmu for bug 6699555

exception
    WHEN INVALID_START_DATE THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_INVALID_EFF_FROM',
                            p_token1       => 'DATE',
                            p_token1_value => l_cal_eff_from);
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
END create_version;

PROCEDURE validate_end_of_term_option(
                            p_api_version    IN  NUMBER,
                            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            p_end_of_ver_id IN  NUMBER
                            ) AS


l_eto_tbl   okl_eto_tbl;
l_api_name  VARCHAR2(40) := 'validate_end_of_term_option';
l_eot_type  VARCHAR2(30);
l_cat_code  VARCHAR2(30);
i           NUMBER := 0;
j           NUMBER;
int_count   NUMBER;

CURSOR cat_type_code_csr(p_end_of_term_ver_id IN NUMBER) IS
SELECT category_type_code,eot_type_code FROM OKL_FE_EO_TERMS_V hdr, OKL_FE_EO_TERM_VERS ver
WHERE hdr.end_of_term_id = ver.end_of_term_id  AND ver.end_of_term_ver_id = p_end_of_term_ver_id;

CURSOR objects_csr(p_end_of_term_ver_id IN NUMBER) IS
SELECT inventory_item_id, organization_id, category_id, category_set_id, resi_category_set_id
FROM OKL_FE_EO_TERM_OBJECTS
WHERE end_of_term_ver_id=p_end_of_term_ver_id;

cursor repeat_csr(id1 NUMBER, id2 NUMBER) is
select count(*) from
(
select organization_id, inventory_item_id, category_id, category_set_id
from OKL_FE_RESI_CAT_OBJECTS where resi_category_set_id = id1
intersect
select organization_id, inventory_item_id, category_id, category_set_id
from OKL_FE_RESI_CAT_OBJECTS where resi_category_set_id = id2
);

BEGIN

    -- If the residual type is 'residual category set', then we need to check for items repeating
    -- in that residual amount
    OPEN cat_type_code_csr(p_end_of_ver_id);
    FETCH cat_type_code_csr INTO l_cat_code,l_eot_type;
    CLOSE cat_type_code_csr;

    FOR l_objects_rec IN objects_csr(p_end_of_ver_id) LOOP
        l_eto_tbl(i).inventory_item_id:=l_objects_rec.inventory_item_id;
        l_eto_tbl(i).organization_id  :=l_objects_rec.organization_id;
        l_eto_tbl(i).category_id      :=l_objects_rec.category_id;
        l_eto_tbl(i).category_set_id  :=l_objects_rec.category_set_id;
        l_eto_tbl(i).resi_category_set_id :=l_objects_rec.resi_category_set_id;
    END LOOP;

    IF( l_eto_tbl.COUNT> 0) then
        i := l_eto_tbl.FIRST;
        IF (l_cat_code= 'RESIDUAL_CAT_SET') and
           (l_eot_type='RESIDUAL_AMOUNT' or l_eot_type='RESIDUAL_PERCENT') then
            FOR i IN l_eto_tbl.FIRST..l_eto_tbl.LAST-1 LOOP
                FOR j IN i+1..l_eto_tbl.LAST LOOP
                    OPEN repeat_csr(l_eto_tbl(i).resi_category_set_id, l_eto_tbl(j).resi_category_set_id);
                    FETCH repeat_csr into int_count;
                    CLOSE repeat_csr;
                    IF (int_count > 0) THEN
                        RAISE EXCEPTION_ITEM_REPEAT;
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
    END IF;
exception
    WHEN EXCEPTION_ITEM_REPEAT THEN
      null;
    WHEN OTHERS THEN
      IF (repeat_csr%ISOPEN) then
        CLOSE repeat_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
END validate_end_of_term_option;

PROCEDURE handle_approval(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_end_of_term_ver_id  IN NUMBER) AS
cal_end_date    DATE;
l_eve_rec       okl_eve_rec ;
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_ERROR;
x_eve_rec       okl_eve_rec;
l_ethv_rec      okl_ethv_rec;
x_ethv_rec      okl_ethv_rec;
l_eff_from      DATE;
l_eff_to        DATE;
l_ver_number    VARCHAR2(24);
l_eot_id        NUMBER;
l_api_name      VARCHAR2(40) := 'handle_approval';
l_api_version   NUMBER := 1.0;
l_cal_eff_from  DATE;
l_prev_ver_id   NUMBER;
l_prev_ver_eff_to DATE;
l_prev_eve_rec  okl_eve_rec;
x_prev_eve_rec  okl_eve_rec;
x_obj_tbl       invalid_object_tbl;
i               NUMBER;
lp_lrtv_tbl     okl_lrs_id_tbl;

-- cursor to get the data of the versions record
CURSOR eot_versions_csr(p_ver_id IN NUMBER) IS
SELECT  END_OF_TERM_ID,
        VERSION_NUMBER,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE
FROM OKL_FE_EO_TERM_VERS WHERE END_OF_TERM_VER_ID=p_ver_id;

CURSOR ver_eff_to_csr(p_eot_id IN NUMBER, p_version_number IN NUMBER)IS
SELECT  END_OF_TERM_VER_ID,
        EFFECTIVE_TO_DATE FROM okl_fe_eo_term_vers
WHERE END_OF_TERM_ID=p_eot_id and VERSION_NUMBER = p_version_number;

BEGIN
l_return_status := OKL_API.start_activity(l_api_name
                           ,g_pkg_name
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
END IF;

l_return_status := val_avail_item_residual(p_end_of_term_ver_id);
IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
END IF;

-- fetch thte details of the versions record and populate them into versions record
OPEN eot_versions_csr(p_end_of_term_ver_id);
FETCH eot_versions_csr INTO l_eot_id,l_ver_number,l_eff_from, l_eff_to;
CLOSE eot_versions_csr;

-- set the properties of the versions record
l_eve_rec.STS_CODE:='ACTIVE';
l_eve_rec.END_OF_TERM_VER_ID:= p_end_of_term_ver_id;
l_eve_rec.END_OF_TERM_ID:= l_eot_id;
l_eve_rec.VERSION_NUMBER:= l_ver_number;
l_eve_rec.EFFECTIVE_FROM_DATE:=l_eff_from;

IF (l_eff_to is not null) THEN
  l_eve_rec.EFFECTIVE_TO_DATE:=l_eff_to;
ELSE
  l_eve_rec.EFFECTIVE_TO_DATE:= OKL_API.G_MISS_DATE;
END IF;

IF (l_eve_rec.VERSION_NUMBER >1 ) THEN
    calculate_start_date(
                     p_api_version   ,
                     p_init_msg_list ,
                     l_return_status ,
                     x_msg_count     ,
                     x_msg_data      ,
                     l_eve_rec       ,
                     l_cal_eff_from );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_eve_rec.effective_from_date < l_cal_eff_from ) THEN
        RAISE INVALID_START_DATE;
    END IF;

    OPEN ver_eff_to_csr(l_eot_id,l_ver_number-1);
    FETCH ver_eff_to_csr INTO l_prev_ver_id,l_prev_ver_eff_to;
    CLOSE ver_eff_to_csr;

    l_prev_eve_rec.end_of_term_ver_id:=l_prev_ver_id;
    l_prev_eve_rec.effective_to_date:=l_eve_rec.effective_from_date-1;

    -- end date the lease rate set versions
    INVALID_OBJECTS(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_version_id    => l_prev_ver_id,
                        x_obj_tbl       => x_obj_tbl
                        );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (x_obj_tbl.COUNT >0) THEN
    FOR i IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
       lp_lrtv_tbl(i) := x_obj_tbl(i).obj_id;
    END LOOP;

    okl_lease_rate_Sets_pvt.enddate_lease_rate_set(
     p_api_version
    ,p_init_msg_list
    ,l_return_status
    ,x_msg_count
    ,x_msg_data
    ,lp_lrtv_tbl
    ,l_prev_eve_rec.effective_to_date
    );
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- update the previous version record
    okl_eve_pvt.update_row(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_eve_rec       => l_prev_eve_rec,
                        x_eve_rec       => x_prev_eve_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

END IF;

-- update the version record
okl_eve_pvt.update_row(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_eve_rec       => l_eve_rec,
                        x_eve_rec       => x_eve_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
END IF;
-- change the status in the header record also as active for search purcpose only
l_ethv_rec.sts_code:= 'ACTIVE';
l_ethv_rec.end_of_term_id := x_eve_rec.end_of_term_id;

IF (l_eve_rec.EFFECTIVE_TO_DATE is not null) THEN
    l_ethv_rec.EFFECTIVE_TO_DATE :=x_eve_rec.EFFECTIVE_TO_DATE;
ELSE
    l_ethv_rec.EFFECTIVE_TO_DATE :=OKL_API.G_MISS_DATE;
END IF;
okl_eth_pvt.update_row(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => l_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_ethv_rec       => l_ethv_rec,
                       x_ethv_rec       => x_ethv_rec
                       );
IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
     raise OKL_API.G_EXCEPTION_ERROR;
END IF;

-- make the change to the previous 0.

exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');

    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                      ( l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');


END handle_approval;
PROCEDURE INVALID_OBJECTS(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_version_id    IN  NUMBER,
                        x_obj_tbl       OUT NOCOPY invalid_object_tbl
                        )AS

-- cursor to calculate the  LRS objects which are referncing this adjustment matrix
CURSOR lrs_invalids_csr(p_version_id IN NUMBER) IS
SELECT vers.RATE_SET_VERSION_ID ID,hdr.name NAME,vers.version_number VERSION_NUMBER
FROM OKL_FE_RATE_SET_VERSIONS vers, OKL_LS_RT_FCTR_SETS_V hdr
WHERE  vers.rate_set_id = hdr.id AND vers.end_of_term_ver_id=p_version_id
AND vers.STS_CODE='ACTIVE';

l_version_id    NUMBER :=p_version_id;
i               NUMBER:=1;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='invalid_objects';
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;

BEGIN

x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            p_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

FOR lrs_invalid_record IN lrs_invalids_csr(p_version_id) LOOP
    x_obj_tbl(i).obj_id :=lrs_invalid_record.id;
    x_obj_tbl(i).obj_name:=lrs_invalid_record.NAME;
    x_obj_tbl(i).obj_version :=lrs_invalid_record.VERSION_NUMBER;
    x_obj_tbl(i).obj_type:='LRS';
    i:=i+1;
END LOOP;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END INVALID_OBJECTS;

PROCEDURE submit_end_of_term(
                            p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_end_of_term_ver_id  IN NUMBER) AS

l_eve_rec       okl_eve_rec;
x_eve_rec       okl_eve_rec;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='submit_end_of_term';
l_init_msg_list VARCHAR2(1):=p_init_msg_list;
l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_parameter_list        wf_parameter_list_t;
p_event_name varchar2(240):='oracle.apps.okl.fe.eotapproval';
l_profile_value varchar2(30);

  -- Cursor to check if the residual category sets are active before Activating the Item Residual
  -- Pass the Item Residual Identifier and the Status as ACTIVE to check for Inactive Residual Category Sets
  CURSOR check_active_resi_cat_sets(p_itm_rsdl_id NUMBER, p_rcs_sts_code VARCHAR2) IS
    SELECT
             RCSV.RESI_CATEGORY_SET_ID ID
           , RCSV.RESI_CAT_NAME        NAME
      FROM
            OKL_FE_RESI_CAT_V RCSV
          , OKL_FE_ITEM_RESIDUAL IRESDV
      WHERE
            IRESDV.CATEGORY_TYPE_CODE   = 'RESCAT'
        AND IRESDV.RESI_CATEGORY_SET_ID = RCSV.RESI_CATEGORY_SET_ID
        AND RCSV.STS_CODE               <> p_rcs_sts_code
        AND IRESDV.item_residual_id     = p_itm_rsdl_id;

   l_eot_id NUMBER;
   l_source_type OKL_FE_ITEM_RESIDUAL_ALL.CATEGORY_TYPE_CODE%TYPE;
   l_rcs_rec  check_active_resi_cat_sets%ROWTYPE;

   CURSOR get_eot_id(p_ver_id IN NUMBER) IS
   SELECT  END_OF_TERM_ID
   FROM OKL_FE_EO_TERM_VERS WHERE END_OF_TERM_VER_ID=p_ver_id;

   CURSOR get_source_type(p_eot_id IN NUMBER)IS
   SELECT EOT_TYPE_CODE
   FROM OKL_FE_EO_TERMS_V where end_of_term_id= p_eot_id;
BEGIN
l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            l_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

l_return_status := val_avail_item_residual(p_end_of_term_ver_id);
IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
    raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) then
    raise OKL_API.G_EXCEPTION_ERROR;
END IF;
 OPEN get_eot_id(p_end_of_term_ver_id);
   FETCH get_eot_id INTO l_eot_id;
 CLOSE get_eot_id;

 OPEN get_source_type (l_eot_id);
   FETCH get_source_type INTO l_source_type;
 CLOSE get_source_type;

  IF l_source_type = 'RESCAT' THEN
    OPEN check_active_resi_cat_sets(l_eot_id,'ACTIVE');
      FETCH check_active_resi_cat_sets INTO l_rcs_rec;
      IF check_active_resi_cat_sets%FOUND THEN
      LOOP
        OKL_API.set_message(p_app_name      => G_APP_NAME,
                               p_msg_name      => 'OKL_RCS_STS_INACTIVE',
                               p_token1        => OKL_API.G_COL_NAME_TOKEN,
                               p_token1_value  => l_rcs_rec.name);
         FETCH check_active_resi_cat_sets INTO l_rcs_rec;
         EXIT WHEN check_active_resi_cat_sets%NOTFOUND;
       END LOOP;
       RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     CLOSE check_active_resi_cat_sets;
    END IF;

l_eve_rec.end_of_term_ver_id := p_end_of_term_ver_id;
l_eve_rec.STS_CODE := 'SUBMITTED';

okl_eve_pvt.update_row(   l_api_version
                          ,p_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_eve_rec
                          ,x_eve_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
fnd_profile.get('OKL_PE_APPROVAL_PROCESS',l_profile_value);

 IF (nvl(l_profile_value,'NONE') = 'NONE') THEN

HANDLE_APPROVAL(
                p_api_version   => l_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_end_of_term_ver_id    => p_end_of_term_ver_id
                );

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
ELSE
-- raise the business event passing the version id added to the parameter list
wf_event.AddParameterToList('VERSION_ID',p_end_of_term_ver_id,l_parameter_list);
--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);
OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
			    p_init_msg_list  => p_init_msg_list,
			    x_return_status  => x_return_status,
			    x_msg_count      => x_msg_count,
			    x_msg_data       => x_msg_data,
			    p_event_name     => p_event_name,
			    p_parameters     => l_parameter_list);



END IF;


--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
end submit_end_of_term;
END OKL_FE_EO_TERM_OPTIONS_PVT;

/
