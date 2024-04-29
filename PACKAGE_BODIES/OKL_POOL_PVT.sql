--------------------------------------------------------
--  DDL for Package Body OKL_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POOL_PVT" AS
/* $Header: OKLRSZPB.pls 120.30 2008/02/14 05:12:07 ankushar noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
      G_STS_CODE    VARCHAR2(10) := 'NEW';

  G_REJECT_DUP_POCS          CONSTANT VARCHAR2(2) := '01';
  G_REJECT_VARIABLE_INTEREST CONSTANT VARCHAR2(2) := '02';
  G_REJECT_REV_KHR           CONSTANT VARCHAR2(2) := '03';
  G_REJECT_SPLIT_ASSET       CONSTANT VARCHAR2(2) := '04';
  G_REJECT_DELINQ_KHR        CONSTANT VARCHAR2(2) := '05';
  G_REJECT_ASSET_TERMINATED	 CONSTANT VARCHAR2(2) := '06';
  G_REJECT_LEGAL_ENTITY_MISMATCH CONSTANT VARCHAR2(2) := '07';

  G_POOL_ADD_TBL_HDR       CONSTANT VARCHAR2(30) := 'OKL_POOL_ADD_TBL_HDR';
  G_POOL_ADD_NEW_TBL_HDR CONSTANT VARCHAR2(25) := 'OKL_POOL_ADD_NEW_TBL_HDR';
  G_ROW_NUMBER                CONSTANT VARCHAR2(14) := 'OKL_ROW_NUMBER';
  G_CONTRACT_NUMBER           CONSTANT VARCHAR2(25) := 'OKL_GLP_RPT_CTR_NUM_TITLE';
  G_ASSET_NUMBER              CONSTANT VARCHAR2(16) := 'OKL_ASSET_NUMBER';
  G_LESSEE                    CONSTANT VARCHAR2(10) := 'OKL_LESSEE';
  G_STREAM_TYPE_SUBCLASS CONSTANT VARCHAR2(25) := 'OKL_STREAM_TYPE_SUBCLASS';
  G_REJECT_REASON_CODE CONSTANT VARCHAR2(25) := 'OKL_REJECT_REASON_CODE';
  G_REJECT_REASON_CODES CONSTANT VARCHAR2(25) := 'OKL_REJECT_REASON_CODES';
 -- sosharma added codes for adjustment
  G_POOL_TRX_ADD               CONSTANT VARCHAR2(30) := 'ADD';
  G_POOL_TRX_REASON_ADJUST     CONSTANT VARCHAR2(30) := 'ADJUSTMENTS';
 -- sosharma added codes for tranaction_status
   G_POOL_TRX_STATUS_NEW               CONSTANT VARCHAR2(30) := 'NEW';
   G_POOL_TRX_STATUS_APPREJ            CONSTANT VARCHAR2(30) := 'APPROVAL_REJECTED';
   G_POOL_TRX_STATUS_APPROVED          CONSTANT VARCHAR2(30) := 'APPROVED';
   G_POOL_TRX_STATUS_INCOMPLETE        CONSTANT VARCHAR2(30) := 'INCOMPLETE ';
    G_POOL_TRX_STATUS_COMPLETE        CONSTANT VARCHAR2(30) := 'COMPLETE ';

  TYPE msg_rec_type IS RECORD ( msg VARCHAR2(150) );
  TYPE msg_tbl_type IS TABLE OF msg_rec_type INDEX BY BINARY_INTEGER;

  --Added by kthiruva on 21-Nov -2007 to determine the Pool Status
  --Bug 6640050 - Start of Changes
  CURSOR pool_status_csr(p_pol_id IN NUMBER)
  IS
  SELECT status_code
  FROM   okl_pools
  WHERE  id = p_pol_id;
  --Bug 6640050 - End of Changes

  -- Cursor for getting the status of the open transaction
 CURSOR l_trans_status_csr(p_pol_id IN NUMBER)
  IS
  SELECT transaction_status,id FROM OKL_POOL_TRANSACTIONS pools
  where pools.transaction_status <> G_POOL_TRX_STATUS_COMPLETE
  and pools.transaction_type='ADD' and pools.transaction_reason='ADJUSTMENTS'
  and pools.pol_id=p_pol_id;



----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_status
-- Description     : updates a pool header, and contents' status. This utility IS
--                   used for sync 'ACTIVE', and 'EXPIRED' status only
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_status(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pool_status                  IN okl_pools.status_code%TYPE
   ,p_pol_id                       IN okl_pools.id%TYPE)
 IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_status';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_pol_id           OKL_POOLS.ID%TYPE;
  l_currency_code    OKL_POOLS.CURRENCY_CODE%TYPE;
  l_org_id           OKL_POOLS.ORG_ID%TYPE;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;
  l_poc_id           OKL_POOL_CONTENTS.ID%TYPE;

  lp_pocv_rec         pocv_rec_type;
  lx_pocv_rec         pocv_rec_type;


CURSOR c_poc IS
SELECT poc.id
FROM okl_pool_contents poc
WHERE poc.pol_id = p_pol_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_status_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
----------------------------------------------------------------------------
--1. update pool status
----------------------------------------------------------------------------
--DBMS_OUTPUT.PUT_LINE('1. update pool header status');
--DBMS_OUTPUT.PUT_LINE('OKL_POOL_PVT.update_pool start');

    lp_polv_rec.ID := p_pol_id;
    lp_polv_rec.status_code := p_pool_status;

    Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

----------------------------------------------------------------------------
--2. update pool contents status
----------------------------------------------------------------------------
--DBMS_OUTPUT.PUT_LINE('2. update pool contents status');
--DBMS_OUTPUT.PUT_LINE('OKL_POOL_PVT.update_pool_contents start');

  OPEN c_poc;
  LOOP
    FETCH c_poc INTO
                l_poc_id;
    EXIT WHEN c_poc%NOTFOUND;

    lp_pocv_rec.id := l_poc_id;
    lp_pocv_rec.status_code := p_pool_status;

    Okl_Pool_Pvt.update_pool_contents(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_pocv_rec      => lp_pocv_rec,
      x_pocv_rec      => lx_pocv_rec);

     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

  END LOOP;
  CLOSE c_poc;

--DBMS_OUTPUT.PUT_LINE('OKL_POOL_PVT.update_pool_status end');

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_status_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_status_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_status_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_status;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool
-- Description     : wrapper api for create pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_pool_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


  l_polv_rec         polv_rec_type := p_polv_rec;
--  x_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT create_pool_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      l_polv_rec.DATE_CREATED := SYSDATE;
      l_polv_rec.DATE_LAST_UPDATED := SYSDATE;
      l_polv_rec.STATUS_CODE := G_STS_CODE; -- default to 'NEW'

      Okl_Pol_Pvt.insert_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => x_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_pool_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;






      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END create_pool;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool
-- Description     : wrapper api for update pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_polv_rec         polv_rec_type := p_polv_rec;
--  x_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      l_polv_rec.DATE_LAST_UPDATED := SYSDATE;
-- 12/30/02 fixed
--      l_polv_rec.TOTAL_RECEIVABLE_AMOUNT := get_tot_receivable_amt(p_pol_id => l_polv_rec.ID);
--      l_polv_rec.TOTAL_PRINCIPAL_AMOUNT := get_tot_principal_amt(p_pol_id => l_polv_rec.ID);
--      l_polv_rec.DATE_TOTAL_PRINCIPAL_CALC := SYSDATE;


      -- fmiao 12/09/05 fix OBJECT_VERSION_NUMBER

      IF (l_polv_rec.object_version_number IS NULL) THEN
	    l_polv_rec.object_version_number :=Okl_Api.G_MISS_NUM;
	  END IF;

	  IF (l_polv_rec.date_created IS NULL) THEN
	    l_polv_rec.date_created :=Okl_Api.G_MISS_DATE;
	  END IF;

	  IF (l_polv_rec.created_by IS NULL) THEN
	    l_polv_rec.created_by :=Okl_Api.G_MISS_NUM;
	  END IF;
	  IF (l_polv_rec.creation_date IS NULL) THEN
	    l_polv_rec.creation_date :=Okl_Api.G_MISS_DATE;
	  END IF;
	  IF (l_polv_rec.last_updated_by IS NULL) THEN
	    l_polv_rec.last_updated_by :=Okl_Api.G_MISS_NUM;
	  END IF;
	  IF (l_polv_rec.last_update_date IS NULL) THEN
	    l_polv_rec.last_update_date :=Okl_Api.G_MISS_DATE;
	  END IF;
	  IF (l_polv_rec.last_update_login IS NULL) THEN
	    l_polv_rec.last_update_login :=Okl_Api.G_MISS_NUM;
	  END IF;
	  -- end fmiao 12/09/05 fix OBJECT_VERSION_NUMBER

      Okl_Pol_Pvt.update_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => x_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);





  WHEN OTHERS THEN
	ROLLBACK TO update_pool_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END update_pool;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool
-- Description     : wrapper api for delete pool
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_pool_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_polv_rec         polv_rec_type := p_polv_rec;
--  x_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT delete_pool_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      Okl_Pol_Pvt.delete_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => l_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_pool_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_pool_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END delete_pool;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_contents
-- Description     : wrapper api for create pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
   ,x_pocv_rec                     OUT NOCOPY pocv_rec_type
 )  IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type := p_pocv_rec;
--  x_pocv_rec         pocv_rec_type;
  --Added by kthiruva on 21-Nov-2007 for Bug 6640050
  l_status_code      okl_pools.status_Code%TYPE;

  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

  BEGIN
  -- Set API savepoint
  SAVEPOINT create_pool_contents_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;
  FOR pool_status_rec IN pool_status_csr(p_pocv_rec.pol_id)
  LOOP
    l_status_code := pool_status_rec.status_code;
  END LOOP;


/*** Begin API body ****************************************************/

  --Modified by kthiruva on 21-Nov-2007
  --If pool is active, new contents are created in status 'PENDING'
  -- Bug 6640050 - start of changes
  IF l_status_code = G_POL_STS_ACTIVE
  THEN
    l_pocv_rec.STATUS_CODE := G_POC_STS_PENDING;
  ELSE
    l_pocv_rec.STATUS_CODE := G_POC_STS_NEW; -- default to NEW status_code. cklee 04/14/03
  END IF;
  -- Bug 6640050 - end of changes

      Okl_Poc_Pvt.insert_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => l_pocv_rec,
        x_pocv_rec      => x_pocv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      lp_polv_rec.ID := p_pocv_rec.POL_ID;

      Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN

        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_pool_contents_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_pool_contents_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_pool_contents_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END create_pool_contents;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_contents
-- Description     : wrapper api for create pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
   ,x_pocv_tbl                     OUT NOCOPY pocv_tbl_type
 )  IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_tbl         pocv_tbl_type := p_pocv_tbl;
--  x_pocv_tbl         pocv_tbl_type;
  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT create_pool_contents_PVT2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    IF (l_pocv_tbl.COUNT > 0) THEN
      i := l_pocv_tbl.FIRST;
      LOOP

        Okl_Pool_Pvt.create_pool_contents(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_pocv_rec      => l_pocv_tbl(i),
          x_pocv_rec      => x_pocv_tbl(i));

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = l_pocv_tbl.LAST);
        i := l_pocv_tbl.NEXT(i);
      END LOOP;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_pool_contents_PVT2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_pool_contents_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_pool_contents_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END create_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_contents
-- Description     : wrapper api for update pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
   ,x_pocv_rec                     OUT NOCOPY pocv_rec_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type := p_pocv_rec;
--  x_pocv_rec         pocv_rec_type;
  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

CURSOR c_pol(p_id okl_pool_contents.id%TYPE) IS
  SELECT pol_id
FROM okl_pool_contents
WHERE id = p_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_contents_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

-- 12/30/02 fixed
      OPEN c_pol(l_pocv_rec.ID);
      FETCH c_pol INTO lp_polv_rec.ID;
      CLOSE c_pol;

      Okl_Poc_Pvt.update_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => l_pocv_rec,
        x_pocv_rec      => x_pocv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

--      lp_polv_rec.ID := p_pocv_rec.POL_ID;

      Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);


EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_contents_PVT;




    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_contents_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_contents_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_contents;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_contents
-- Description     : wrapper api for update pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
   ,x_pocv_tbl                     OUT NOCOPY pocv_tbl_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_tbl         pocv_tbl_type := p_pocv_tbl;
--  x_pocv_tbl         pocv_tbl_type;
  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_contents_PVT2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    IF (l_pocv_tbl.COUNT > 0) THEN
      i := l_pocv_tbl.FIRST;
      LOOP

        Okl_Pool_Pvt.update_pool_contents(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_pocv_rec      => l_pocv_tbl(i),
          x_pocv_rec      => x_pocv_tbl(i));

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = l_pocv_tbl.LAST);
        i := l_pocv_tbl.NEXT(i);
      END LOOP;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_contents_PVT2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_contents_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_contents_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_contents
-- Description     : wrapper api for delele pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_rec                     IN pocv_rec_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type := p_pocv_rec;
--  x_pocv_rec         pocv_rec_type;

  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

CURSOR c_pol(p_id okl_pool_contents.id%TYPE) IS
  SELECT pol_id
FROM     okl_pool_contents
WHERE    id = p_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT delete_pool_contents_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      OPEN c_pol(l_pocv_rec.ID);
      FETCH c_pol INTO lp_polv_rec.ID;
      CLOSE c_pol;

      Okl_Poc_Pvt.delete_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => l_pocv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

--      lp_polv_rec.ID := p_pocv_rec.POL_ID;

      Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_pool_contents_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_pool_contents_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_pool_contents_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END delete_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_contents
-- Description     : wrapper api for delele pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE delete_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2

   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pocv_tbl                     IN pocv_tbl_type
 ) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_tbl         pocv_tbl_type := p_pocv_tbl;
--  x_pocv_tbl         pocv_tbl_type;
  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT delete_pool_contents_pvt2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    IF (l_pocv_tbl.COUNT > 0) THEN
      i := l_pocv_tbl.FIRST;
      LOOP

        Okl_Pool_Pvt.delete_pool_contents(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,

          x_msg_data      => x_msg_data,
          p_pocv_rec      => l_pocv_tbl(i));

        IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (i = l_pocv_tbl.LAST);
        i := l_pocv_tbl.NEXT(i);
      END LOOP;

    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_pool_contents_PVT2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_pool_contents_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_pool_contents_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END delete_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_pool_transaction
-- Description     : wrapper api for create pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
   ,x_poxv_rec                     OUT NOCOPY poxv_rec_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'create_pool_transaction_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_poxv_rec         poxv_rec_type := p_poxv_rec;
--  x_poxv_rec         poxv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT create_pool_transaction_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN

    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      Okl_Pox_Pvt.insert_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_poxv_rec      => l_poxv_rec,
        x_poxv_rec      => x_poxv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_pool_transaction_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_pool_transaction_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_pool_transaction_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END create_pool_transaction;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_transaction
-- Description     : wrapper api for update pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
   ,x_poxv_rec                     OUT NOCOPY poxv_rec_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_transaction_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_poxv_rec         poxv_rec_type := p_poxv_rec;
--  x_poxv_rec         poxv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_transaction_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      Okl_Pox_Pvt.update_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_poxv_rec      => l_poxv_rec,
        x_poxv_rec      => x_poxv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/


  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_transaction_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_transaction_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_transaction_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_transaction;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_pool_transaction
