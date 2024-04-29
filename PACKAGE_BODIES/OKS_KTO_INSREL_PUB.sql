--------------------------------------------------------
--  DDL for Package Body OKS_KTO_INSREL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_KTO_INSREL_PUB" AS
/* $Header: OKSPOIRB.pls 120.0 2005/05/25 17:41:33 appldev noship $ */




-------------------------------------------------------------------------------
--
-- global package structures
--
-------------------------------------------------------------------------------
--
-- global constants
--
G_EXCEPTION_HALT_VALIDATION     EXCEPTION;
G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN        	        CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OC_INT_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_API_TYPE                      VARCHAR2(30)           := '_PROCESS';

L_LOG_ENABLED			VARCHAR2(200);


-------------------------------------------------------------------------------
--
-- APIs: K->O
--
-------------------------------------------------------------------------------

-- Procedure:       create_instance_rel
-- Version:         1.0
-- Purpose:         Create instance relationship  between subscription item instance
---                 and instance created from the order management



PROCEDURE create_instance_rel(ERRBUF              OUT NOCOPY VARCHAR2
			                 ,RETCODE             OUT NOCOPY NUMBER
			                 ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                              ) IS

l_api_version           CONSTANT NUMBER := 1;
lx_order_id             okx_order_headers_v.id1%TYPE := NULL;
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;
l_contract_id number;



BEGIN
  --
  -- call full version of create_instance_rel
  --

  --errorout('1');
  OKS_KTO_INSREL_PUB.create_instance_rel(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_TRUE
                                    ,p_commit        => OKC_API.G_TRUE
                                    ,x_return_status => lx_return_status
                                    ,x_msg_count     => lx_msg_count
                                    ,x_msg_data      => lx_msg_data
                                    ,p_contract_id   => p_contract_id);
      --errorout('10');

  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	IF lx_order_id IS NULL THEN
	   RETCODE := 2;
	ELSE
	   RETCODE := 1;
	END IF;
  ELSE
	RETCODE:=0;
  END IF;
  ERRBUF:=lx_msg_data;
END create_instance_rel;

--
-- full version of the procedure to create an order from a contract
--

PROCEDURE create_instance_rel(p_api_version       IN  NUMBER   DEFAULT NULL
                             ,p_init_msg_list     IN  VARCHAR2 DEFAULT NULL
                             ,p_commit            IN  VARCHAR2 DEFAULT NULL
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_msg_count         OUT NOCOPY NUMBER
                             ,x_msg_data          OUT NOCOPY VARCHAR2
                             ,p_contract_id       IN  okc_k_headers_b.ID%TYPE
                                   ) IS

l_api_name		    CONSTANT VARCHAR2(30) := 'OKS_KTO_INSREL_PUB_';
l_api_version	            CONSTANT NUMBER	  := 1;
l_commit                              VARCHAR2(1) := 'F';
l_validation_level        NUMBER  := FND_API.G_VALID_LEVEL_FULL;


cursor SUBSCR_INS(p_contract_id IN NUMBER)  is
 select ose.order_header_id
 ,ose.order_line_id
 ,osh.instance_id
 ,osh.dnz_chr_id
 from oks_subscr_elements ose,
 oks_subscr_header_b osh,
 okc_k_headers_b hdr
 where ose.osh_id=osh.id
 and osh.dnz_chr_id=hdr.id
 and hdr.id= p_contract_id
 and ose.order_header_id  is not null;


CURSOR OM_INS(p_header_id IN NUMBER) is
select oh.header_id
,ol.line_id
,cii.instance_id
,cii.inventory_item_id
,cii.last_oe_order_line_id
from
csi_item_instances cii,
oe_order_lines_all ol,
oe_order_headers_all oh
where oh.header_id=ol.header_id
and oh.header_id=p_header_id
and cii.last_oe_order_line_id = ol.line_id
and ol.flow_status_code='CLOSED'
and ol.shipped_quantity=ol.fulfilled_quantity
order by oh.header_id;

subscr_ins_rec subscr_ins%rowtype;
om_ins_rec om_ins%rowtype;
l_relationship_tbl CSI_DATASTRUCTURES_PUB.II_RELATIONSHIP_TBL;
l_txn_rec CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
l_return_status VARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
i NUMBER:=1;


BEGIN

   FOR subscr_ins_rec in subscr_ins(p_contract_id) LOOP
   FOR om_ins_rec in om_ins(subscr_ins_rec.order_header_id)  LOOP

   ---l_relationship_tbl(i).relationship_id       := NULL;
  l_relationship_tbl(i).relationship_type_code := 'COMPONENT-OF';
  l_relationship_tbl(i).object_id              := subscr_ins_rec.instance_id;
  l_relationship_tbl(i).subject_id             := om_ins_rec.instance_id;
 -- l_relationship_tbl(i).object_id              := 58988;
 -- l_relationship_tbl(i).subject_id             := 2007;
  l_relationship_tbl(i).subject_has_child      := '';
  l_relationship_tbl(i).position_reference     := '';
  l_relationship_tbl(i).active_start_date      := NULL;
  l_relationship_tbl(i).active_end_date        := NULL;
  l_relationship_tbl(i).display_order          := NULL;
  l_relationship_tbl(i).mandatory_flag         := 'N';
  l_relationship_tbl(i).object_version_number  := NULL;

  --l_txn_rec.transaction_id                     := NULL;
  l_txn_rec.transaction_date                   := sysdate;
  l_txn_rec.source_transaction_date            := sysdate;
  l_txn_rec.transaction_type_id                := 51;
  l_txn_rec.txn_sub_type_id                    := NULL;
  l_txn_rec.source_group_ref_id                := NULL;
  l_txn_rec.source_group_ref                   := '';
  l_txn_rec.source_header_ref_id               := NULL;
  l_txn_rec.source_header_ref                  := '';
  l_txn_rec.source_line_ref_id                 := NULL;
  l_txn_rec.source_line_ref                    := '';
  l_txn_rec.source_dist_ref_id1                := NULL;
  l_txn_rec.source_dist_ref_id2                := NULL;
  l_txn_rec.inv_material_transaction_id        := NULL;
  l_txn_rec.transaction_quantity               := NULL;
  l_txn_rec.transaction_uom_code               := '';
  l_txn_rec.transacted_by                      := NULL;
  l_txn_rec.transaction_status_code            := '';
  l_txn_rec.transaction_action_code            := '';
  l_txn_rec.message_id                         := NULL;
  l_txn_rec.object_version_number              := 1;
  l_txn_rec.split_reason_code                  := '';

    csi_ii_relationships_pub.create_relationship(
      	p_api_version     => 1.0,
        p_init_msg_list   => OKC_API.G_FALSE,
        p_commit          => l_commit,
        p_validation_level=> l_validation_level,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_relationship_tbl=>l_relationship_tbl,
        p_txn_rec         =>  l_txn_rec);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Return_status='||l_return_status);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Relation_ship_id='||l_relationship_tbl(i).relationship_id );

        i:=i+1;

        --errorout('return_status='||l_return_status);

IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;


   END LOOP;

  END LOOP;
  -- check return status


  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);
END create_instance_rel;



END OKS_KTO_INSREL_PUB;


/
