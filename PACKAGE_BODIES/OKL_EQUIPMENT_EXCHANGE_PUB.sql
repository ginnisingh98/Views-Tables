--------------------------------------------------------
--  DDL for Package Body OKL_EQUIPMENT_EXCHANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EQUIPMENT_EXCHANGE_PUB" AS
/* $Header: OKLPEQXB.pls 115.3 2004/04/13 10:44:23 rnaik noship $ */

 FUNCTION GET_TAS_HDR_REC
        (p_thpv_tbl IN thpv_tbl_type
        ,p_no_data_found                OUT NOCOPY BOOLEAN
        ) RETURN thpv_tbl_type
 AS
    l_thpv_tbl                     thpv_tbl_type;
 BEGIN

    l_thpv_tbl := okl_equipment_exchange_pvt.get_tas_hdr_rec(p_thpv_tbl,p_no_data_found);

    RETURN l_thpv_tbl;

 END GET_TAS_HDR_REC;

 FUNCTION get_status
        (p_status_code  IN      VARCHAR2)
        RETURN VARCHAR2
 AS
    l_status    VARCHAR2(80);

 BEGIN

    l_status  := okl_equipment_exchange_pvt.get_status(p_status_code);

    RETURN l_status;
 END get_status;


 FUNCTION get_tal_rec
        (p_talv_tbl                     IN talv_tbl_type,
        x_no_data_found                OUT NOCOPY BOOLEAN)
         RETURN talv_tbl_type
 AS
    l_talv_tbl      talv_tbl_type;
 BEGIN

    l_talv_tbl  := okl_equipment_exchange_pvt.get_tal_rec(p_talv_tbl,x_no_data_found);

    RETURN l_talv_tbl;
 END get_tal_rec;

 FUNCTION get_vendor_name
        (p_vendor_id  IN      VARCHAR2)
        RETURN VARCHAR2
 AS
    l_vdr_name  VARCHAR2(80);
 BEGIN
    l_vdr_name  := okl_equipment_exchange_pvt.get_vendor_name(p_vendor_id);

    RETURN l_vdr_name;
 END get_vendor_name;


 FUNCTION get_item_rec (
    p_itiv_tbl                     IN itiv_tbl_type,
    x_no_data_found                OUT NOCOPY BOOLEAN) RETURN itiv_tbl_type
 AS
    l_itiv_tbl itiv_tbl_type;

 BEGIN
    l_itiv_tbl  := okl_equipment_exchange_pvt.get_item_rec(p_itiv_tbl,x_no_data_found);

    RETURN l_itiv_tbl;
 END get_item_rec;


 FUNCTION get_exchange_type
        (p_tas_id  IN      NUMBER)
        RETURN VARCHAR2
 AS
    l_exchange_type     VARCHAR2(60);

 BEGIN
    l_exchange_type := okl_equipment_exchange_pvt.get_exchange_type(p_tas_id);

    RETURN l_exchange_type;

END get_exchange_type;



  PROCEDURE update_serial_number(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
       p_instance_id                    IN  NUMBER,
       p_instance_name                  IN  VARCHAR2,
       p_serial_number                  IN  VARCHAR2,
       p_inventory_item_id              IN  NUMBER,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2)
  AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);


  BEGIN

    --SAVEPOINT update_serial_number;






  ------------ Call to Private Process API--------------

    okl_equipment_exchange_pvt.update_serial_number (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                   p_instance_id      => p_instance_id,
                                                   p_instance_name    => p_instance_name,
                                                   p_serial_number    => p_serial_number,
                                                   p_inventory_item_id => p_inventory_item_id,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --ROLLBACK TO update_serial_number;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --ROLLBACK TO update_serial_number;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      --ROLLBACK TO update_serial_number;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_EQUIPMENT_EXCHANGE_PUB','update_serial_number');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_serial_number;

   PROCEDURE store_exchange_details (
                        p_api_version                    IN  NUMBER,
                        p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        p_thpv_tbl                       IN  thpv_tbl_type,
                        p_old_tlpv_tbl                   IN  tlpv_tbl_type,
                        p_new_tlpv_tbl                   IN  tlpv_tbl_type,
                        p_old_iipv_tbl                   IN  iipv_tbl_type,
                        p_new_iipv_tbl                   IN  iipv_tbl_type,
                        x_thpv_tbl                       OUT NOCOPY  thpv_tbl_type,
                        x_old_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
                        x_new_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
                        x_old_iipv_tbl                   OUT NOCOPY  iipv_tbl_type,
                        x_new_iipv_tbl                   OUT NOCOPY  iipv_tbl_type,
                        x_return_status                  OUT NOCOPY VARCHAR2,
                        x_msg_count                      OUT NOCOPY NUMBER,
                        x_msg_data                       OUT NOCOPY VARCHAR2)
   AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

    l_thpv_tbl               thpv_tbl_type;
    l_old_tlpv_tbl           tlpv_tbl_type;
    l_new_tlpv_tbl           tlpv_tbl_type;
    l_old_iipv_tbl           iipv_tbl_type;
    l_new_iipv_tbl           iipv_tbl_type;

  BEGIN

    --SAVEPOINT store_exchange_details;






  ------------ Call to Private Process API--------------

    okl_equipment_exchange_pvt.store_exchange_details (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                             p_thpv_tbl     => p_thpv_tbl,
                                                            p_old_tlpv_tbl  => p_old_tlpv_tbl,
                                                            p_new_tlpv_tbl  => p_new_tlpv_tbl,
                                                            p_old_iipv_tbl  => p_old_iipv_tbl,
                                                            p_new_iipv_tbl  => p_new_iipv_tbl,
                                                            x_thpv_tbl      => x_thpv_tbl,
                                                            x_old_tlpv_tbl  => x_old_tlpv_tbl,
                                                            x_new_tlpv_tbl  => x_new_tlpv_tbl,
                                                            x_old_iipv_tbl  => x_old_iipv_tbl,
                                                            x_new_iipv_tbl  => x_new_iipv_tbl,
                                                            x_return_status => l_return_status,
                                                            x_msg_count     => l_msg_count,
                                                            x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --ROLLBACK TO store_exchange_details;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --ROLLBACK TO store_exchange_details;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      --ROLLBACK TO store_exchange_details;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_EQUIPMENT_EXCHANGE_PUB','store_exchange_details');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END store_exchange_details;


   PROCEDURE exchange(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                p_tas_id                IN      NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2)
   AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    --SAVEPOINT exchange;






  ------------ Call to Private Process API--------------

    okl_equipment_exchange_pvt.exchange (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                            p_tas_id     => p_tas_id,
                                                            x_return_status => l_return_status,
                                                            x_msg_count     => l_msg_count,
                                                            x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --ROLLBACK TO exchange;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --ROLLBACK TO exchange;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      --ROLLBACK TO exchange;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_EQUIPMENT_EXCHANGE_PUB','exchange');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END exchange;


END okl_equipment_exchange_pub;

/