-- Description     : wrapper api for delete pool transaction
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_pool_transaction(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poxv_rec                     IN poxv_rec_type
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_pool_transaction_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_poxv_rec         poxv_rec_type := p_poxv_rec;
--  x_poxv_rec         poxv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT delete_pool_transaction_pvt2;


  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      Okl_Pox_Pvt.delete_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,

        x_msg_data      => x_msg_data,
        p_poxv_rec      => l_poxv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_pool_transaction_PVT2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_pool_transaction_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_pool_transaction_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END delete_pool_transaction;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_pool_stream_amout
-- Description     : get stream elements amount from pool contents
-- Business Rules  : This amount filter by the from date and to date of pool contents
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_pool_stream_amout(
  p_poc_id IN okl_pool_contents.id%TYPE
 ) RETURN NUMBER
IS
  l_amount NUMBER;

  CURSOR c (p_poc_id  NUMBER )
  IS
SELECT
 NVL(SUM(NVL(ele.AMOUNT,0)),0) STREAM_AMOUNT
--  SUM(ele.AMOUNT) STREAM_AMOUNT --fixed cklee 06/05/2003
--for streams
FROM
      okl_streams       strm
      ,okl_strm_elements ele
      ,okl_pool_contents cnt
WHERE  strm.id       = ele.stm_id
AND    cnt.ID        = p_poc_id
-- mvasudev, 08/11/2003 , Restoring stm_id changes
--AND    strm.KHR_ID   = cnt.KHR_ID
--AND    strm.KLE_ID   = cnt.KLE_ID
--AND    strm.STY_ID   = cnt.STY_ID
AND    strm.ID   = cnt.STM_ID
AND    strm.say_code = 'CURR'
AND    strm.active_yn = 'Y'
AND    cnt.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
AND    ele.STREAM_ELEMENT_DATE
       BETWEEN cnt.STREAMS_FROM_DATE AND NVL(cnt.STREAMS_TO_DATE,G_FINAL_DATE)
  ;

BEGIN

  OPEN c (p_poc_id);
  FETCH c INTO l_amount;
  CLOSE c;

  RETURN l_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_pool_stream_amout;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_receivable_amt
-- Description     : get stream elements amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_receivable_amt(
  p_pol_id IN okl_pools.id%TYPE

 ) RETURN NUMBER
IS
  l_amount NUMBER;
  l_tot_amount NUMBER := 0;
  l_poc_id okl_pool_contents.id%TYPE;
  i NUMBER := 0;

  CURSOR c_poc (p_pol_id  NUMBER)
  IS
SELECT poc.id
FROM okl_pool_contents poc
WHERE poc.pol_id = p_pol_id
AND   poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
;

BEGIN

  OPEN c_poc (p_pol_id);
  LOOP

    FETCH c_poc INTO l_poc_id;
    EXIT WHEN c_poc%NOTFOUND;

    l_amount := get_pool_stream_amout(l_poc_id);
    l_tot_amount := l_tot_amount + l_amount;
    i := i+1;

  END LOOP;
  CLOSE c_poc;

  IF (i = 0) THEN
    l_tot_amount := NULL;
  END IF;

  RETURN l_tot_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_tot_receivable_amt;

/* ankushar - Bug 6658065
   Prcedure to return Value Of Streams for Pending Pool Transactions
   start changes
*/
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_recv_amt_for_pend
-- Description     : get stream elements amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_recv_amt_for_pend(
  p_pol_id IN okl_pools.id%TYPE

 ) RETURN NUMBER
IS
  l_amount NUMBER;
  l_tot_amount NUMBER := 0;
  l_poc_id okl_pool_contents.id%TYPE;
  i NUMBER := 0;

--Begin - Changes for bug#6658065 by VARANGAN on 30/11/2007
  CURSOR c_poc (p_pol_id  NUMBER)
  IS
SELECT poc.id
FROM okl_pool_contents poc
WHERE poc.pol_id = p_pol_id
AND   poc.status_code IN (G_POC_STS_PENDING);   -- Getting only pending POC - for Bug 6691554
--Getting only pending POC stream amounts
CURSOR c_strm_amount ( p_poc_id NUMBER)
IS
SELECT 	NVL(SUM(NVL(ele.AMOUNT,0)),0) STREAM_AMOUNT
FROM	okl_streams       strm
	,okl_strm_elements ele
	,okl_pool_contents cnt
WHERE  strm.id       = ele.stm_id
AND    cnt.ID        = p_poc_id
AND    strm.ID   = cnt.STM_ID
AND    strm.say_code = 'CURR'
AND    strm.active_yn = 'Y'
AND    cnt.status_code IN (G_POC_STS_PENDING)
AND    ele.STREAM_ELEMENT_DATE
BETWEEN cnt.STREAMS_FROM_DATE AND NVL(cnt.STREAMS_TO_DATE,G_FINAL_DATE);

l_allowed_status Varchar2(100);
l_status_code      okl_pools.status_Code%TYPE;
--End - Changes for bug#6658065 by VARANGAN on 30/11/2007
BEGIN
-- Begin - Changes for Bug#6658065
 --(1) Check the pool status
 FOR pool_status_rec IN pool_status_csr(p_pol_id)
 LOOP
	l_status_code := pool_status_rec.status_code;
 END LOOP;
 --(2)  If the Status is 'Active', then only 'Pending' status pool contents created for adjustment should be processed
  IF l_status_code = G_POL_STS_ACTIVE  THEN
	OPEN c_poc (p_pol_id);
	LOOP
		FETCH c_poc INTO l_poc_id;
		EXIT WHEN c_poc%NOTFOUND;
			OPEN c_strm_amount (l_poc_id) ;
			FETCH c_strm_amount INTO l_amount;
			CLOSE c_strm_amount;
			l_tot_amount := l_tot_amount + l_amount;
			i := i+1;
	END LOOP;
	CLOSE c_poc;
  END IF;

  IF (i = 0) THEN
    l_tot_amount := NULL;
  END IF;

  RETURN l_tot_amount;

  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_tot_recv_amt_for_pend;

----------------------------------------------------------------------------------
-- Start of comments
--

-- Procedure Name  : get_tot_recei_amt_pend
-- Description     : wrapper api for get_tot_receivable_amt_pend
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_tot_recei_amt_pend(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE

 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'get_tot_receivable_amt_pvt2';
  l_api_version      CONSTANT NUMBER       := 1.0;

  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_amount           NUMBER;

BEGIN
  -- Set API savepoint
  SAVEPOINT get_tot_recv_amt_pend_pvt2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

 x_value := get_tot_recv_amt_for_pend(p_pol_id =>p_pol_id);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,

     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO get_tot_recv_amt_pend_pvt2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_tot_recv_amt_pend_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO get_tot_recv_amt_pend_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END get_tot_recei_amt_pend;

/* ankushar - Bug 6658065
   end changes
*/
----------------------------------------------------------------------------------
-- Start of comments
--

-- Procedure Name  : get_tot_recei_amt
-- Description     : wrapper api for get_tot_receivable_amt
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_tot_recei_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE

 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'get_tot_receivable_amt_pvt2';
  l_api_version      CONSTANT NUMBER       := 1.0;

  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_amount           NUMBER;

BEGIN
  -- Set API savepoint
  SAVEPOINT get_tot_receivable_amt_pvt2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

 x_value := get_tot_receivable_amt(p_pol_id =>p_pol_id);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,

     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO get_tot_receivable_amt_pvt2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_tot_receivable_amt_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO get_tot_receivable_amt_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END get_tot_recei_amt;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_receivable_amt
-- Description     : wrapper api for get_tot_receivable_amt by investor agreement ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_tot_receivable_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_khr_id                       IN  okc_k_headers_b.id%TYPE
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'get_tot_receivable_amt_pvt2';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_pol_id           okl_pools.id%TYPE;

CURSOR c_khr(p_khr_id okc_k_headers_b.id%TYPE) IS
  SELECT ph.id
FROM okl_pools ph
WHERE ph.khr_id = p_khr_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT get_tot_receivable_amt_pvt2;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;

	END IF;



  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

  OPEN c_khr (p_khr_id);
  FETCH c_khr INTO l_pol_id;
  CLOSE c_khr;

  x_value := get_tot_receivable_amt(p_pol_id =>l_pol_id);

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO get_tot_receivable_amt_pvt2;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get


      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_tot_receivable_amt_pvt2;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO get_tot_receivable_amt_pvt2;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END get_tot_receivable_amt;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : get_tot_principal_amt
-- Description     : get asset principal amount from pool contents by okl_pools.id
-- Business Rules  :
-- Parameters      :

-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 FUNCTION get_tot_principal_amt(
  p_pol_id IN okl_pools.id%TYPE
 ) RETURN NUMBER
IS
  l_amount NUMBER := 0;
  l_tot_amount NUMBER := 0;

  l_khr_id okl_pool_contents.khr_id%TYPE;
  l_kle_id okl_pool_contents.kle_id%TYPE := NULL;
  l_start_date DATE;
  l_end_date DATE;

   l_api_version              NUMBER := 1;
   l_init_msg_list            VARCHAR2(100) := Okc_Api.G_FALSE;
   x_return_status            VARCHAR2(100);
   x_msg_count                NUMBER;
   x_msg_data                 VARCHAR2(1999);
   x_value                    NUMBER := 0;
   l_ctxt_val_tbl             Okl_Execute_Formula_Pvt.ctxt_val_tbl_type;
   l_deal_type                okl_k_headers.deal_type%TYPE;
   l_contract_number          okc_k_headers_b.contract_number%TYPE;

   l_formula_name             VARCHAR2(100);
/*
  CURSOR c_poc (p_pol_id  NUMBER)
  IS
SELECT DISTINCT poc.khr_id,
       poc.kle_id,
       DECODE(khr.deal_type, G_DEAL_TYPE_LEASEDF, G_NET_INVESTMENT_DF

                           , G_DEAL_TYPE_LEASEST, G_NET_INVESTMENT_DF
                           , G_DEAL_TYPE_LOAN, G_NET_INVESTMENT_LOAN
                           , G_DEAL_TYPE_LEASEOP, G_NET_INVESTMENT_OP
                           , G_NET_INVESTMENT_OTHERS)
FROM okl_pool_contents poc,
     okc_k_headers_b CHR,
     okl_k_headers khr
WHERE poc.khr_id = CHR.id
AND   khr.id = CHR.id
AND   poc.pol_id = p_pol_id
;
*/
  CURSOR c_poc (p_pol_id  NUMBER)
  IS
SELECT khr.id,
       DECODE(khr.deal_type, G_DEAL_TYPE_LEASEDF, G_NET_INVESTMENT_DF
                           , G_DEAL_TYPE_LEASEST, G_NET_INVESTMENT_DF
                           , G_DEAL_TYPE_LOAN, G_NET_INVESTMENT_LOAN
                           , G_DEAL_TYPE_LEASEOP, G_NET_INVESTMENT_OP
                           , G_NET_INVESTMENT_OTHERS)
FROM  okl_k_headers khr
WHERE EXISTS (SELECT '1'
              FROM   okl_pool_contents poc
              WHERE  khr.id = poc.khr_id
              AND    poc.pol_id = p_pol_id
              AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE))
;


  CURSOR c_chr (p_chr_id  NUMBER)
  IS
SELECT CHR.contract_number,
       khr.deal_type
FROM  okc_k_headers_b CHR,
      okl_k_headers khr
WHERE CHR.id = khr.id
AND   CHR.id = p_chr_id
;

BEGIN

  OPEN c_poc (p_pol_id);
  LOOP

    FETCH c_poc INTO l_khr_id,
--                     l_kle_id,
                     l_formula_name;

    EXIT WHEN c_poc%NOTFOUND;

    IF (l_formula_name = G_NET_INVESTMENT_OTHERS) THEN
      OPEN c_chr (l_khr_id);
      FETCH c_chr INTO l_contract_number,
                       l_deal_type;
      CLOSE c_chr;

      Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_DEAL_TYPE',
                          p_token1       => 'CONTRACT_NUM',
                          p_token1_value => l_contract_number,
                          p_token2       => 'DEAL_TYPE',
                          p_token2_value => l_deal_type);



      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

--     DBMS_OUTPUT.PUT_LINE('l_khr_id = ' || l_khr_id);
--     DBMS_OUTPUT.PUT_LINE('l_kle_id = ' || l_kle_id);

    Okl_Execute_Formula_Pub.EXECUTE(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_formula_name  => l_formula_name,
        p_contract_id   => l_khr_id,
        p_line_id       => l_kle_id,
        x_value         => x_value);

--     DBMS_OUTPUT.PUT_LINE('x_value = ' || x_value);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_tot_amount := l_tot_amount + NVL(x_value,0);


  END LOOP;
  CLOSE c_poc;

  RETURN l_tot_amount;
  EXCEPTION
    WHEN OTHERS THEN
      --l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => Okl_Api.G_APP_NAME,
                          p_msg_name      => 'OKL_UNEXPECTED_ERROR',
                          p_token1        => 'OKL_SQLCODE',
                          p_token1_value  => SQLCODE,
                          p_token2        => 'OKL_SQLERRM',
                          p_token2_value  => SQLERRM);
      RETURN NULL;

END get_tot_principal_amt;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_princ_amt
-- Description     : wrapper api for get_tot_principal_amt

-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE recal_tot_princ_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_pol_id                       IN  okl_pools.id%TYPE
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'recal_tot_princ_amt_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_amount           NUMBER;

  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

BEGIN
  -- Set API savepoint
  SAVEPOINT recal_tot_princ_amt_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

  x_value := get_tot_principal_amt(p_pol_id =>p_pol_id);

  IF x_value IS NULL THEN
    Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_RECAL_PRINC_AMT_ERR');
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

      lp_polv_rec.ID := p_pol_id;
      lp_polv_rec.TOTAL_PRINCIPAL_AMOUNT := x_value;
      lp_polv_rec.DATE_TOTAL_PRINCIPAL_CALC := SYSDATE;

      Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);


      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO recal_tot_princ_amt_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO recal_tot_princ_amt_pvt;

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get

      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO recal_tot_princ_amt_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);
END recal_tot_princ_amt;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : recal_tot_principal_amt
-- Description     : wrapper api for get_tot_principal_amt by investor agreement ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE recal_tot_principal_amt(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_value                        OUT NOCOPY NUMBER
   ,p_khr_id                       IN  okc_k_headers_b.id%TYPE
 )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'recal_tot_principal_amt_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_pol_id           okl_pools.id%TYPE;

  lp_polv_rec         polv_rec_type;
  lx_polv_rec         polv_rec_type;

CURSOR c_khr(p_khr_id okc_k_headers_b.id%TYPE) IS
  SELECT ph.id
FROM okl_pools ph
WHERE ph.khr_id = p_khr_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT recal_tot_principal_amt_pvt;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

  OPEN c_khr (p_khr_id);
  FETCH c_khr INTO l_pol_id;
  CLOSE c_khr;

  x_value := get_tot_principal_amt(p_pol_id =>l_pol_id);

  IF x_value IS NULL THEN
    Okl_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_RECAL_PRINC_AMT_ERR');
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

      lp_polv_rec.ID := l_pol_id;
    lp_polv_rec.TOTAL_PRINCIPAL_AMOUNT := x_value;
    lp_polv_rec.DATE_TOTAL_PRINCIPAL_CALC := SYSDATE;

      Okl_Pool_Pvt.update_pool(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_polv_rec      => lp_polv_rec,
        x_polv_rec      => lx_polv_rec);

      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN

    ROLLBACK TO recal_tot_principal_amt_pvt;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO recal_tot_principal_amt_pvt;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO recal_tot_principal_amt_pvt;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END recal_tot_principal_amt;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : add_pool_contents
