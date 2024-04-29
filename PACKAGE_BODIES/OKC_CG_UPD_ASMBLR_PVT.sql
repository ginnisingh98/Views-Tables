--------------------------------------------------------
--  DDL for Package Body OKC_CG_UPD_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CG_UPD_ASMBLR_PVT" AS
/* $Header: OKCRCUAB.pls 120.2 2005/07/15 16:21:06 pnayani noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE acn_assemble(
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 ,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_counter_id	        IN NUMBER
  )  IS

 l_api_name      CONSTANT VARCHAR2(30) := 'ACN_ASSEMBLE';
 l_api_version   CONSTANT NUMBER := 1.0;
 l_init_msg_list VARCHAR2(1) ;
 i               NUMBER;
 l_corrid_rec    okc_aq_pvt.corrid_rec_typ;
 l_msg_tbl       okc_aq_pvt.msg_tab_typ;
 l_msg_count     number;
 l_msg_data      varchar2(1000);
 l_return_status varchar2(1);
 l_counter_group_id  okx_counter_groups_v.counter_group_id%TYPE;
 l_contract_id       okx_counter_groups_v.source_object_id%TYPE;


CURSOR ctr_grp_cur IS
/*R12 changes
SELECT cg.counter_group_id counter_group_id,
       cg.source_object_code source_object_code,
       cg.source_object_id source_object_id
FROM   okx_counter_grp_log_v log,
       okx_counter_groups_v cg
WHERE  log.counter_group_id = cg.counter_group_id
AND    counter_grp_log_id  =  p_counter_grp_log_id;*/
SELECT ca.source_object_code source_object_code,
       ca.source_object_id source_object_id
       FROM   csi_counter_associations ca
       WHERE  ca.counter_id  = p_counter_id;

ctr_grp_rec  ctr_grp_cur%ROWTYPE;


CURSOR ename_cur IS
SELECT aae.element_name
FROM   okc_actions_b acn,
       okc_action_attributes_b aae
WHERE  acn.id = aae.acn_id
AND    acn.correlation = 'CTR_GRP_UPD' ;
ename_rec  ename_cur%ROWTYPE;

CURSOR kl_cur (x IN NUMBER) IS
SELECT dnz_chr_id k_id
FROM   okc_k_lines_b
WHERE  id = x;
kl_rec kl_cur%ROWTYPE;

CURSOR ctr_cur IS
select net_reading counter_reading
from csi_counter_readings
where counter_id = p_counter_id
and nvl(disabled_flag,'N') = 'N'
order by value_timestamp desc;

ctr_rec ctr_cur%ROWTYPE;

BEGIN

 l_return_status := OKC_API.START_ACTIVITY
                    (l_api_name
                    ,l_init_msg_list
                    ,'_PVT'
                    ,x_return_status);

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

 l_corrid_rec.corrid := 'CTR_GRP_UPD' ;
 i := 0;

-- check if action is enabled
IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_corrid_rec.corrid) = 'Y' THEN
 l_msg_tbl   :=    okc_aq_pvt.msg_tab_typ();
 FOR ename_rec IN ename_cur
 LOOP
   OPEN ctr_grp_cur;
   FETCH ctr_grp_cur INTO ctr_grp_rec;
     IF ename_rec.element_name = 'COUNTER_ID' THEN
       l_msg_tbl.extend;
       i := i + 1;
       l_msg_tbl(i).element_name    := ename_rec.element_name;
       l_msg_tbl(i).element_value   := p_counter_id;
     ELSIF ename_rec.element_name = 'COUNTER_READING' THEN
	        OPEN ctr_cur;
	        FETCH ctr_cur INTO ctr_rec;
                l_msg_tbl.extend;
                i := i + 1;
                l_msg_tbl(i).element_name    := ename_rec.element_name;
                l_msg_tbl(i).element_value   := ctr_rec.counter_reading;
            CLOSE ctr_cur;
     ELSIF ename_rec.element_name = 'SOURCE_OBJECT_CODE' THEN
       l_msg_tbl.extend;
       i := i + 1;
       l_msg_tbl(i).element_name    := ename_rec.element_name;
       l_msg_tbl(i).element_value   := ctr_grp_rec.source_object_code;
     ELSIF ename_rec.element_name = 'SOURCE_OBJECT_ID' THEN
       l_msg_tbl.extend;
       i := i + 1;
       l_msg_tbl(i).element_name    := ename_rec.element_name;
       l_msg_tbl(i).element_value   := ctr_grp_rec.source_object_id;
     ELSIF ename_rec.element_name = 'K_ID' THEN
       IF  ctr_grp_rec.source_object_code = 'CONTRACT_LINE' AND
	   ctr_grp_rec.source_object_id IS NOT NULL THEN
	        OPEN kl_cur(ctr_grp_rec.source_object_id);
	        FETCH kl_cur INTO kl_rec;
                l_msg_tbl.extend;
                i := i + 1;
                l_msg_tbl(i).element_name    := ename_rec.element_name;
                l_msg_tbl(i).element_value   := kl_rec.k_id;
            CLOSE kl_cur;
       ELSIF  ctr_grp_rec.source_object_code = 'CP' THEN
           l_msg_tbl.extend;
           i := i + 1;
           l_msg_tbl(i).element_name    := ename_rec.element_name;
           l_msg_tbl(i).element_value   := NULL;
       ELSIF  ctr_grp_rec.source_object_code IS NULL THEN
           l_msg_tbl.extend;
           i := i + 1;
           l_msg_tbl(i).element_name    := ename_rec.element_name;
           l_msg_tbl(i).element_value   := NULL;
       END IF;
     END IF;
  CLOSE ctr_grp_cur;
 END LOOP;

  OKC_AQ_PUB.send_message(p_api_version     => l_api_version
                         ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 END IF; -- OKC_K_SIGN_ASMBLR_PVT.isActionEnabled
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
 WHEN OKC_API.G_EXCEPTION_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
 WHEN OTHERS THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT');
END acn_assemble;

END OKC_CG_UPD_ASMBLR_PVT;

/