-- Description     : creates pool contents based on passed in search criteria
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- Create by Search Criteria:	Query Streams from contracts + Create
/*
 PROCEDURE add_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_row_count                    OUT NOCOPY NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_pol_id                       IN NUMBER
   ,p_multi_org                    IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER
   ,p_sic_code                     IN VARCHAR2
   ,p_khr_id                       IN NUMBER
   ,p_pre_tax_yield_from           IN NUMBER
   ,p_pre_tax_yield_to             IN NUMBER
   ,p_book_classification          IN VARCHAR2
   ,p_tax_owner                    IN VARCHAR2
   ,p_pdt_id                       IN NUMBER
   ,p_start_date_from              IN DATE
   ,p_start_date_to                IN DATE
   ,p_end_date_from                IN DATE
   ,p_end_date_to                  IN DATE
   ,p_asset_id                     IN NUMBER
   ,p_item_id1                     IN NUMBER
   ,p_model_number                 IN VARCHAR2
   ,p_manufacturer_name            IN VARCHAR2
   ,p_vendor_id1                   IN NUMBER
   ,p_oec_from                     IN NUMBER
   ,p_oec_to                       IN NUMBER
   ,p_residual_percentage          IN NUMBER
   ,p_sty_id1                      IN NUMBER
   ,p_sty_id2                      IN NUMBER
-- start added by cklee 08/06/03
   ,p_stream_type_subclass         IN VARCHAR2
-- end added by cklee 08/06/03
   ,p_stream_element_from_date     IN DATE
   ,p_stream_element_to_date       IN DATE
   ,p_stream_element_payment_freq  IN VARCHAR2)
 IS
  l_api_name         CONSTANT VARCHAR2(30) := 'add_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type;
  x_pocv_rec         pocv_rec_type;

-------------------------------------------
-- search w/o payment frequency
-------------------------------------------

 CURSOR c_pool IS
	SELECT
	pol.dnz_chr_id khr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code sty_code
	,MIN(pol.stream_element_due_date) streams_from_date
	,DECODE(pol.stream_type_subclass, 'RESIDUAL', NULL, pol.end_date) streams_to_date
	-- mvasudev, stm_id changes
	,pol.stm_id
 FROM okl_pool_srch_v pol
 WHERE
 -- pre-req
	pol.currency_code = p_currency_code
     AND pol.sts_code = 'BOOKED'
     AND pol.assignable_yn = 'Y'
     AND pol.stream_element_date_billed IS NULL
	AND NVL(pol.cust_object1_id1,G_DEFAULT_NUM) = NVL(p_cust_object1_id1, NVL(pol.cust_object1_id1,G_DEFAULT_NUM))
	AND NVL(pol.sic_code,G_DEFAULT_CHAR) = NVL(p_sic_code, NVL(pol.sic_code,G_DEFAULT_CHAR))
	AND NVL(pol.dnz_chr_id,G_DEFAULT_NUM) = NVL(p_khr_id, NVL(pol.dnz_chr_id,G_DEFAULT_NUM))
	AND NVL(pol.pre_tax_yield,G_DEFAULT_NUM) BETWEEN NVL(p_pre_tax_yield_from, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
                                  AND     NVL(p_pre_tax_yield_to, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
--and pol.contract_number
	AND NVL(pol.book_classification,G_DEFAULT_CHAR) = NVL(p_book_classification, NVL(pol.book_classification,G_DEFAULT_CHAR))
	AND NVL(pol.pdt_id,G_DEFAULT_NUM) = NVL(p_pdt_id, NVL(pol.pdt_id,G_DEFAULT_NUM))
	AND NVL(pol.start_date, G_DEFAULT_DATE)
         BETWEEN NVL(p_start_date_from, NVL(pol.start_date, G_DEFAULT_DATE))
         AND     NVL(p_start_date_to, NVL(pol.start_date, G_DEFAULT_DATE))
	AND NVL(pol.end_date,G_DEFAULT_DATE)
         BETWEEN NVL(p_end_date_from, NVL(pol.end_date,G_DEFAULT_DATE))
         AND     NVL(p_end_date_to, NVL(pol.end_date,G_DEFAULT_DATE))
	AND NVL(pol.tax_owner,G_DEFAULT_CHAR) = NVL(p_tax_owner, NVL(pol.tax_owner,G_DEFAULT_CHAR))

	AND NVL(pol.stream_element_due_date, G_DEFAULT_DATE)
             BETWEEN NVL(p_stream_element_from_date,
                     NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
	       AND     NVL(p_stream_element_to_date,NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
-- pre-req condition
-- start for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND pol.stream_type_subclass IN ('RENT', 'RESIDUAL')
     AND NVL(pol.stream_type_subclass,G_DEFAULT_CHAR) = NVL(p_stream_type_subclass, NVL(pol.stream_type_subclass,G_DEFAULT_CHAR))
-- end for 11.5.10 by cklee 08/06/03 stream_type_subclass ER

	AND pol.stream_say_code = 'CURR'
	AND pol.stream_active_yn = 'Y'
     AND pol.stream_element_due_date > SYSDATE
-- multi-org
-- non existing check
-- start for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND NOT EXISTS -- okl_pool_contents
         (SELECT '1'
          FROM okl_pool_contents pol_cnts,
               okl_strm_type_b styb
          WHERE pol_cnts.pol_id = pol_id
		  -- mvasudev, stm_id changes
		  -- AND pol_cnts.sty_id = styb.id
          -- AND pol.dnz_chr_id = pol_cnts.khr_id
          AND pol.stm_id = pol_cnts.stm_id
          AND   styb.stream_type_subclass = pol.stream_type_subclass
          AND   pol_cnts.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
         )
-- end for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND NOT EXISTS -- variable interest rate
          (SELECT '1'

           FROM   okc_rule_groups_b rgp
                 ,okc_rules_b rg
           WHERE rgp.id = rg.rgp_id
           AND   rgp.rgd_code = 'LAIIND'
           AND   rg.rule_information_category= 'LAINTP'
           AND   rg.rule_information1 = 'Y'
           AND   rgp.dnz_chr_id = pol.dnz_chr_id)
     AND NOT EXISTS -- revision contract: rebook, split contract, reverse
          (SELECT '1'
           FROM okl_trx_contracts trxc
           WHERE trxc.tcn_type IN ('TRBK','SPLC','RVS')
           AND trxc.tsu_code NOT IN ('PROCESSED', 'ERROR','CANCELED') -- condition changes 01/13/2003 cklee
           AND trxc.khr_id = pol.dnz_chr_id)
     AND NOT EXISTS -- split assets, split assets components
          (SELECT '1'
           FROM okl_txd_assets_v tdas,
                okl_txl_assets_b tal,
                okc_k_lines_b      cle
           WHERE cle.id = tal.kle_id
           AND   tal.id = tdas.tal_id
           AND   tal.tal_type = 'ALI'
           -- link from okl_pool_srch_v pol
           AND   cle.cle_id = pol.kle_id -- top line id
           AND   tal.dnz_khr_id = pol.dnz_chr_id
           -- link from okl_pool_srch_v pol
           AND   EXISTS (SELECT '1'
                         FROM okl_trx_assets tas
                         WHERE tas.id = tal.tas_id
                         AND tas.tas_type = 'ALI'
                         AND tas.tsu_code NOT IN ('PROCESSED','CANCELED')))--cklee 02/24/03
     AND NOT EXISTS -- contract is under deliquent status
          (SELECT '1'
           FROM   iex_case_objects ico,
                  iex_delinquencies_all del
           WHERE  ico. cas_id = del.case_id
           AND    del.status ='DELINQUENT'
           AND    ico.object_id = pol.dnz_chr_id)
     AND NOT EXISTS -- contract line has been terminated
          (SELECT '1'
           FROM   okc_k_lines_b cle,
                  okc_statuses_b sts
           WHERE  sts.code = cle.sts_code
           AND    sts.ste_code IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
           AND    cle.id = pol.kle_id)
GROUP BY
	pol.dnz_chr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code
     ,pol.stream_type_subclass
     ,pol.end_date
	 -- mvasudev, stm_id changes
	,pol.stm_id
;

-------------------------------------------
-- search with payment frequency
-------------------------------------------

 CURSOR c_pool_payfreq IS
	SELECT
	pol.dnz_chr_id khr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code sty_code
	,MIN(pol.stream_element_due_date) streams_from_date
	,DECODE(pol.stream_type_subclass, 'RESIDUAL', NULL, pol.end_date) streams_to_date
	 -- mvasudev, stm_id changes
	,pol.stm_id
FROM okl_pool_srch_payfreq_v pol
WHERE
-- pre-req
	pol.currency_code = p_currency_code
     AND pol.sts_code = 'BOOKED'
     AND pol.assignable_yn = 'Y'
     AND pol.stream_element_date_billed IS NULL
--
	AND NVL(pol.cust_object1_id1,G_DEFAULT_NUM) = NVL(p_cust_object1_id1, NVL(pol.cust_object1_id1,G_DEFAULT_NUM))
--and pol.lessee
	AND NVL(pol.sic_code,G_DEFAULT_CHAR) = NVL(p_sic_code, NVL(pol.sic_code,G_DEFAULT_CHAR))
	AND NVL(pol.dnz_chr_id,G_DEFAULT_NUM) = NVL(p_khr_id, NVL(pol.dnz_chr_id,G_DEFAULT_NUM))
	AND NVL(pol.pre_tax_yield,G_DEFAULT_NUM) BETWEEN NVL(p_pre_tax_yield_from, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
                                  AND     NVL(p_pre_tax_yield_to, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
--and pol.contract_number
	AND NVL(pol.book_classification,G_DEFAULT_CHAR) = NVL(p_book_classification, NVL(pol.book_classification,G_DEFAULT_CHAR))
	AND NVL(pol.pdt_id,G_DEFAULT_NUM) = NVL(p_pdt_id, NVL(pol.pdt_id,G_DEFAULT_NUM))
	AND NVL(pol.start_date, G_DEFAULT_DATE)
         BETWEEN NVL(p_start_date_from, NVL(pol.start_date, G_DEFAULT_DATE))
         AND     NVL(p_start_date_to, NVL(pol.start_date, G_DEFAULT_DATE))
	AND NVL(pol.end_date,G_DEFAULT_DATE)
         BETWEEN NVL(p_end_date_from, NVL(pol.end_date,G_DEFAULT_DATE))
         AND     NVL(p_end_date_to, NVL(pol.end_date,G_DEFAULT_DATE))
	AND NVL(pol.tax_owner,G_DEFAULT_CHAR) = NVL(p_tax_owner, NVL(pol.tax_owner,G_DEFAULT_CHAR))
	AND NVL(pol.stream_element_due_date, G_DEFAULT_DATE)
             BETWEEN NVL(p_stream_element_from_date,
                     NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
	       AND     NVL(p_stream_element_to_date,
                     NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
-- cklee 02/21/2003 bug fixed
     AND NVL(pol.PAYMENT_FREQ,G_DEFAULT_CHAR) = NVL(p_STREAM_ELEMENT_PAYMENT_FREQ, NVL(pol.PAYMENT_FREQ,G_DEFAULT_CHAR))
-- pre-req condition
-- start for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND pol.stream_type_subclass IN ('RENT', 'RESIDUAL')
     AND NVL(pol.stream_type_subclass,G_DEFAULT_CHAR) = NVL(p_stream_type_subclass, NVL(pol.stream_type_subclass,G_DEFAULT_CHAR))
-- end for 11.5.10 by cklee 08/06/03 stream_type_subclass ER

	AND pol.stream_say_code = 'CURR'
	AND pol.stream_active_yn = 'Y'
     AND pol.stream_element_due_date > SYSDATE
-- multi-org
-- non existing check
-- start for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND NOT EXISTS -- okl_pool_contents
         (SELECT '1'
          FROM okl_pool_contents pol_cnts,
               okl_strm_type_b styb
          WHERE  pol_cnts.pol_id = pol_id
		  -- mvasudev, stm_id changes
		  --AND pol_cnts.sty_id = styb.id
          --AND   pol.dnz_chr_id = pol_cnts.khr_id
          AND   pol.stm_id = pol_cnts.stm_id
          AND   styb.stream_type_subclass = pol.stream_type_subclass
          AND   pol_cnts.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
         )
-- end for 11.5.10 by cklee 08/06/03 stream_type_subclass ER
     AND NOT EXISTS -- variable interest rate
          (SELECT '1'
           FROM   okc_rule_groups_b rgp
                 ,okc_rules_b rg
           WHERE rgp.id = rg.rgp_id
           AND   rgp.rgd_code = 'LAIIND'
           AND   rg.rule_information_category= 'LAINTP'
           AND   rg.rule_information1 = 'Y'
           AND   rgp.dnz_chr_id = pol.dnz_chr_id)
     AND NOT EXISTS -- revision contract: rebook, split contract, reverse
          (SELECT '1'
           FROM okl_trx_contracts
           WHERE tcn_type IN ('TRBK','SPLC','RVS')
           AND tsu_code NOT IN ('PROCESSED', 'ERROR','CANCELED') -- condition changes 01/13/2003 cklee
           AND khr_id = pol.dnz_chr_id)
     AND NOT EXISTS -- split assets, split assets components
          (SELECT '1'
           FROM okl_txd_assets_v tdas,
                okl_txl_assets_b tal,
                okc_k_lines_b      cle
           WHERE cle.id = tal.kle_id
           AND   tal.id = tdas.tal_id
           AND   tal.tal_type = 'ALI'
           -- link from okl_pool_srch_v pol
           AND   cle.cle_id = pol.kle_id -- top line id
           AND   tal.dnz_khr_id = pol.dnz_chr_id
           -- link from okl_pool_srch_v pol
           AND   EXISTS (SELECT '1'
                         FROM okl_trx_assets tas
                         WHERE tas.id = tal.tas_id
                         AND tas.tas_type = 'ALI'
                         AND tas.tsu_code NOT IN ('PROCESSED','CANCELED'))) -- cklee 02/24/03
     AND NOT EXISTS -- contract is under deliquent status
          (SELECT '1'
           FROM   iex_case_objects ico,
                  iex_delinquencies_all del
           WHERE  ico. cas_id = del.case_id
           AND    del.status ='DELINQUENT'
           AND    ico.object_id = pol.dnz_chr_id)
     AND NOT EXISTS -- contract line has been terminated
          (SELECT '1'
           FROM   okc_k_lines_b cle,
                  okc_statuses_b sts
           WHERE  sts.code = cle.sts_code
           AND    sts.ste_code IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
           AND    cle.id = pol.kle_id)
GROUP BY
	pol.dnz_chr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code
     ,pol.stream_type_subclass
     ,pol.end_date
	 -- mvasudev, stm_id changes
	,pol.stm_id
;

BEGIN
  -- Set API savepoint
  SAVEPOINT add_pool_contents_PVT;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


--/*** Begin API body ****************************************************
---------------------------------------------------------
-- 1. validate date format
-- 2. validate number
---------------------------------------------------------

--     DBMS_OUTPUT.PUT_LINE('START add_pool_contents poc');

  l_pocv_rec.POL_ID := p_POL_ID;
  i := 0;

-- fill in l_polv_rec
  IF (p_STREAM_ELEMENT_PAYMENT_FREQ IS NOT NULL) THEN

--     DBMS_OUTPUT.PUT_LINE('IF (p_STREAM_ELEMENT_PAYMENT_FREQ IS NOT NULL) THEN');


    OPEN c_pool_payfreq;
    LOOP
--     DBMS_OUTPUT.PUT_LINE('inside LOOP IF (p_STREAM_ELEMENT_PAYMENT_FREQ IS NOT NULL) THEN');


      FETCH c_pool_payfreq INTO
                       l_pocv_rec.KHR_ID
                       ,l_pocv_rec.KLE_ID
                       ,l_pocv_rec.STY_ID
                       ,l_pocv_rec.STY_CODE
                       ,l_pocv_rec.STREAMS_FROM_DATE
                       ,l_pocv_rec.STREAMS_TO_DATE
                     	 -- mvasudev, stm_id changes
                       ,l_pocv_rec.STM_ID;

      EXIT WHEN c_pool_payfreq%NOTFOUND;

      Okl_Pool_Pvt.create_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => l_pocv_rec,
        x_pocv_rec      => x_pocv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      i := i+1;
    END LOOP;
    CLOSE c_pool_payfreq;


  ELSE -- to avoid outer join
--     DBMS_OUTPUT.PUT_LINE('ELSE IF (p_STREAM_ELEMENT_PAYMENT_FREQ IS NOT NULL) THEN');

    OPEN c_pool;
    LOOP
--     DBMS_OUTPUT.PUT_LINE('inside LOOP ELSE IF (p_STREAM_ELEMENT_PAYMENT_FREQ IS NOT NULL) THEN');

      FETCH c_pool INTO
                       l_pocv_rec.KHR_ID
                       ,l_pocv_rec.KLE_ID
                       ,l_pocv_rec.STY_ID
                       ,l_pocv_rec.STY_CODE
                       ,l_pocv_rec.STREAMS_FROM_DATE
                       ,l_pocv_rec.STREAMS_TO_DATE
                     	 -- mvasudev, stm_id changes
                       ,l_pocv_rec.STM_ID;


      EXIT WHEN c_pool%NOTFOUND;

      Okl_Pool_Pvt.create_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_rec      => l_pocv_rec,
        x_pocv_rec      => x_pocv_rec);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      i := i+1;
    END LOOP;
    CLOSE c_pool;

  END IF;
  x_row_count := i;
--     DBMS_OUTPUT.PUT_LINE('END add_pool_contents poc');


--/*** End API body ******************************************************

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO add_pool_contents_pvt;
    x_row_count := 0;


    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO add_pool_contents_pvt;
    x_row_count := 0;

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO add_pool_contents_pvt;
    x_row_count := 0;

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END add_pool_contents;
*/

 PROCEDURE add_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_row_count                    OUT NOCOPY NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_pol_id                       IN NUMBER
   ,p_multi_org                    IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER
   ,p_sic_code                     IN VARCHAR2
   ,p_khr_id                       IN NUMBER
   ,p_pre_tax_yield_from           IN NUMBER
   ,p_pre_tax_yield_to             IN NUMBER
   ,p_book_classification          IN VARCHAR2
   ,p_tax_owner                    IN VARCHAR2
   ,p_pdt_id                       IN NUMBER
   ,p_start_date_from              IN DATE
   ,p_start_date_to                IN DATE
   ,p_end_date_from                IN DATE
   ,p_end_date_to                  IN DATE
   ,p_asset_id                     IN NUMBER
   ,p_item_id1                     IN NUMBER
   ,p_model_number                 IN VARCHAR2
   ,p_manufacturer_name            IN VARCHAR2
   ,p_vendor_id1                   IN NUMBER
   ,p_oec_from                     IN NUMBER
   ,p_oec_to                       IN NUMBER
   ,p_residual_percentage          IN NUMBER
   ,p_sty_id1                      IN NUMBER
   ,p_sty_id2                      IN NUMBER
-- start added by cklee 08/06/03
   ,p_stream_type_subclass         IN VARCHAR2
-- end added by cklee 08/06/03
   ,p_stream_element_from_date     IN DATE
   ,p_stream_element_to_date       IN DATE
   ,p_stream_element_payment_freq  IN VARCHAR2
/* ankushar 26-JUL-2007 Bug#6000531 start changes*/
   ,p_log_message 	           IN VARCHAR2 DEFAULT 'Y'
 /* ankushar end changes 26-Jul-2007*/
  ,p_cust_crd_clf_code            IN VARCHAR2 DEFAULT NULL)

 IS

-------------------------------------------
-- search w/o payment frequency
-------------------------------------------

 -- Cursor to collect all pocs that satisfy the criteria
 CURSOR l_okl_pocs_csr IS
	SELECT
     pol.dnz_chr_id khr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code sty_code
	,MIN(pol.stream_element_due_date) streams_from_date
	-- mvasudev, 02/06/2004
	,DECODE(pol.stream_type_subclass, 'RESIDUAL', NULL, pol.end_date+1) streams_to_date
	,pol.stm_id
	-- extra
	,pol.stream_type_subclass
	,pol.contract_number
	,pol.lessee
	,lkup.meaning sty_subclass_meaning
	,pol.asset_number
	,hcp.credit_classification
 FROM okl_pool_srch_v pol
     ,fnd_lookups lkup
     ,hz_customer_profiles hcp
 WHERE
    -- pre-req
	    pol.currency_code = p_currency_code
    AND pol.sts_code IN ('BOOKED','EVERGREEN')
    AND pol.assignable_yn = 'Y'
    AND pol.stream_element_date_billed IS NULL
	-- to fetch stream_type_subclass name
	AND lkup.lookup_type = 'OKL_STREAM_TYPE_SUBCLASS'
    AND lkup.lookup_code = pol.stream_type_subclass
	-- customer
	AND NVL(pol.cust_object1_id1,G_DEFAULT_NUM) = NVL(p_cust_object1_id1, NVL(pol.cust_object1_id1,G_DEFAULT_NUM))
	AND NVL(pol.sic_code,G_DEFAULT_CHAR) = NVL(p_sic_code, NVL(pol.sic_code,G_DEFAULT_CHAR))
	-- contract number
	AND NVL(pol.dnz_chr_id,G_DEFAULT_NUM) = NVL(p_khr_id, NVL(pol.dnz_chr_id,G_DEFAULT_NUM))
	AND NVL(pol.pre_tax_yield,G_DEFAULT_NUM) BETWEEN NVL(p_pre_tax_yield_from, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
                                  AND     NVL(p_pre_tax_yield_to, NVL(pol.pre_tax_yield,G_DEFAULT_NUM))
	AND NVL(pol.book_classification,G_DEFAULT_CHAR) = NVL(p_book_classification, NVL(pol.book_classification,G_DEFAULT_CHAR))
	AND NVL(pol.pdt_id,G_DEFAULT_NUM) = NVL(p_pdt_id, NVL(pol.pdt_id,G_DEFAULT_NUM))
	AND NVL(pol.start_date, G_DEFAULT_DATE)
         BETWEEN NVL(p_start_date_from, NVL(pol.start_date, G_DEFAULT_DATE))
         AND     NVL(p_start_date_to, NVL(pol.start_date, G_DEFAULT_DATE))
	AND NVL(pol.end_date,G_DEFAULT_DATE)
         BETWEEN NVL(p_end_date_from, NVL(pol.end_date,G_DEFAULT_DATE))
         AND     NVL(p_end_date_to, NVL(pol.end_date,G_DEFAULT_DATE))
	AND NVL(pol.tax_owner,G_DEFAULT_CHAR) = NVL(p_tax_owner, NVL(pol.tax_owner,G_DEFAULT_CHAR))
    -- streams
	AND NVL(pol.stream_element_due_date, G_DEFAULT_DATE)
             BETWEEN NVL(p_stream_element_from_date,
                     NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
    	       AND   NVL(p_stream_element_to_date,NVL(pol.stream_element_due_date, G_DEFAULT_DATE))
     --Bug 674000 ssdeshpa start
     AND pol.stream_type_subclass IN ('RENT', 'RESIDUAL', 'LOAN_PAYMENT')
     --Bug 674000 ssdeshpa end
     AND NVL(pol.stream_type_subclass,G_DEFAULT_CHAR) = NVL(p_stream_type_subclass, NVL(pol.stream_type_subclass,G_DEFAULT_CHAR))
     AND pol.stream_say_code = 'CURR'
	 AND pol.stream_active_yn = 'Y'
	 -- mvasudev, 02/06/2004
     --AND pol.stream_element_due_date > SYSDATE
     -- multi-org
     --Bug # 6691554 Changes for Cust Credit Classification Lov Start
     AND pol.cust_object1_id1 = hcp.party_id(+)
     AND hcp.cust_account_id(+) = -1
     AND hcp.site_use_id(+) IS NULL
     AND NVL(hcp.credit_classification(+),G_DEFAULT_CHAR) = NVL(p_cust_crd_clf_code, NVL(hcp.credit_classification(+),G_DEFAULT_CHAR))
     --Bug # 6691554 Changes for Cust Credit Classification Lov End
GROUP BY
	pol.dnz_chr_id
	,pol.kle_id
	,pol.sty_id
	,pol.stream_type_code
     ,pol.stream_type_subclass
     ,pol.end_date
	 -- mvasudev, stm_id changes
	,pol.stm_id
	,pol.contract_number
	,pol.lessee
	,lkup.meaning
	,pol.asset_number
	,hcp.credit_classification;

    -- Cursor to discard pocs that already exist
 /* ankushar 03-JAN-2008
    Bug#6726555  Modified cursor to look at the stream element level to achive partially bought back
    contracts to be associcated to another Pool.
    start changes
 */
    CURSOR l_okl_dup_pocs_csr(p_stream_type_subclass IN VARCHAR2,p_stm_id IN NUMBER)
	IS
    SELECT '1'
    FROM okl_pool_contents pol_cnts,
         okl_strm_type_b   styb,
         okl_strm_elements sel
    WHERE pol_cnts.pol_id = pol_id
    AND   pol_cnts.stm_id = p_stm_id
    AND   styb.stream_type_subclass = p_stream_type_subclass
    AND   pol_cnts.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE,G_POC_STS_PENDING)
    AND   sel.stm_id = pol_cnts.stm_id
    AND   sel.date_billed IS NULL
    GROUP BY sel.stm_id
    HAVING MAX(sel.STREAM_ELEMENT_DATE) <= MAX(nvl(pol_cnts.STREAMS_TO_DATE,pol_cnts.STREAMS_FROM_DATE));
 /* ankushar 03-JAN-2008 Bug# 6726555
    end Changes
 */

    /*Added by kthiruva to check whether the contract streams were bought back */
    CURSOR l_buyback_yes_csr(p_stm_id IN NUMBER)
	IS
    SELECT '1'
    FROM okl_pool_contents pol_cnts
    WHERE pol_cnts.pol_id = pol_id
    AND   pol_cnts.stm_id = p_stm_id
    AND   pol_cnts.status_code = 'INACTIVE';

    /*Added by ankushar to fetch the maximum stream to_date to pick up the remaining streams after this date */
    CURSOR l_max_to_date_csr(p_stm_id IN NUMBER)
	IS
    SELECT MAX(nvl(pol_cnts.STREAMS_TO_DATE,pol_cnts.STREAMS_FROM_DATE)) eff_from_date
    FROM okl_pool_contents pol_cnts
    WHERE pol_cnts.pol_id = pol_id
    AND   pol_cnts.stm_id = p_stm_id
    AND   pol_cnts.status_code = 'ACTIVE';

    l_buyback_yn         BOOLEAN := false;
    l_eff_from_date      DATE;
	-- Variable Interest Rate
	-- fmiao bug 5160080--
	/*
	CURSOR l_okl_poc_vari_csr(p_dnz_chr_id IN NUMBER)
	IS
	SELECT '1'
	FROM   okc_rule_groups_b rgp
          ,okc_rules_b rg
    WHERE rgp.id = rg.rgp_id
    AND   rgp.rgd_code = 'LAIIND'
    AND   rg.rule_information_category= 'LAINTP'
    AND   rg.rule_information1 = 'Y'
    AND   rgp.dnz_chr_id = p_dnz_chr_id;
	*/
	SUBTYPE pdt_parameters_rec_type IS Okl_Setupproducts_Pvt.pdt_parameters_rec_type;
	l_pdt_parameters_rec pdt_parameters_rec_type;
	--fmiao 5160080 end-- fmiao bug 5160080 end --

	-- revision contract: rebook, split contract, reverse
	CURSOR l_okl_poc_rev_csr(p_dnz_chr_id IN NUMBER)
	IS
	SELECT '1'
	FROM okl_trx_contracts trxc
	WHERE trxc.tcn_type IN ('TRBK','SPLC','RVS')
    AND trxc.tsu_code NOT IN ('PROCESSED', 'ERROR','CANCELED')
    AND trxc.khr_id = p_dnz_chr_id;

    -- split assets, split assets components
	CURSOR l_okl_poc_splits_csr(p_dnz_chr_id IN NUMBER,p_kle_id IN NUMBER)
	IS
	SELECT '1'
           FROM okl_txd_assets_v tdas,
                okl_txl_assets_b tal,
                okc_k_lines_b      cle
           WHERE cle.id = tal.kle_id
           AND   tal.id = tdas.tal_id
           AND   tal.tal_type = 'ALI'
           -- link from okl_pool_srch_v pol
           AND   cle.cle_id = p_kle_id -- top line id
           AND   tal.dnz_khr_id = p_dnz_chr_id
           -- link from okl_pool_srch_v pol
           AND   EXISTS (SELECT '1'
                         FROM okl_trx_assets tas
                         WHERE tas.id = tal.tas_id
                         AND tas.tas_type = 'ALI'
                         AND tas.tsu_code NOT IN ('PROCESSED','CANCELED')
						);

     -- contract is under deliquent status
     CURSOR l_okl_poc_delinq_csr(p_dnz_chr_id IN NUMBER)
	 IS
	 SELECT '1'
	 FROM   iex_case_objects ico,
            iex_delinquencies_all del
     WHERE  ico. cas_id = del.case_id
     AND    del.status ='DELINQUENT'
     AND    ico.object_id = p_dnz_chr_id;

    -- contract line has been terminated
    CURSOR l_okl_poc_kle_csr(p_kle_id IN NUMBER)
	IS
	SELECT '1'
    FROM   okc_k_lines_b cle,
           okc_statuses_b sts
    WHERE  sts.code = cle.sts_code
    AND    sts.ste_code IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
    AND    cle.id = p_kle_id;

-- cursor to discard Legal Entity Mismatch

--if Legal Entity Id for Pool and Contract is not same
-- then raise an error
  CURSOR l_okl_reject_le_csr(p_khr_id IN NUMBER)
  IS
   SELECT '1'
   FROM   okl_k_headers khr,
	  okl_pools pol
   WHERE  pol.legal_entity_id <> khr.legal_entity_id
   AND    pol.id =p_pol_id
   AND    khr.id = p_khr_id;

  CURSOR l_okl_reject_codes_csr
  IS
  SELECT lookup_code,
	     meaning
  FROM   fnd_lookups
  WHERE LOOKUP_TYPE LIKE 'OKL_POOL_REJECT_REASON'
  ORDER BY LOOKUP_CODE;

   /* sosharma 21-nov-2007
  R12 Bug 6640050
  Cursor to check whether new transaction needs to be created for adjustments
  Start Changes
  */
  CURSOR l_trans_exists_csr(p_pol_id IN NUMBER)
  IS
  SELECT id pox_id,transaction_number FROM OKL_POOL_TRANSACTIONS pools
  where pools.transaction_status in (G_POOL_TRX_STATUS_INCOMPLETE,G_POOL_TRX_STATUS_NEW,G_POOL_TRX_STATUS_APPREJ)
  and pools.transaction_type='ADD' and pools.transaction_reason='ADJUSTMENTS'
  and pools.pol_id=p_pol_id;

   -- Cursor to get the Legal Entity Id
    CURSOR l_okl_agrle_csr(p_pol_id IN NUMBER)
    IS
    SELECT legal_entity_id
    FROM   okl_pools
	WHERE  id = p_pol_id;


  /* sosharma end changes*/

  l_api_name         CONSTANT VARCHAR2(30) := 'add_pool_contents_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;

  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type;
  x_pocv_rec         pocv_rec_type;
  --Added by kthiruva on 21-Nov-2007 for Bug 6640050
  l_pocv_tbl         pocv_tbl_type;
  l_status_code      okl_pools.status_code%TYPE;
  l_poc_count        NUMBER := 0;

--  l_discarded BOOLEAN := FALSE;
  l_discard_count NUMBER := 0;
  l_add_count        NUMBER := 0;
  l_reject_code VARCHAR2(5) ;

  -- copied from okl_poolconc_pvt (need to modify this later to directly refer to that api)
  l_row_num_len      NUMBER := 6;
  l_contract_num_len NUMBER := 30;
  l_asset_num_len    NUMBER := 15;
  l_lessee_len       NUMBER := 40;
  l_sty_subclass_len NUMBER := 25;
  l_reject_code_len  NUMBER := 20;
  l_filler            VARCHAR2(5) := RPAD(' ',5,' ');

  l_adds_msg_tbl msg_tbl_type;
  l_rejects_msg_tbl msg_tbl_type;
  i NUMBER;
  --sosharma added
  l_pox_id NUMBER;
  l_transaction_number NUMBER;
  l_legal_entity_id NUMBER;
  l_transaction_status VARCHAR2(30);
  l_trx_id NUMBER;
  l_trans_found BOOLEAN := TRUE;
  lp_poxv_rec         poxv_rec_type;
  lx_poxv_rec         poxv_rec_type;
  x_pocv_tbl         pocv_tbl_type;


BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec.pol_id := p_pol_id;
  --Added by kthiruva on 21-Nov -2007 to fetch the Pool Status
  --Bug 6640050 - Start of Changes
  FOR pool_status_rec IN pool_status_csr(p_pol_id)
  LOOP
    l_status_code := pool_status_rec.status_code;
  END LOOP;
  --Bug 6640050 - End of Changes

    FOR l_okl_poc_rec IN l_okl_pocs_csr
	LOOP
	   l_reject_code := NULL;

       -- Any poc that is caught in the following cursors
	   -- needs to be discarded


		   -- duplicate pocs
		   FOR l_okl_dup_pocs_rec IN l_okl_dup_pocs_csr(l_okl_poc_rec.stream_type_subclass,l_okl_poc_rec.stm_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_DUP_POCS;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;


  	   IF l_reject_code IS NULL THEN
  	       /* Added by kthiruva to check if a contract stream has been bought back */
		   FOR l_buyback_yes_rec IN l_buyback_yes_csr(l_okl_poc_rec.stm_id)
		   LOOP
 /* ankushar 21-JAN-2008
    Bug#6740000  Modified cursor to populate the effective from date as the max date of the Active Streams.
    start changes
  */
        FOR l_max_to_date_rec IN l_max_to_date_csr(l_okl_poc_rec.stm_id)
        LOOP
                     l_eff_from_date := l_max_to_date_rec.eff_from_date;
        END LOOP;
 /* ankushar 21-JAN-2008
    Bug#6740000  end changes
  */
		     l_buyback_yn := true;
		   END LOOP;
		   -- variable interest
		   -- fmiao bug 5160080
		   --FOR l_okl_poc_vari_rec IN l_okl_poc_vari_csr(l_okl_poc_rec.khr_id)
		   --LOOP
		   Okl_K_Rate_Params_Pvt.GET_PRODUCT(
             p_api_version             => p_api_version,
             p_init_msg_list           => p_init_msg_list,
             x_return_status           => x_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data,
             p_khr_id                  => l_okl_poc_rec.khr_id,
             x_pdt_parameter_rec       => l_pdt_parameters_rec);

		   IF l_pdt_parameters_rec.interest_calculation_basis <> 'FIXED' THEN
 		       l_discard_count := l_discard_count + 1;
			   l_reject_code := G_REJECT_VARIABLE_INTEREST;
           ELSE
              IF l_pdt_parameters_rec.revenue_recognition_method = 'ACTUAL'  THEN
                 l_discard_count := l_discard_count + 1;
			     l_reject_code := G_REJECT_VARIABLE_INTEREST;
              END IF;
           END IF;
			--EXIT WHEN l_reject_code IS NOT NULL;
		    --END LOOP;
		    -- fmiao bug 5160080 end
	   END IF;

  	   IF l_reject_code IS NULL THEN
		   -- revision contract
		   FOR l_okl_poc_rev_rec IN l_okl_poc_rev_csr(l_okl_poc_rec.khr_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_REV_KHR;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;
	   END IF;

  	   IF l_reject_code IS NULL THEN
		   -- split asset components
		   FOR l_okl_poc_splits_rec IN l_okl_poc_splits_csr(l_okl_poc_rec.khr_id,l_okl_poc_rec.kle_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_SPLIT_ASSET;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;
       END IF;

  	   IF l_reject_code IS NULL THEN
		   -- delinquent contract
		   FOR l_okl_poc_delinq_rec IN l_okl_poc_delinq_csr(l_okl_poc_rec.khr_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_DELINQ_KHR;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;
	   END IF;

  	   IF l_reject_code IS NULL THEN
	       -- terminated assets
		   FOR l_okl_poc_kle_rec IN l_okl_poc_kle_csr(l_okl_poc_rec.kle_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_ASSET_TERMINATED;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;
       END IF;

	   IF l_reject_code IS NULL THEN
	       -- check for Legal Entity
		   FOR l_okl_poc_le_rec IN l_okl_reject_le_csr(l_okl_poc_rec.khr_id)
		   LOOP
			 l_discard_count := l_discard_count + 1;
			 l_reject_code := G_REJECT_LEGAL_ENTITY_MISMATCH;
		   EXIT WHEN l_reject_code IS NOT NULL;
		   END LOOP;
       END IF;

  	   IF l_reject_code IS NOT NULL THEN
	     -- write it to the report

	    IF Fnd_Global.CONC_REQUEST_ID <> -1 THEN

            l_rejects_msg_tbl(l_discard_count).msg := RPAD(l_discard_count,l_row_num_len)
                         || RPAD(l_okl_poc_rec.contract_number ,l_contract_num_len)
                         || RPAD(l_okl_poc_rec.asset_number ,l_asset_num_len)
                         || RPAD(l_okl_poc_rec.lessee ,l_lessee_len)
                         || RPAD(l_okl_poc_rec.sty_subclass_meaning ,l_sty_subclass_len)
                         || RPAD(l_reject_code ,l_reject_code_len);
         END IF;

       ELSE

		  l_add_count := l_add_count+1;
		  IF l_status_code = 'NEW' THEN

           l_pocv_rec.khr_id := l_okl_poc_rec.khr_id;
           l_pocv_rec.kle_id := l_okl_poc_rec.kle_id;
           l_pocv_rec.sty_id := l_okl_poc_rec.sty_id;
           l_pocv_rec.sty_code := l_okl_poc_rec.sty_code;
           /*Modified by kthiruva to set the streams start date to  effective from date of the stream has been bought back*/
           IF (l_buyback_yn) AND (l_okl_poc_rec.streams_from_date < (l_eff_from_date  +1)) THEN
              l_pocv_rec.streams_from_date := l_eff_from_date + 1;
           ELSE
            l_pocv_rec.streams_from_date := l_okl_poc_rec.streams_from_date;
           END IF;
           l_pocv_rec.streams_to_date := l_okl_poc_rec.streams_to_date;
           l_pocv_rec.stm_id := l_okl_poc_rec.stm_id;

          Okl_Pool_Pvt.create_pool_contents(
	        p_api_version   => p_api_version,
	        p_init_msg_list => p_init_msg_list,
	        x_return_status => x_return_status,
	        x_msg_count     => x_msg_count,
	        x_msg_data      => x_msg_data,
	        p_pocv_rec      => l_pocv_rec,
	        x_pocv_rec      => x_pocv_rec);


	      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	        RAISE Okl_Api.G_EXCEPTION_ERROR;
	      END IF;

	      ELSE
	       /* sosharma 21-Nov-2007
            R12 Bug 6640050
            Code to create a table for pool content records before making the create call
            Start Changes
           */
           l_pocv_tbl(l_poc_count).pol_id := p_pol_id;
	        l_pocv_tbl(l_poc_count).khr_id := l_okl_poc_rec.khr_id;
           l_pocv_tbl(l_poc_count).kle_id := l_okl_poc_rec.kle_id;
           l_pocv_tbl(l_poc_count).sty_id := l_okl_poc_rec.sty_id;
           l_pocv_tbl(l_poc_count).sty_code := l_okl_poc_rec.sty_code;
           /*Modified by kthiruva to set the streams start date to  effective
 * from date of the stream has been bought back*/
          IF (l_buyback_yn) AND (l_okl_poc_rec.streams_from_date <(l_eff_from_date  +1)) THEN
               l_pocv_tbl(l_poc_count).streams_from_date := l_eff_from_date + 1;

           ELSE
              l_pocv_tbl(l_poc_count).streams_from_date := l_okl_poc_rec.streams_from_date;
           END IF;           l_pocv_tbl(l_poc_count).streams_to_date := l_okl_poc_rec.streams_to_date;
           l_pocv_tbl(l_poc_count).stm_id := l_okl_poc_rec.stm_id;
           -- Status code to be set as PENDING
          -- l_pocv_tbl(l_poc_count).status_code := G_POC_STS_PENDING;
           l_poc_count       := l_poc_count + 1;
           END IF;
	       /* sosharma End changes*/



/* ankushar 26-JUL-2007
    Bug#6000531
    start changes
*/
	  IF p_log_message ='Y' THEN
/* ankushar end changes 26-Jul-2007*/
   -- populate the log table only if the p_log_message is 'Y'
	    IF Fnd_Global.CONC_REQUEST_ID <> -1 THEN
            l_adds_msg_tbl(l_add_count).msg  := RPAD(l_add_count,l_row_num_len)
                         || RPAD(l_okl_poc_rec.contract_number ,l_contract_num_len)
                         || RPAD(l_okl_poc_rec.asset_number ,l_asset_num_len)
                         || RPAD(l_okl_poc_rec.lessee ,l_lessee_len)
                         || RPAD(l_okl_poc_rec.sty_subclass_meaning ,l_sty_subclass_len);
        END IF;

	  END IF;

	  END IF;

    END LOOP; -- l_okl_poc_csr

 /* sosharma 21-Nov-2007
   R12 Bug 6640050
   Create pool contents and create transaction calls
   Start Changes
  */
IF l_pocv_tbl.COUNT > 0 THEN
       OPEN l_trans_exists_csr(p_pol_id);
       FETCH l_trans_exists_csr INTO l_pox_id,l_transaction_number;
       l_trans_found := l_trans_exists_csr%FOUND;
       CLOSE l_trans_exists_csr;
     IF l_trans_found THEN
       FOR i IN l_pocv_tbl.FIRST..l_pocv_tbl.LAST LOOP
          l_pocv_tbl(i).pox_id:= l_pox_id;
          l_pocv_tbl(i).transaction_number_in:=l_transaction_number;
        END LOOP;
     ELSE

-- get the legal entity id to create transactions
    OPEN l_okl_agrle_csr(p_pol_id);
	  FETCH l_okl_agrle_csr into l_legal_entity_id;
	  CLOSE l_okl_agrle_csr;

-- populate pool transaction rec
      lp_poxv_rec.POL_ID := p_pol_id;
      lp_poxv_rec.TRANSACTION_DATE := SYSDATE;
      lp_poxv_rec.TRANSACTION_TYPE := G_POOL_TRX_ADD;
      lp_poxv_rec.TRANSACTION_REASON := G_POOL_TRX_REASON_ADJUST;
      lp_poxv_rec.CURRENCY_CODE := p_currency_code;
      lp_poxv_rec.LEGAL_ENTITY_ID := l_legal_entity_id;
      --sosharma 03/12/2007 added to enable status on pool transaction
      lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_NEW;

    -- create ADD transaction for Adjustment
      Okl_Pool_Pvt.create_pool_transaction(p_api_version   => p_api_version
 	                                    ,p_init_msg_list => p_init_msg_list
 	                                    ,x_return_status => l_return_status
 	                                    ,x_msg_count     => x_msg_count
 	                                    ,x_msg_data      => x_msg_data
 	                                    ,p_poxv_rec      => lp_poxv_rec
 	                                    ,x_poxv_rec      => lx_poxv_rec);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
     -- Assign the Transaction Id to pool contents
     FOR i IN l_pocv_tbl.FIRST..l_pocv_tbl.LAST LOOP
     l_pocv_tbl(i).pox_id:= lx_poxv_rec.id;
     l_pocv_tbl(i).transaction_number_in:= lx_poxv_rec.transaction_number;
     END LOOP;

    END IF;
    --- create pool contents for Adjustment ADD transaction
        Okl_Pool_Pvt.create_pool_contents(
	        p_api_version   => p_api_version,
	        p_init_msg_list => p_init_msg_list,
	        x_return_status => x_return_status,
	        x_msg_count     => x_msg_count,
	        x_msg_data      => x_msg_data,
	        p_pocv_tbl      => l_pocv_tbl,
	        x_pocv_tbl      => x_pocv_tbl);


	      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	        RAISE Okl_Api.G_EXCEPTION_ERROR;
	      END IF;

-- get existing the transaction status
    OPEN l_trans_status_csr(p_pol_id);
       FETCH l_trans_status_csr INTO l_transaction_status,l_trx_id;
       CLOSE l_trans_status_csr;

    IF l_transaction_status = G_POOL_TRX_STATUS_APPREJ THEN
      lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_INCOMPLETE;
      lp_poxv_rec.POL_ID := p_pol_id;
      lp_poxv_rec.ID := l_trx_id;

    -- create ADD transaction for Adjustment
      Okl_Pool_Pvt.update_pool_transaction(p_api_version   => p_api_version
 	                                    ,p_init_msg_list => p_init_msg_list
 	                                    ,x_return_status => l_return_status
 	                                    ,x_msg_count     => x_msg_count
 	                                    ,x_msg_data      => x_msg_data
 	                                    ,p_poxv_rec      => lp_poxv_rec
 	                                    ,x_poxv_rec      => lx_poxv_rec);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
   END IF;

END IF;


/* sosharma end changes*/

/* ankushar 26-JUL-2007
    Bug#6000531
    start changes
*/
	IF p_log_message ='Y' THEN
/* ankushar end changes 26-Jul-2007*/
   /*** REJECTS ***/
		    -- note preceding table header
		    Fnd_File.Put_Line(Fnd_File.output,' ');
		    Fnd_File.Put_Line(Fnd_File.output,Fnd_Message.get_string(g_app_name,g_pool_add_tbl_hdr));

			-- table header
		       Fnd_File.Put_Line(Fnd_File.output,RPAD('-',l_row_num_len-1,'-') || ' '
			             || RPAD('-',l_contract_num_len-1,'-') || ' '
			             || RPAD('-',l_asset_num_len-1,'-') || ' '
						 || RPAD('-',l_lessee_len-1,'-') || ' '
						 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
						 || RPAD('-',l_reject_code_len-1,'-'));

		       Fnd_File.Put_Line(Fnd_File.output,RPAD(Fnd_Message.get_string(g_app_name,g_row_number),l_row_num_len-1) || ' '
			                || RPAD(Fnd_Message.get_string(g_app_name,g_contract_number),l_contract_num_len-1) || ' '
			                || RPAD(Fnd_Message.get_string(g_app_name,g_asset_number),l_asset_num_len-1) || ' '
		                    || RPAD(Fnd_Message.get_string(g_app_name,g_lessee),l_lessee_len-1) || ' '
		                    || RPAD(Fnd_Message.get_string(g_app_name,g_stream_type_subclass),l_sty_subclass_len-1) || ' '
		                    || RPAD(Fnd_Message.get_string(g_app_name,g_reject_reason_code),l_reject_code_len-1));

		       Fnd_File.Put_Line(Fnd_File.output,RPAD('-',l_row_num_len-1,'-') || ' '
			             || RPAD('-',l_contract_num_len-1,'-') || ' '
			             || RPAD('-',l_asset_num_len-1,'-') || ' '
						 || RPAD('-',l_lessee_len-1,'-') || ' '
						 || RPAD('-',l_sty_subclass_len-1,'-') || ' '
						 || RPAD('-',l_reject_code_len-1,'-'));

			FOR i IN 1..l_rejects_msg_tbl.COUNT
			LOOP
     			Fnd_File.Put_Line(Fnd_File.OUTPUT, l_rejects_msg_tbl(i).msg);
			END LOOP;

		    Fnd_File.Put_Line(Fnd_File.OUTPUT,' ');
		    Fnd_File.Put_Line(Fnd_File.OUTPUT,Fnd_Message.GET_STRING(G_APP_NAME,G_REJECT_REASON_CODES));

		    -- Listing Reason Code Meaning-s
			FOR l_okl_reject_codes_rec IN l_okl_reject_codes_csr
			LOOP
		      Fnd_File.Put_Line(Fnd_File.OUTPUT,l_filler || l_okl_reject_codes_rec.lookup_code
			                                                  || ' => '
															  || l_okl_reject_codes_rec.meaning);
		    END LOOP;

		/*** ADDS ***/

		    -- note preceding table header
		    Fnd_File.Put_Line(Fnd_File.output,' ');
		    Fnd_File.Put_Line(Fnd_File.output,' ');
		    Fnd_File.Put_Line(Fnd_File.output,' ');
		    Fnd_File.Put_Line(Fnd_File.output,' ');
		    Fnd_File.Put_Line(Fnd_File.output,Fnd_Message.get_string(g_app_name,g_pool_add_new_tbl_hdr));

			-- table header
		       Fnd_File.Put_Line(Fnd_File.output,RPAD('-',l_row_num_len-1,'-') || ' '
			             || RPAD('-',l_contract_num_len-1,'-') || ' '
			             || RPAD('-',l_asset_num_len-1,'-') || ' '
						 || RPAD('-',l_lessee_len-1,'-') || ' '
						 || RPAD('-',l_sty_subclass_len-1,'-'));

		       Fnd_File.Put_Line(Fnd_File.output,RPAD(Fnd_Message.get_string(g_app_name,g_row_number),l_row_num_len-1) || ' '
			                || RPAD(Fnd_Message.get_string(g_app_name,g_contract_number),l_contract_num_len-1) || ' '
			                || RPAD(Fnd_Message.get_string(g_app_name,g_asset_number),l_asset_num_len-1) || ' '
		                    || RPAD(Fnd_Message.get_string(g_app_name,g_lessee),l_lessee_len-1) || ' '
		                    || RPAD(Fnd_Message.get_string(g_app_name,g_stream_type_subclass),l_sty_subclass_len-1));

		       Fnd_File.Put_Line(Fnd_File.output,RPAD('-',l_row_num_len-1,'-') || ' '
			             || RPAD('-',l_contract_num_len-1,'-') || ' '
			             || RPAD('-',l_asset_num_len-1,'-') || ' '
						 || RPAD('-',l_lessee_len-1,'-') || ' '
						 || RPAD('-',l_sty_subclass_len-1,'-'));

			FOR i IN 1..l_adds_msg_tbl.COUNT
			LOOP
     			Fnd_File.Put_Line(Fnd_File.OUTPUT, l_adds_msg_tbl(i).msg);
			END LOOP;

   END IF;

    x_row_count := l_add_count;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);

    x_return_status := l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                     p_pkg_name	=> G_PKG_NAME,
                p_exc_name   => G_EXC_NAME_ERROR,
                x_msg_count	=> x_msg_count,
                x_msg_data	=> x_msg_data,
                p_api_type	=> G_API_TYPE);
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                     p_pkg_name	=> G_PKG_NAME,
                p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                x_msg_count	=> x_msg_count,
                x_msg_data	=> x_msg_data,
                p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

       x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                     p_pkg_name	=> G_PKG_NAME,
                p_exc_name   => G_EXC_NAME_OTHERS,
                x_msg_count	=> x_msg_count,
                x_msg_data	=> x_msg_data,
                p_api_type	=> G_API_TYPE);


END add_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : cleanup_pool_contents
-- Description     : removes pool contents based on passed in search criteria
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
-- Create by Search Criteria:	Query Streams from contracts + Create

  PROCEDURE cleanup_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_currency_code                IN VARCHAR2
   ,p_pol_id                       IN  NUMBER
   ,p_multi_org                    IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER
   ,p_sic_code                     IN VARCHAR2
   ,p_dnz_chr_id                   IN NUMBER
   ,p_pre_tax_yield_from           IN NUMBER
   ,p_pre_tax_yield_to             IN NUMBER
   ,p_book_classification          IN VARCHAR2
   ,p_tax_owner                    IN VARCHAR2
   ,p_pdt_id                       IN NUMBER
   ,p_start_from_date              IN DATE
   ,p_start_to_date                IN DATE
   ,p_end_from_date                IN DATE
   ,p_end_to_date                  IN DATE
   ,p_asset_id                     IN NUMBER
   ,p_item_id1                     IN NUMBER
   ,p_model_number                 IN VARCHAR2
   ,p_manufacturer_name            IN VARCHAR2
   ,p_vendor_id1                   IN NUMBER
   ,p_oec_from                     IN NUMBER
   ,p_oec_to                       IN NUMBER
   ,p_residual_percentage          IN NUMBER
   ,p_sty_id                       IN NUMBER
   -- mvasudev, 11.5.10
   ,p_stream_type_subclass         IN VARCHAR2
   -- end, mvasudev, 11.5.10
   ,p_streams_from_date            IN DATE
   ,p_streams_to_date              IN DATE
   ,p_action_code                  IN VARCHAR2
   ,x_poc_uv_tbl                   OUT NOCOPY poc_uv_tbl_type
   ,p_cust_crd_clf_code            IN VARCHAR2 DEFAULT NULL)
 IS
  l_api_name         CONSTANT VARCHAR2(30) := 'cleanup_pool_contents';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_pocv_rec         pocv_rec_type;
  lp_poxv_rec         poxv_rec_type;
   lx_poxv_rec        poxv_rec_type;

  l_transaction_status VARCHAR2(30);
  l_trx_id  NUMBER;

  CURSOR l_okl_pool_cleanup_csr(p_allowed_sts Varchar2) IS
  SELECT pocv.poc_id
        ,pocv.contract_number
		,pocv.asset_number
		,pocv.lessee
		,pocv.stream_type_name
		,pocv.sty_subclass_code
		,pocv.sty_subclass
   		-- mvasudev, 09/28/2004, Bug#3909240
   		,pocv.stream_type_purpose
   		,hcp.credit_classification
  FROM   okl_pool_contents_uv pocv
         ,hz_customer_profiles hcp
  -- pool_number
  WHERE  pocv.pol_id = p_pol_id
  -- customer
  AND    NVL(pocv.cust_object1_id1,G_DEFAULT_NUM) = NVL(p_cust_object1_id1, NVL(pocv.cust_object1_id1,G_DEFAULT_NUM))
  AND    NVL(pocv.sic_code,G_DEFAULT_CHAR) = NVL(p_sic_code, NVL(pocv.sic_code,G_DEFAULT_CHAR))
  -- contract
  AND    NVL(pocv.dnz_chr_id,G_DEFAULT_NUM) = NVL(p_dnz_chr_id, NVL(pocv.dnz_chr_id,G_DEFAULT_NUM))
  AND    NVL(pocv.pre_tax_yield,G_DEFAULT_NUM) BETWEEN NVL(p_pre_tax_yield_from, NVL(pocv.pre_tax_yield,G_DEFAULT_NUM))
  AND    NVL(p_pre_tax_yield_to, NVL(pocv.pre_tax_yield,G_DEFAULT_NUM))
  AND    NVL(pocv.book_classification,G_DEFAULT_CHAR) = NVL(p_book_classification, NVL(pocv.book_classification,G_DEFAULT_CHAR))
  AND    NVL(pocv.pdt_id,G_DEFAULT_NUM) = NVL(p_pdt_id, NVL(pocv.pdt_id,G_DEFAULT_NUM))
  AND    NVL(pocv.start_date, G_DEFAULT_DATE)
             BETWEEN NVL(p_start_from_date, NVL(pocv.start_date, G_DEFAULT_DATE))
             AND     NVL(p_start_to_date, NVL(pocv.start_date, G_DEFAULT_DATE))
  AND    NVL(pocv.end_date,G_FINAL_DATE)
            BETWEEN NVL(p_end_from_date, NVL(pocv.end_date,G_FINAL_DATE))
            AND     NVL(p_end_to_date, NVL(pocv.end_date,G_FINAL_DATE))
  AND    NVL(pocv.tax_owner,G_DEFAULT_CHAR) = NVL(p_tax_owner, NVL(pocv.tax_owner,G_DEFAULT_CHAR))
  -- asset
/* cklee, 04/23/2003
  AND    NVL(pocv.asset_id,G_DEFAULT_NUM) = NVL(p_asset_id, NVL(pocv.asset_id,G_DEFAULT_NUM))
  AND    NVL(UPPER(pocv.model_number),G_DEFAULT_CHAR) LIKE NVL(UPPER(p_model_number),NVL(UPPER(pocv.model_number),G_DEFAULT_CHAR))
  AND    NVL(UPPER(pocv.manufacturer_name),G_DEFAULT_CHAR) LIKE NVL(UPPER(p_manufacturer_name),NVL(UPPER(pocv.manufacturer_name),G_DEFAULT_CHAR))
  AND    NVL(pocv.item_id1,G_DEFAULT_NUM) = NVL(p_item_id1, NVL(pocv.item_id1,G_DEFAULT_NUM))
  AND    NVL(pocv.vendor_id1,G_DEFAULT_NUM) = NVL(p_vendor_id1, NVL(pocv.vendor_id1,G_DEFAULT_NUM))
  AND    NVL(pocv.oec,G_DEFAULT_NUM) BETWEEN NVL(p_oec_from, NVL(pocv.oec,G_DEFAULT_NUM))
  AND    NVL(p_oec_to, NVL(pocv.oec,G_DEFAULT_NUM))
  AND    NVL(pocv.residual_percentage,G_DEFAULT_NUM) = NVL(p_residual_percentage, NVL(pocv.residual_percentage,G_DEFAULT_NUM))
*/
  -- streams
   -- mvasudev, 11.5.10
  --AND    NVL(pocv.sty_id,G_DEFAULT_NUM) = NVL(p_sty_id, NVL(pocv.sty_id,G_DEFAULT_NUM))
  AND    NVL(pocv.sty_subclass_code,G_DEFAULT_CHAR) = NVL(p_stream_type_subclass, NVL(pocv.sty_subclass_code,G_DEFAULT_CHAR))
   -- end, mvasudev, 11.5.10
  AND    NVL(pocv.streams_from_date, G_DEFAULT_DATE)
             BETWEEN NVL(p_streams_from_date, NVL(pocv.streams_from_date, G_DEFAULT_DATE))
	         AND     NVL(p_streams_to_date, NVL(pocv.streams_to_date, G_FINAL_DATE))
-- cklee 04/10/2003
  AND   EXISTS (SELECT '1'
                FROM okl_pool_contents pc
                WHERE pc.id = pocv.POC_ID
                AND   pc.status_code IN (p_allowed_sts))
-- cklee 04/10/2003
--Bug # 6691554 Changes for Cust Credit Classification Lov Start
  AND pocv.cust_object1_id1 = hcp.party_id(+)
  AND hcp.cust_account_id(+) = -1
  AND hcp.site_use_id(+) IS NULL
  AND NVL(hcp.credit_classification(+),G_DEFAULT_CHAR) = NVL(p_cust_crd_clf_code, NVL(hcp.credit_classification(+),G_DEFAULT_CHAR))
--Bug # 6691554 Changes for Cust Credit Classification Lov End
  ORDER BY  pocv.contract_number
           ,pocv.asset_number
           ,pocv.stream_type_name;


  lp_pocv_tbl pocv_tbl_type;

  l_row_count         NUMBER;
  l_pool_amount       NUMBER;
  --Begin - Changes for Bug 6640050 by varangan on 29-Nov-2007
	CURSOR c_strm_amount ( p_poc_id NUMBER)
	IS
	SELECT 	NVL(SUM(NVL(ele.AMOUNT,0)),0) STREAM_AMOUNT
	FROM	okl_streams       strm
		,okl_strm_elements ele
		,okl_pool_contents cnt
	WHERE  strm.id       = ele.stm_id
	AND    cnt.ID        = p_poc_id
	AND    strm.ID   = cnt.STM_ID
	AND    strm.say_code = 'CURR'
	AND    strm.active_yn = 'Y'
	AND    cnt.status_code IN (G_POC_STS_PENDING)
	AND    ele.STREAM_ELEMENT_DATE
	BETWEEN cnt.STREAMS_FROM_DATE AND NVL(cnt.STREAMS_TO_DATE,G_FINAL_DATE);

  l_allowed_status Varchar2(100);
  l_status_code      okl_pools.status_Code%TYPE;
  --End - Changes for Bug 6640050 by varangan on 29-Nov-2007

BEGIN
	l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
					      p_pkg_name	   => G_PKG_NAME,
					      p_init_msg_list  => p_init_msg_list,
					      l_api_version	   => l_api_version,
					      p_api_version	   => p_api_version,
					      p_api_type	   => G_API_TYPE,

					      x_return_status  => l_return_status);
	IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = G_RET_STS_ERROR) THEN
		RAISE G_EXCEPTION_ERROR;
	END IF;


	l_row_count := 0;
	-- Begin - Changes for Bug#6658065
	 --(1) Check the pool status for clean up action
	 FOR pool_status_rec IN pool_status_csr(p_pol_id)
	 LOOP
		l_status_code := pool_status_rec.status_code;
	 END LOOP;
	 --(2)  If the Status is 'Active', then only 'Pending' status pool contents created for adjustment should be removed
	 --     else, existing flow should be followed
	  IF l_status_code = G_POL_STS_ACTIVE  THEN
		l_allowed_status:= G_POC_STS_PENDING;
	  ELSE
	  	l_allowed_status:=G_POC_STS_NEW; -- Fetch only 'New' status POCs for Bug 6691554
	  END IF;
	 --(3) Query the pool contents as per the status check
	  FOR l_okl_pool_cleanup_rec IN l_okl_pool_cleanup_csr(l_allowed_status)
	  LOOP
		l_row_count := 	l_row_count + 1;
		lp_pocv_tbl(l_row_count).id := l_okl_pool_cleanup_rec.poc_id;
		 -- Get Pool Stream Amount to Display
		 IF l_status_code= G_POL_STS_ACTIVE  THEN -- Get the pending contents stream amount
			OPEN c_strm_amount (l_okl_pool_cleanup_rec.poc_id) ;
			FETCH c_strm_amount INTO l_pool_amount;
			CLOSE c_strm_amount;
		ELSE -- follow the existing process
			l_pool_amount := Okl_Pool_Pvt.get_pool_stream_amout(l_okl_pool_cleanup_rec.poc_id);
		END IF;

		x_poc_uv_tbl(l_row_count).poc_id :=  l_okl_pool_cleanup_rec.poc_id;
		x_poc_uv_tbl(l_row_count).contract_number :=  l_okl_pool_cleanup_rec.contract_number;
		x_poc_uv_tbl(l_row_count).asset_number :=  l_okl_pool_cleanup_rec.asset_number;
		x_poc_uv_tbl(l_row_count).lessee :=  l_okl_pool_cleanup_rec.lessee;
		x_poc_uv_tbl(l_row_count).stream_type_name :=  l_okl_pool_cleanup_rec.stream_type_name;

		x_poc_uv_tbl(l_row_count).sty_subclass_code :=  l_okl_pool_cleanup_rec.sty_subclass_code;
		x_poc_uv_tbl(l_row_count).sty_subclass     :=  l_okl_pool_cleanup_rec.sty_subclass;

		x_poc_uv_tbl(l_row_count).pool_amount :=  l_pool_amount;
		-- mvasudev, 09/28/2004, Bug#3909240
		x_poc_uv_tbl(l_row_count).stream_type_purpose :=  l_okl_pool_cleanup_rec.stream_type_purpose;

	  END LOOP;
	-- End - Changes for Bug#6658065

	    IF p_action_code = Okl_Pool_Pvt.G_ACTION_REMOVE THEN
	      Okl_Pool_Pvt.delete_pool_contents(p_api_version     => p_api_version
					     ,p_init_msg_list   => p_init_msg_list
					     ,x_return_status   => l_return_status
					     ,x_msg_count       => x_msg_count
					     ,x_msg_data        => x_msg_data
					     ,p_pocv_tbl        => lp_pocv_tbl);

	      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
		RAISE G_EXCEPTION_ERROR;
	      END IF;
	    END IF;

-- get existing the transaction status
    OPEN l_trans_status_csr(p_pol_id);
       FETCH l_trans_status_csr INTO l_transaction_status,l_trx_id;
       CLOSE l_trans_status_csr;

    IF l_transaction_status = G_POOL_TRX_STATUS_APPREJ THEN
      lp_poxv_rec.TRANSACTION_STATUS := G_POOL_TRX_STATUS_INCOMPLETE;
      lp_poxv_rec.POL_ID := p_pol_id;
      lp_poxv_rec.ID := l_trx_id;

    -- create ADD transaction for Adjustment
      Okl_Pool_Pvt.update_pool_transaction(p_api_version   => p_api_version
 	                                    ,p_init_msg_list => p_init_msg_list
 	                                    ,x_return_status => l_return_status
 	                                    ,x_msg_count     => x_msg_count
 	                                    ,x_msg_data      => x_msg_data
 	                                    ,p_poxv_rec      => lp_poxv_rec
 	                                    ,x_poxv_rec      => lx_poxv_rec);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
   END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data	  => x_msg_data);

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
END cleanup_pool_contents;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : reconcile_contents
-- Description     : reconcile pool contents
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE reconcile_contents(p_api_version                  IN NUMBER
                              ,p_init_msg_list                IN VARCHAR2
                              ,p_pol_id                       IN NUMBER
                              ,p_mode                         IN VARCHAR2 DEFAULT NULL
                              ,x_return_status                OUT NOCOPY VARCHAR2
                              ,x_msg_count                    OUT NOCOPY NUMBER
                              ,x_msg_data                     OUT NOCOPY VARCHAR2
                              ,x_reconciled                   OUT NOCOPY VARCHAR2)
  IS
	  --fmiao 21-OCT-2005 bug 4775555 --
   CURSOR evg_rent_strms_csr (p_pol_id IN NUMBER)
   IS
   -- to remove all the rent strms if the contract turns to EVERGREEN--
   SELECT poc.id
   FROM okl_pool_contents poc,
        okl_pools pol,
		okl_strm_type_b sty,
		okc_k_headers_b CHR
   WHERE pol.id = p_pol_id
   AND pol.id = poc.pol_id
   AND poc.sty_id = sty.id
   AND sty.STREAM_TYPE_SUBCLASS ='RENT'
   AND poc.KHR_ID = CHR.id
   AND CHR.sts_code ='EVERGREEN'
   AND poc.status_code  IN (G_POC_STS_NEW, G_POC_STS_ACTIVE) ;
   --fmiao 21-OCT-2005 bug 4775555 --

   CURSOR l_okl_invalid_khr_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to invalid contracts
   SELECT poc.id
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb,
		  okl_k_headers khrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   AND    poc.khr_id = khrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   AND    (chrb.sts_code NOT IN ('BOOKED','EVERGREEN')  OR khrb.assignable_yn <> 'Y');

   CURSOR l_okl_delinq_khr_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to delinquent contracts
   SELECT poc.id
   FROM   okl_pool_contents poc,
		  iex_case_objects ico,
		  iex_delinquencies_all del
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = ico.object_id
   AND    ico. cas_id = del.case_id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   AND    del.status  = 'DELINQUENT';

   CURSOR l_okl_rev_khr_csr(p_pol_id IN NUMBER)
   IS
   -- and to remove all contents pointing to contracts under modification
   SELECT poc.id
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   -- AND    chrb.sts_code = 'BOOKED'
   AND EXISTS -- revision contract: rebook, split contract, reverse
       (SELECT '1'
        FROM  okl_trx_contracts trxb
        WHERE trxb.tcn_type IN ('TRBK','SPLC','RVS')
   --   AND   trxb.tsu_code = 'ENTERED'
        AND   trxb.tsu_code NOT IN ('PROCESSED', 'ERROR','CANCELED') -- condition changes 01/13/2003 cklee
        AND   trxb.khr_id = poc.khr_id
	   )
   AND EXISTS -- split assets, split assets components
       (SELECT '1'
        FROM okl_txd_assets_v tdas,
             okl_txl_assets_b talb,
             okc_k_lines_b    cleb
        WHERE cleb.id = talb.kle_id
		AND   talb.ID = tdas.TAL_ID
		AND   talb.TAL_TYPE = 'ALI'
		AND   cleb.cle_id = poc.kle_id -- top line id
        AND   talb.dnz_khr_id = poc.khr_id
		AND   EXISTS (SELECT '1'
                      FROM  okl_trx_assets tas
                      WHERE tas.id = talb.tas_id
                      AND tas.tas_type = 'ALI'
                      AND tas.tsu_code = 'PROCESSED')
	   );

   CURSOR l_okl_invalid_assets_csr(p_pol_id IN NUMBER)
   IS
   -- and to remove all contents pointing to lease contracts
   --  that have atleast one invalid asset
   SELECT poc.id
   FROM   okl_pool_contents poc
   WHERE  poc.khr_id
          IN
		  (SELECT poc.khr_id
           FROM   okl_pool_contents poc,
                  okc_k_lines_b cleb,
             	  okc_statuses_b stsb
           WHERE  poc.pol_id = p_pol_id
           AND    poc.kle_id = cleb.id
           AND    cleb.sts_code = stsb.code
           -- cklee 04/10/2003 never reconcile historical data
           AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
           -- cklee 04/10/2003 never reconcile historical data
           AND    stsb.ste_code IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
		  );

   -- v115.37 Fix
   CURSOR l_okl_invalid_streams_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to inactive streams
   --- or assets that do not have streams
   /*
   SELECT poc.id
   FROM   okl_pool_contents poc,
          okl_streams stmb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.kle_id = stmb.kle_id
   AND    poc.sty_id = stmb.sty_id
   AND    (
            -- if the streams are not active
             stmb.active_yn <> 'Y'
	    --if stream elements do not exist

           OR NOT EXISTS
            (
		     SELECT '1'
             FROM okl_strm_elements selb
             WHERE selb.stm_id = stmb.id
            )
          );
   */
   SELECT poc.id
   FROM   okl_pool_contents poc
   WHERE  poc.pol_id = p_pol_id
   AND NOT EXISTS
       ( SELECT	 '1'
	 FROM       OKL_POOL_STREAMS_UV pols
         WHERE  poc.stm_id = pols.stm_id
         AND pols.stream_say_code = 'CURR'
         AND pols.stream_active_yn = 'Y'
		 -- mvasudev, 02/06/2004
         --AND pols.stream_element_due_date > SYSDATE
		 )
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   ;
   -- cklee 04/10/2003 never reconcile historical data


   CURSOR l_okl_update_khr_dates_csr(p_pol_id IN NUMBER)
   IS
   SELECT poc.id, chrb.end_date
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   -- mvasudev,02/06/2004
   AND    poc.streams_to_date <> chrb.end_date+1;

   CURSOR l_okl_update_dates_csr(p_pol_id IN NUMBER)
   IS
   SELECT  poc.id, poc.stm_id
   FROM    okl_pool_contents poc
          ,okl_streams stmb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.stm_id = stmb.id
   AND    stmb.say_code = 'CURR'
   AND    stmb.active_yn = 'Y'
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   AND    TRUNC(poc.streams_from_date) <> ( SELECT TRUNC(MIN(selb.stream_element_date))
                                     FROM okl_strm_elements selb
           WHERE selb.stm_id = stmb.id
           AND   selb.date_billed IS NULL
           -- mvasudev, 02/06/2004
           --AND   selb.stream_element_date > SYSDATE
            );

/* sosharma 26-Dec-2007
New cursors to reconcile Transient pool contents
Start Changes
*/
   CURSOR evg_rent_strms_pend_csr (p_pol_id IN NUMBER)
   IS
   -- to remove all the rent strms if the contract turns to EVERGREEN--
   SELECT poc.id
   FROM okl_pool_contents poc,
        okl_pools pol,
		okl_strm_type_b sty,
		okc_k_headers_b CHR
   WHERE pol.id = p_pol_id
   AND pol.id = poc.pol_id
   AND poc.sty_id = sty.id
   AND sty.STREAM_TYPE_SUBCLASS ='RENT'
   AND poc.KHR_ID = CHR.id
   AND CHR.sts_code ='EVERGREEN'
   AND poc.status_code = G_POC_STS_PENDING ;
   --fmiao 21-OCT-2005 bug 4775555 --

   CURSOR l_okl_invalid_khr_pend_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to invalid contracts
   SELECT poc.id
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb,
		  okl_k_headers khrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   AND    poc.khr_id = khrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_PENDING)
   -- cklee 04/10/2003 never reconcile historical data
   AND    (chrb.sts_code NOT IN ('BOOKED','EVERGREEN')  OR khrb.assignable_yn <> 'Y');

   CURSOR l_okl_delinq_khr_pend_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to delinquent contracts
   SELECT poc.id
   FROM   okl_pool_contents poc,
		  iex_case_objects ico,
		  iex_delinquencies_all del
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = ico.object_id
   AND    ico. cas_id = del.case_id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_PENDING)
   -- cklee 04/10/2003 never reconcile historical data
   AND    del.status  = 'DELINQUENT';

   CURSOR l_okl_rev_khr_pend_csr(p_pol_id IN NUMBER)
   IS
   -- and to remove all contents pointing to contracts under modification
   SELECT poc.id
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_PENDING)
   -- cklee 04/10/2003 never reconcile historical data
   -- AND    chrb.sts_code = 'BOOKED'
   AND EXISTS -- revision contract: rebook, split contract, reverse
       (SELECT '1'
        FROM  okl_trx_contracts trxb
        WHERE trxb.tcn_type IN ('TRBK','SPLC','RVS')
   --   AND   trxb.tsu_code = 'ENTERED'
        AND   trxb.tsu_code NOT IN ('PROCESSED', 'ERROR','CANCELED') -- condition changes 01/13/2003 cklee
        AND   trxb.khr_id = poc.khr_id
	   )
   AND EXISTS -- split assets, split assets components
       (SELECT '1'
        FROM okl_txd_assets_v tdas,
             okl_txl_assets_b talb,
             okc_k_lines_b    cleb
        WHERE cleb.id = talb.kle_id
		AND   talb.ID = tdas.TAL_ID
		AND   talb.TAL_TYPE = 'ALI'
		AND   cleb.cle_id = poc.kle_id -- top line id
        AND   talb.dnz_khr_id = poc.khr_id
		AND   EXISTS (SELECT '1'
                      FROM  okl_trx_assets tas
                      WHERE tas.id = talb.tas_id
                      AND tas.tas_type = 'ALI'
                      AND tas.tsu_code = 'PROCESSED')
	   );

   CURSOR l_okl_invalid_assets_pend_csr(p_pol_id IN NUMBER)
   IS
   -- and to remove all contents pointing to lease contracts
   --  that have atleast one invalid asset
   SELECT poc.id
   FROM   okl_pool_contents poc
   WHERE  poc.khr_id
          IN
		  (SELECT poc.khr_id
           FROM   okl_pool_contents poc,
                  okc_k_lines_b cleb,
             	  okc_statuses_b stsb
           WHERE  poc.pol_id = p_pol_id
           AND    poc.kle_id = cleb.id
           AND    cleb.sts_code = stsb.code
           -- cklee 04/10/2003 never reconcile historical data
           AND    poc.status_code IN (G_POC_STS_PENDING)
           -- cklee 04/10/2003 never reconcile historical data
           AND    stsb.ste_code IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
		  );

   -- v115.37 Fix
   CURSOR l_okl_invalid_streams_pend_csr(p_pol_id IN NUMBER)
   IS
   -- to remove all contents pointing to inactive streams
   --- or assets that do not have streams
   SELECT poc.id
   FROM   okl_pool_contents poc
   WHERE  poc.pol_id = p_pol_id
   AND NOT EXISTS
       ( SELECT	 '1'
	 FROM       OKL_POOL_STREAMS_UV pols
         WHERE  poc.stm_id = pols.stm_id
         AND pols.stream_say_code = 'CURR'
         AND pols.stream_active_yn = 'Y'
		 -- mvasudev, 02/06/2004
         --AND pols.stream_element_due_date > SYSDATE
		 )
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_PENDING)
   ;
   -- cklee 04/10/2003 never reconcile historical data


   CURSOR l_okl_update_khr_dts_pend_csr(p_pol_id IN NUMBER)
   IS
   SELECT poc.id, chrb.end_date
   FROM   okl_pool_contents poc,
          okc_k_headers_b chrb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.khr_id = chrb.id
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_NEW, G_POC_STS_ACTIVE)
   -- cklee 04/10/2003 never reconcile historical data
   -- mvasudev,02/06/2004
   AND    poc.streams_to_date <> chrb.end_date+1;

   CURSOR l_okl_update_dates_pend_csr(p_pol_id IN NUMBER)
   IS
   SELECT  poc.id, poc.stm_id
   FROM    okl_pool_contents poc
          ,okl_streams stmb
   WHERE  poc.pol_id = p_pol_id
   AND    poc.stm_id = stmb.id
   AND    stmb.say_code = 'CURR'
   AND    stmb.active_yn = 'Y'
   -- cklee 04/10/2003 never reconcile historical data
   AND    poc.status_code IN (G_POC_STS_PENDING)
   -- cklee 04/10/2003 never reconcile historical data
   AND    TRUNC(poc.streams_from_date) <> ( SELECT TRUNC(MIN(selb.stream_element_date))
                                     FROM okl_strm_elements selb
									 WHERE selb.stm_id = stmb.id
									 AND   selb.date_billed IS NULL
									 -- mvasudev, 02/06/2004
									 --AND   selb.stream_element_date > SYSDATE
								   );
/* End changes */


   CURSOR l_okl_valid_dates_csr(p_stm_id IN NUMBER)
   IS
   SELECT MIN(selb.stream_element_date)
   FROM   okl_strm_elements selb
         ,okl_streams stmb
   WHERE selb.stm_id = stmb.id
   AND   selb.date_billed IS NULL
   -- mvasudev, 02/06/2004
   --AND   selb.stream_element_date > SYSDATE
   AND   stmb.id = p_stm_id
   AND   stmb.say_code = 'CURR'
   AND   stmb.active_yn = 'Y';

   l_api_name         CONSTANT VARCHAR2(30) := 'reconcile_contents';
   l_api_version      CONSTANT NUMBER       := 1.0;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   lp_pocv_tbl         pocv_tbl_type;
   lx_pocv_tbl         pocv_tbl_type;
   lp_polv_rec         polv_rec_type;
   lx_polv_rec         polv_rec_type;

   i NUMBER := 1;
   l_date DATE;

  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    x_reconciled := Okl_Api.G_FALSE;


 /*sosharma 26-Dec-2007
Bifurcating further processing based on the value of p_mode
 Start Changes
 */
IF p_mode IS NULL THEN
 --fmiao 21-OCT-2005 bug 4775555 --
 i := 1;
	FOR  evg_rent_strms_rec IN evg_rent_strms_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := evg_rent_strms_rec.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
        i := i + 1;
    END LOOP;

    IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove rent streams for EVERGREEN contract from pool--
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
    END IF;
    lp_pocv_tbl.DELETE; -- clear
	--fmiao 21-OCT-2005 bug 4775555 --

    i := 1; -- initialize
    FOR  l_okl_invalid_khr IN l_okl_invalid_khr_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the invalid khrs
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;


    lp_pocv_tbl.DELETE; -- clear
    i := 1; -- initialize
    FOR  l_okl_delinq_khr IN l_okl_delinq_khr_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_delinq_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the delinquent khrs
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;





    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_rev_khr IN l_okl_rev_khr_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_rev_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rev khr rows
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;


    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_invalid_assets IN l_okl_invalid_assets_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_assets.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rows of invalid_assets
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_invalid_streams IN l_okl_invalid_streams_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_streams.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rows of invalid_streams
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear the contents to get updatable rows

    -- Collect all the records that need to be updated for Contract dates
    i := 1;
    FOR l_okl_update_khr_dates IN l_okl_update_khr_dates_csr(p_pol_id)
	LOOP

		lp_pocv_tbl(i).id := l_okl_update_khr_dates.id;

        lp_pocv_tbl(i).pol_id := p_pol_id;
		-- mvasudev, 02/06/2004
		lp_pocv_tbl(i).streams_to_date := l_okl_update_khr_dates.end_date+1;
	i := i + 1;
	END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN
	-- Update the rows with correct stream dates
      Okl_Pool_Pvt.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl,
		x_pocv_tbl      => lx_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear the contents to get new updatable rows

    -- Collect all the records that need to be updated for Stream dates
    i := 1;
    FOR l_okl_update_dates IN l_okl_update_dates_csr(p_pol_id)
	LOOP

        l_date := NULL;
        OPEN  l_okl_valid_dates_csr(l_okl_update_dates.stm_id);
		FETCH l_okl_valid_dates_csr INTO l_date;
		CLOSE l_okl_valid_dates_csr;

		lp_pocv_tbl(i).id := l_okl_update_dates.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
		lp_pocv_tbl(i).streams_from_date := l_date;

	i := i + 1;
	END LOOP;
   IF lp_pocv_tbl.COUNT > 0 THEN
	-- Update the rows with correct stream dates
      Okl_Pool_Pvt.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl,
		x_pocv_tbl      => lx_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;

ELSE

 i := 1;
	FOR  evg_rent_strms_rec IN evg_rent_strms_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := evg_rent_strms_rec.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
        i := i + 1;
    END LOOP;

    IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove rent streams for EVERGREEN contract from pool--
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
    END IF;
    lp_pocv_tbl.DELETE; -- clear
	--fmiao 21-OCT-2005 bug 4775555 --

    i := 1; -- initialize
    FOR  l_okl_invalid_khr IN l_okl_invalid_khr_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the invalid khrs
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;


    lp_pocv_tbl.DELETE; -- clear
    i := 1; -- initialize
    FOR  l_okl_delinq_khr IN l_okl_delinq_khr_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_delinq_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the delinquent khrs
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;





    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_rev_khr IN l_okl_rev_khr_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_rev_khr.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rev khr rows
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;


    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_invalid_assets IN l_okl_invalid_assets_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_assets.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rows of invalid_assets
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear

    i := 1; -- initialize
    FOR  l_okl_invalid_streams IN l_okl_invalid_streams_pend_csr(p_pol_id)
    LOOP
        lp_pocv_tbl(i).id := l_okl_invalid_streams.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
   i := i + 1;
   END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN

      -- Remove the rows of invalid_streams
      Okl_Pool_Pvt.delete_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear the contents to get updatable rows

    -- Collect all the records that need to be updated for Contract dates
    i := 1;
    FOR l_okl_update_khr_dates IN l_okl_update_khr_dts_pend_csr(p_pol_id)
	LOOP

		lp_pocv_tbl(i).id := l_okl_update_khr_dates.id;

        lp_pocv_tbl(i).pol_id := p_pol_id;
		-- mvasudev, 02/06/2004
		lp_pocv_tbl(i).streams_to_date := l_okl_update_khr_dates.end_date+1;
	i := i + 1;
	END LOOP;

   IF lp_pocv_tbl.COUNT > 0 THEN
	-- Update the rows with correct stream dates
      Okl_Pool_Pvt.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl,
		x_pocv_tbl      => lx_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;

    lp_pocv_tbl.DELETE; -- clear the contents to get new updatable rows

    -- Collect all the records that need to be updated for Stream dates
    i := 1;
    FOR l_okl_update_dates IN l_okl_update_dates_pend_csr(p_pol_id)
	LOOP

        l_date := NULL;
        OPEN  l_okl_valid_dates_csr(l_okl_update_dates.stm_id);
		FETCH l_okl_valid_dates_csr INTO l_date;
		CLOSE l_okl_valid_dates_csr;

		lp_pocv_tbl(i).id := l_okl_update_dates.id;
        lp_pocv_tbl(i).pol_id := p_pol_id;
		lp_pocv_tbl(i).streams_from_date := l_date;

	i := i + 1;
	END LOOP;
   IF lp_pocv_tbl.COUNT > 0 THEN
	-- Update the rows with correct stream dates
      Okl_Pool_Pvt.update_pool_contents(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pocv_tbl      => lp_pocv_tbl,
		x_pocv_tbl      => lx_pocv_tbl);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_reconciled := Okl_Api.G_TRUE;
   END IF;
END IF;
/*sosharma end changes*/

    -- update date_last_reconciled
        lp_polv_rec.id := p_pol_id;
        lp_polv_rec.date_last_reconciled := SYSDATE;
    Okl_Pol_Pvt.update_row(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
		p_polv_rec       => lp_polv_rec,
		x_polv_rec       => lx_polv_rec);

      IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;

      ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);

	x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

  END reconcile_contents;

----------------------------------------------------------------------------------
-- Start of comments
--

-- Procedure Name  : update_pool_status_active
-- Description     : updates a pool header, and contents' status.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_status_active(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN okl_pools.id%TYPE)
IS


  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_status_active';
  l_api_version      CONSTANT NUMBER       := 1.0;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_status_active_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    update_pool_status(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pool_status   => G_POL_STS_ACTIVE,
        p_pol_id        => p_pol_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_status_active_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

    ROLLBACK TO update_pool_status_active_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_status_active_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_status_active;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_pool_status_expired
-- Description     : updates a pool header, and contents' status.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_pool_status_expired(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN okl_pools.id%TYPE)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool_status_expired';
  l_api_version      CONSTANT NUMBER       := 1.0;

BEGIN
  -- Set API savepoint
  SAVEPOINT update_pool_status_expired_PVT;

  -- Check for call compatibility
  IF (NOT Fnd_Api.Compatible_API_Call (l_api_version,
                                	   p_api_version,

                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN

    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
      Fnd_Msg_Pub.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    update_pool_status(
        p_api_version   => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data,
        p_pool_status   => G_POL_STS_EXPIRED,
        p_pol_id        => p_pol_id);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	Fnd_Msg_Pub.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_pool_status_expired_PVT;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_pool_status_expired_PVT;
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_pool_status_expired_PVT;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;
      Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,

                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      Fnd_Msg_Pub.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

END update_pool_status_expired;

----------------------------------------------------------------------------------
-- Start of comments
--  mvasudev
-- Procedure Name  : get_total_stream_amount
-- Description     : Gets the Total Stream Amount for a given POC using the stm_id
--                   regardless of its status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE get_total_stream_amount(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_poc_id                       IN  okl_pool_contents.id%TYPE
   ,p_stm_id                       IN okl_streams.id%TYPE
   ,x_amount                       OUT NOCOPY NUMBER
 )
 IS

   l_api_name         CONSTANT VARCHAR2(30) := 'get_total_stream_amount';
   l_api_version      CONSTANT NUMBER       := 1.0;
   i                  NUMBER;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  CURSOR l_okl_poc_stm_csr
  IS
  SELECT NVL(SUM(NVL(selb.amount,0)),0) amount
  FROM   okl_streams       stmb
        ,okl_strm_elements selb
        ,okl_pool_contents pocb
        ,okl_strm_type_v styv
        ,okc_k_headers_b chrb
  WHERE pocb.stm_id = stmb.id
  AND   stmb.id  = selb.stm_id
  AND   pocb.id  = p_poc_id
  -- Bug#3520846,mvasudev, 3/22/2004
  AND   pocb.status_code = 'ACTIVE'
  AND   selb.date_billed IS NULL
 /*
    ankushar --Bug 6594724: Unable to terminate Investor Agreement with Residual Streams
    Start changes
   */
 AND stmb.sty_id = styv.id
 AND pocb.khr_id = chrb.id
 AND (  selb.stream_element_date > SYSDATE   OR
     ( styv.stream_type_subclass = 'RESIDUAL'
      and chrb.STS_CODE IN ('TERMINATED','EXPIRED')
   )
  )
  /* ankushar Bug 6594724
     End Changes
   */

  -- end, mvasudev
  AND   selb.stream_element_date
        BETWEEN pocb.streams_from_date AND NVL(pocb.streams_to_date,G_FINAL_DATE)
   ;

  CURSOR l_okl_poc_csr
  IS
  SELECT NVL(SUM(NVL(selb.amount,0)),0) amount
  FROM   okl_streams       stmb
        ,okl_strm_elements selb
        ,okl_pool_contents pocb
  WHERE pocb.stm_id = stmb.id
  AND   stmb.id  = selb.stm_id
  AND   pocb.id  = p_poc_id
  AND   selb.stream_element_date
        BETWEEN pocb.streams_from_date AND NVL(pocb.streams_to_date,G_FINAL_DATE)
   ;

 BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    x_amount := 0;

	-- mvasudev, 04/01/2004
	IF p_stm_id IS NOT NULL THEN
	    FOR l_okl_poc_stm_rec IN l_okl_poc_stm_csr
	    LOOP
	      x_amount := x_amount + l_okl_poc_stm_rec.amount;
	    END LOOP;
	ELSE
	    FOR l_okl_poc_rec IN l_okl_poc_csr
	    LOOP
	      x_amount := x_amount + l_okl_poc_rec.amount;
	    END LOOP;
	END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

 END get_total_stream_amount;

 /* ankushar 26-JUL-2007
    Bug#6000531  To publish OKL_POOL_PUB added a new api validate_pool
    start changes
*/
 PROCEDURE validate_pool(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2
    ,p_api_name 	         	    IN VARCHAR2
    ,p_polv_rec                     IN polv_rec_type
    ,p_action                       IN VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2

  ) IS
   l_api_name         CONSTANT VARCHAR2(30) := 'validate_pool';
   l_api_version      CONSTANT NUMBER       := 1.0;
   i                  NUMBER;
   l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_action           VARCHAR2(40) := p_api_name;
   l_contract_number   OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%type;
   l_polv_rec         polv_rec_type := p_polv_rec;

    CURSOR l_okl_pol_status_csr(p_pol_id IN NUMBER)
    IS
    SELECT status_code
    FROM   okl_pools
    WHERE  id = p_pol_id;

    -- Cursor For OKL_CURRENCIES;
   CURSOR okl_fnd_curr_csr (p_code IN OKL_POOLS.currency_code%TYPE) IS
   SELECT '1'
   FROM FND_CURRENCIES_VL
   WHERE FND_CURRENCIES_VL.currency_code = currency_code;

   l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;
 BEGIN

   -- Initialize API status to success
   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                             p_pkg_name	   => G_PKG_NAME,
                                             p_init_msg_list  => p_init_msg_list,
                                             l_api_version	   => l_api_version,
                                             p_api_version	   => p_api_version,
                                             p_api_type	   => G_API_TYPE,
                                             x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Initialize message list if requested
   IF (Fnd_Api.to_Boolean(p_init_msg_list)) THEN
       Fnd_Msg_Pub.initialize;
   END IF;

  --update validation for pool id when the pool is in active or new status
   IF l_action = 'update_pool' THEN
  		IF ((p_polv_rec.id is null) OR (p_polv_rec.id=OKL_API.G_MISS_NUM )) THEN
			OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       	END IF;
   END IF;

   --following actions are permitted only when pool status is NEW
   IF l_action in ('add_pool_contents','cleanup_pool_contents') THEN
		IF ((p_polv_rec.id is null) OR (p_polv_rec.id=OKL_API.G_MISS_NUM )) THEN
			OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
			RAISE OKL_API.G_EXCEPTION_ERROR;
		ELSE
			FOR l_okl_pol_status_rec IN l_okl_pol_status_csr(p_polv_rec.id)
			LOOP

				IF l_okl_pol_status_rec.status_code   <> Okl_Pool_Pvt.G_POL_STS_NEW THEN
					OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME, p_msg_name => 'OKL_POOL_NO_MODIFY');
					RAISE OKL_API.G_EXCEPTION_ERROR;
				END IF;
			END LOOP;
		End if;
	END IF;

   IF l_action = 'add_pool_contents' THEN
	  -- validte whether the currency code entered is correct
	  -- currency code must be entered by user while adding
      -- the pool contents

    IF (p_polv_rec.currency_code = OKL_API.G_MISS_CHAR OR
        p_polv_rec.currency_code IS NULL)
    THEN
       OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => 'OKL_REQUIRED_VALUE',
                         p_token1       => 'COL_NAME',
                        p_token1_value => 'currency_code');
      RAISE G_EXCEPTION_ERROR;
    END IF;

    OPEN okl_fnd_curr_csr(p_polv_rec.currency_code);

    FETCH okl_fnd_curr_csr INTO l_dummy;
    l_row_not_found := okl_fnd_curr_csr%NOTFOUND;
    CLOSE okl_fnd_curr_csr;

    IF l_row_not_found THEN
      OKL_API.set_message(G_APP_NAME,
                          OKL_API.G_INVALID_VALUE,
                          OKL_API.G_COL_NAME_TOKEN,
                          'currency_code');
      RAISE G_EXCEPTION_ERROR;
    END IF;

  END IF; --l_action

   -- Get message count and if count is 1, get message info
 	Fnd_Msg_Pub.Count_And_Get
     (p_count          =>      x_msg_count,
      p_data           =>      x_msg_data);

 EXCEPTION
   WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     x_return_status := Okl_Api.G_RET_STS_ERROR;
     Fnd_Msg_Pub.Count_And_Get
       (p_count         =>      x_msg_count,
        p_data          =>      x_msg_data);

   WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
     Fnd_Msg_Pub.Count_And_Get
       (p_count         =>      x_msg_count,
        p_data          =>      x_msg_data);

   WHEN OTHERS THEN
       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR ;

       Okl_Api.Set_Message(p_app_name      => G_APP_NAME,
                           p_msg_name      => G_UNEXPECTED_ERROR,
                           p_token1        => G_SQLCODE_TOKEN,
                           p_token1_value  => SQLCODE,
                           p_token2        => G_SQLERRM_TOKEN,
                           p_token2_value  => SQLERRM);
       Fnd_Msg_Pub.Count_And_Get
         (p_count         =>      x_msg_count,
          p_data          =>      x_msg_data);

 END validate_pool;
 /* ankushar end changes 26-Jul-2007*/

END Okl_Pool_Pvt;

/
