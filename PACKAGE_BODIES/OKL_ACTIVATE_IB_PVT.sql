--------------------------------------------------------
--  DDL for Package Body OKL_ACTIVATE_IB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACTIVATE_IB_PVT" AS
/* $Header: OKLRAIBB.pls 120.12.12010000.2 2009/08/10 09:38:45 rpillay ship $ */
--------------------------------------------------------------------------------
--GLOBAL VARIABLES
--------------------------------------------------------------------------------
G_TRX_LINE_TYPE_BOOK     Varchar2(30)  := 'CFA';
G_TRX_HDR_TYPE_BOOK      Varchar2(30)  := 'CFA';
G_TRX_LINE_TYPE_REBOOK   Varchar2(30)  := 'CRB';
G_TRX_HDR_TYPE_REBOOK    Varchar2(30)  := 'CRB';
G_TSU_CODE_ENTERED       Varchar2(30)  := 'ENTERED';
G_ITM_INST_PARTY         Varchar2(30)  := 'LESSEE';
G_CONTRACT_INTENT        Varchar2(1)   := 'S';
G_PARTY_SRC_TABLE        Varchar2(30)  := 'HZ_PARTIES';
G_PARTY_RELATIONSHIP     Varchar2(30)  := 'OWNER';
G_IB_LINE_LTY_CODE       Varchar2(30)  := 'INST_ITEM';
G_IB_LINE_LTY_ID         NUMBER        := 45;
G_MODEL_LINE_LTY_CODE    Varchar2(30)  := 'ITEM';
G_MODEL_LINE_LTY_ID      NUMBER        := 34;
G_APPROVED_STS_CODE      VARCHAR2(100) := 'APPROVED';
G_LEASE_SCS_CODE         VARCHAR2(30)  := 'LEASE';
G_MFG_SERIAL_NUMBER_FLAG Varchar2(1)   := 'N';
G_LOC_TYPE_CODE          Varchar2(30)  := 'HZ_LOCATIONS';
G_INSTALL_LOC_TYPE_CODE  Varchar2(30)  := 'HZ_PARTY_SITES';
G_UOM_CODE               Varchar2(10)  := 'Ea';
G_IB_BKNG_TXN_TYPE       Varchar2(30)  := 'OKL_BOOK';
G_CUST_ACCT_RULE         Varchar2(30)  := 'CAN';
G_CUST_ACCT_RULE_GROUP   Varchar2(30)  := 'LACAN';
G_IB_LINE_SRC_CODE       Varchar2(30)  := 'OKX_IB_ITEM';
G_TSU_CODE_PROCESSED     Varchar2(30)  := 'PROCESSED';
-- gboomina Bug 5362977 - Added - Start
G_INST_LINE_LTY_ID       NUMBER        := 43;
-- gboomina Bug 5362977 - End

--------------------------------------------------------------------------------
--GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_PARTY_NOT_FOUND           Varchar2(200) := 'OKL_LLA_PARTY_NOT_FOUND';
G_ROLE_CODE_TOKEN           Varchar2(30)  := 'RLE_CODE';
G_IB_TXN_TYPE_NOT_FOUND     Varchar2(200) := 'OKL_LLA_IB_TXN_TYPE_NOT_FOUND';
G_TXN_TYPE_TOKEN            Varchar2(30)  := 'TXN_TYPE';
G_CONTRACT_NOT_FOUND        VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_FOUND';
G_CONTRACT_ID_TOKEN         VARCHAR2(200) := 'CONTRACT_ID';
G_CONTRACT_NOT_APPROVED     VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_APPROVED';
G_CONTRACT_NOT_LEASE        VARCHAR2(200) := 'OKL_LLA_CONTRACT_NOT_LEASE';
G_IB_TRX_REC_NOT_FOUND      VARCHAR2(200) := 'OKL_LLA_IB_TRX_REC_NOT_FOUND';
G_IB_LINE_ID_TOKEN          VARCHAR2(100) := 'IB_LINE_ID';
G_INV_MSTR_ORG_NOT_FOUND    VARCHAR2(200) := 'OKL_LLA_INV_MSTR_ORG_NOT_FOUND';
G_CUST_ACCOUNT_FOUND        VARCHAR2(200) := 'OKL_LLA_CUST_ACCT_NOT_FOUND';
G_STS_UPDATE_TRX_MISSING    VARCHAR2(200) := 'OKL_LLA_STS_UPDATE_TRX_MISSING';
G_TAS_ID_TOKEN              VARCHAR2(100) := 'TAS_ID';
G_TRX_ALREADY_PROCESSED     VARCHAR2(200) := 'OKL_LLA_TRX_ALREADY_PROCESSED';
G_INSTALL_LOC_NOT_FOUND     VARCHAR2(200) := 'OKL_LLA_INSTALL_LOC_NOT_FOUND';
G_INST_SITE_USE_TOKEN       VARCHAR2(100) := 'SITE_USE_ID';
G_MODEL_LINE_ITEM_NOT_FOUND VARCHAR2(200) := 'OKL_LLA_MDL_LN_ITEM_NOT_FOUND';
G_MODEL_ITEM_NOT_TRACKABLE  VARCHAR2(200) := 'OKL_LLA_ITEM_NOT_TRACKABLE';
G_ITEM_NAME_TOKEN           VARCHAR2(200) := 'ITEM_NAME';
G_INV_ITEM_NOT_FOUND        VARCHAR2(200) := 'OKL_LLA_INV_ITEM_NOT_FOUND';
G_INV_ITEM_ID_TOKEN         VARCHAR2(200) := 'INV_ITEM_ID';
G_INV_ORG_ID_TOKEN          VARCHAR2(200) := 'INV_ORG_ID';
G_BULK_BATCH_SIZE CONSTANT   NUMBER := 10000;

PROCEDURE qc is
begin
  null;
end qc;

PROCEDURE api_copy is
begin
   null;
end api_copy;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
FUNCTION get_cimv_rec (p_cle_id                       IN NUMBER,
         x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cimv_rec_type IS
CURSOR okc_cimv_csr (p_cle_id  IN NUMBER) IS
       SELECT
            cim.ID,
            cim.OBJECT_VERSION_NUMBER,
            cim.CLE_ID,
            cim.CHR_ID,
            cim.CLE_ID_FOR,
            cim.DNZ_CHR_ID,
            cim.OBJECT1_ID1,
            cim.OBJECT1_ID2,
            cim.JTOT_OBJECT1_CODE,
            cim.UOM_CODE,
            cim.EXCEPTION_YN,
            cim.NUMBER_OF_ITEMS,
            cim.UPG_ORIG_SYSTEM_REF,
            cim.UPG_ORIG_SYSTEM_REF_ID,
            cim.PRICED_ITEM_YN,
            cim.CREATED_BY,
            cim.CREATION_DATE,
            cim.LAST_UPDATED_BY,
            cim.LAST_UPDATE_DATE,
            cim.LAST_UPDATE_LOGIN
      FROM  Okc_K_Items_V cim
      where cle_id = p_cle_id;

      l_cimv_rec     cimv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cimv_csr (p_cle_id);
    FETCH okc_cimv_csr INTO
              l_cimv_rec.ID,
              l_cimv_rec.OBJECT_VERSION_NUMBER,
              l_cimv_rec.CLE_ID,
              l_cimv_rec.CHR_ID,
              l_cimv_rec.CLE_ID_FOR,
              l_cimv_rec.DNZ_CHR_ID,
              l_cimv_rec.OBJECT1_ID1,
              l_cimv_rec.OBJECT1_ID2,
              l_cimv_rec.JTOT_OBJECT1_CODE,
              l_cimv_rec.UOM_CODE,
              l_cimv_rec.EXCEPTION_YN,
              l_cimv_rec.NUMBER_OF_ITEMS,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_cimv_rec.PRICED_ITEM_YN,
              l_cimv_rec.CREATED_BY,
              l_cimv_rec.CREATION_DATE,
              l_cimv_rec.LAST_UPDATED_BY,
              l_cimv_rec.LAST_UPDATE_DATE,
              l_cimv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cimv_csr%NOTFOUND;
    CLOSE okc_cimv_csr;
    RETURN(l_cimv_rec);
  END get_cimv_rec;
--------------------------------------------------------------------------------
--Function get_iipv_rec for getting the ib internal transaction record for the line
--------------------------------------------------------------------------------
FUNCTION get_iipv_rec (
    p_kle_id                       IN  NUMBER,
    p_trx_type                     IN  VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN iipv_rec_type  IS
    CURSOR okl_iipv_csr (p_kle_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
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
    FROM OKL_TXL_ITM_INSTS iti
    WHERE iti.kle_id  = p_kle_id
    and   iti.tal_type = p_trx_type
    and   exists (select '1' from  OKL_TRX_ASSETS
                   where  OKL_TRX_ASSETS.TAS_TYPE = p_trx_type
                   and    OKL_TRX_ASSETS.TSU_CODE = G_TSU_CODE_ENTERED
                   and    OKL_TRX_ASSETS.ID       = iti.tas_id);

    l_iipv_rec                     iipv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_iipv_csr (p_kle_id);
    FETCH okl_iipv_csr  INTO
             l_iipv_rec.ID,
              l_iipv_rec.OBJECT_VERSION_NUMBER,
              l_iipv_rec.TAS_ID,
              l_iipv_rec.TAL_ID,
              l_iipv_rec.KLE_ID,
              l_iipv_rec.TAL_TYPE,
              l_iipv_rec.LINE_NUMBER,
              l_iipv_rec.INSTANCE_NUMBER_IB,
              l_iipv_rec.OBJECT_ID1_NEW,
              l_iipv_rec.OBJECT_ID2_NEW,
              l_iipv_rec.JTOT_OBJECT_CODE_NEW,
              l_iipv_rec.OBJECT_ID1_OLD,
              l_iipv_rec.OBJECT_ID2_OLD,
              l_iipv_rec.JTOT_OBJECT_CODE_OLD,
              l_iipv_rec.INVENTORY_ORG_ID,
              l_iipv_rec.SERIAL_NUMBER,
              l_iipv_rec.MFG_SERIAL_NUMBER_YN,
              l_iipv_rec.INVENTORY_ITEM_ID,
              l_iipv_rec.INV_MASTER_ORG_ID,
              l_iipv_rec.ATTRIBUTE_CATEGORY,
              l_iipv_rec.ATTRIBUTE1,
              l_iipv_rec.ATTRIBUTE2,
              l_iipv_rec.ATTRIBUTE3,
              l_iipv_rec.ATTRIBUTE4,
              l_iipv_rec.ATTRIBUTE5,
              l_iipv_rec.ATTRIBUTE6,
              l_iipv_rec.ATTRIBUTE7,
              l_iipv_rec.ATTRIBUTE8,
              l_iipv_rec.ATTRIBUTE9,
              l_iipv_rec.ATTRIBUTE10,
              l_iipv_rec.ATTRIBUTE11,
              l_iipv_rec.ATTRIBUTE12,
              l_iipv_rec.ATTRIBUTE13,
              l_iipv_rec.ATTRIBUTE14,
              l_iipv_rec.ATTRIBUTE15,
              l_iipv_rec.CREATED_BY,
              l_iipv_rec.CREATION_DATE,
              l_iipv_rec.LAST_UPDATED_BY,
              l_iipv_rec.LAST_UPDATE_DATE,
              l_iipv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_iipv_csr%NOTFOUND;
    CLOSE okl_iipv_csr;
    RETURN(l_iipv_rec);
  END get_iipv_rec;
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : update_trx_status
  --Purpose               : Update transaction status - used internally
  --Modification History  :
  --20-Feb-2001    avsingh   Created
------------------------------------------------------------------------------
  PROCEDURE update_trx_status(p_api_version       IN  NUMBER,
                              p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                          x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2,
                              p_tas_id            IN  NUMBER,
                              p_tsu_code          IN  VARCHAR2) IS
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'update_trx_status';
  l_api_version	      CONSTANT NUMBER	:= 1.0;

  l_thpv_rec          OKL_TRX_ASSETS_PUB.thpv_rec_type;
  l_thpv_rec_out      OKL_TRX_ASSETS_PUB.thpv_rec_type;
  --cursor to check existing tsu code
  CURSOR tsu_code_csr (p_tas_id IN NUMBER) is
  SELECT tsu_code
  FROM   OKL_TRX_ASSETS
  WHERE  id = p_tas_id;

  l_tsu_code OKL_TRX_ASSETS.TSU_CODE%TYPE;
BEGIN
        --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --check if tsu code has already been updated to processed
     OPEN tsu_code_csr(p_tas_id => p_tas_id);
          FETCH tsu_code_csr into l_tsu_code;
          If tsu_code_csr%NOTFOUND Then
             --internal error unable to find trransaction record while trying to update status
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                 p_msg_name     => G_STS_UPDATE_TRX_MISSING,
				                 p_token1       => G_TAS_ID_TOKEN,
				                 p_token1_value => p_tas_id
				                );
             Raise OKL_API.G_EXCEPTION_ERROR;
          Else
             If l_tsu_code = p_tsu_code Then
                --transaction already processed by another user
                OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                    p_msg_name     => G_TRX_ALREADY_PROCESSED
				                   );
                 Raise OKL_API.G_EXCEPTION_ERROR;
             Else
                 l_thpv_rec.id := p_tas_id;
                 l_thpv_rec.tsu_code := p_tsu_code;
                 OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                                    p_api_version    => p_api_version,
                                    p_init_msg_list  => p_init_msg_list,
                                    x_return_status  => x_return_status,
                                    x_msg_count      => x_msg_count,
                                    x_msg_data       => x_msg_data,
                                    p_thpv_rec       => l_thpv_rec,
                                    x_thpv_rec       => l_thpv_rec_out);
                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             End If;
          End If;
        CLOSE tsu_code_csr;
            --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END update_trx_status;
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_party_rec
  --Purpose               : Gets Party records for IB interface
  --Modification History  :
  --15-Jun-2001    avsingh   Created
  --Notes : Takes chr_id as input and tries to get the party role
  --        for that contract for party role = 'LESSEE'
  --        Assuming that LESSEE will be the owner of the IB instance
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_party_rec
	(p_api_version                  IN  NUMBER,
	 p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chrv_id                      IN  NUMBER,
     x_party_tbl                    OUT NOCOPY party_tbl_type) is

     l_party_tab         OKL_JTOT_EXTRACT.party_tab_type;
     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_PARTY_REC';
     l_api_version	     CONSTANT NUMBER	:= 1.0;

     l_index         number;
     l_party_id      number;

begin
    --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                               p_init_msg_list,
                                                   '_PVT',
                                         	       x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
/*
    --get Party
    OKL_JTOT_EXTRACT.Get_Party(p_api_version     =>  p_api_version,
                               p_init_msg_list   =>  p_init_msg_list,
                               x_return_status   =>  x_return_status,
                               x_msg_count       =>  x_msg_count,
                               x_msg_data        =>  x_msg_data,
                               p_chr_id          =>  p_chrv_id,
                               p_cle_id          =>  null,
                               p_role_code       =>  G_ITM_INST_PARTY,
                               p_intent          =>  G_CONTRACT_INTENT,
                               x_party_tab       =>  l_party_tab);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
 		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
 		    RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    for l_index in 1..l_party_tab.LAST
    Loop
        x_party_tbl(l_index).party_id := l_party_tab(l_index).id1;
        x_party_tbl(l_index).party_source_table := G_PARTY_SRC_TABLE;
        x_party_tbl(l_index).relationship_type_code := G_PARTY_RELATIONSHIP;
        x_party_tbl(l_index).contact_flag := 'N';
        --dbms_output.put_line('party_id' || to_char(l_index)||'-'||to_char(x_party_tbl(l_index).party_id));
    End Loop;

    If (l_index = 0) Then
        --no owner party record found
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				            p_msg_name     => G_PARTY_NOT_FOUND,
				            p_token1       => G_ROLE_CODE_TOKEN,
				            p_token1_value => G_ITM_INST_PARTY
				         );
        Raise OKL_API.G_EXCEPTION_ERROR;
    End If;
*/
    Begin
	 SELECT P.PARTY_ID
	 INTO   l_party_id
	 FROM   HZ_PARTIES P, OKC_K_PARTY_ROLES_B OKPRV
	 WHERE  OKPRV.chr_id = p_chrv_id
 	 AND    OKPRV.rle_code = 'LESSEE'
	 AND    OKPRV.jtot_object1_code = 'OKX_PARTY'
	 AND    p.PARTY_ID  = OKPRV.object1_id1
	 AND    p.party_type in ('PERSON', 'ORGANIZATION');

    Exception
    When Others then
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				            p_msg_name     => G_PARTY_NOT_FOUND,
				            p_token1       => G_ROLE_CODE_TOKEN,
				            p_token1_value => G_ITM_INST_PARTY
				         );
           Raise OKL_API.G_EXCEPTION_ERROR;
    End;

    x_party_tbl(1).party_id := l_party_id;
    x_party_tbl(1).party_source_table := G_PARTY_SRC_TABLE;
    x_party_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
    x_party_tbl(1).contact_flag := 'N';

    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  end get_party_rec;
------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_trx_rec
  --Purpose               : Gets source transaction record for IB interface
  --Modification History  :
  --15-Jun-2001    ashish.singh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
  PROCEDURE get_trx_rec
    (p_api_version                  IN  NUMBER,
	 p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status                OUT NOCOPY VARCHAR2,
	 x_msg_count                    OUT NOCOPY NUMBER,
	 x_msg_data                     OUT NOCOPY VARCHAR2,
     p_cle_id                       IN  NUMBER,
     p_transaction_type             IN  VARCHAR2,
     x_trx_rec                      OUT NOCOPY trx_rec_type) is

     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_name          CONSTANT VARCHAR2(30) := 'GET_TRX_REC';
     l_api_version	     CONSTANT NUMBER	:= 1.0;

--Following cursor assumes that a transaction type called
--'OKL_BOOK'  will be seeded in IB
     Cursor okl_trx_type_csr(p_transaction_type IN VARCHAR2)is
            select transaction_type_id
            from   CSI_TXN_TYPES
            where  source_transaction_type = p_transaction_type;
     l_trx_type_id NUMBER;
 Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     open okl_trx_type_csr(p_transaction_type);
        Fetch okl_trx_type_csr
        into  l_trx_type_id;
        If okl_trx_type_csr%NotFound Then
           --OKL LINE ACTIVATION not seeded as a source transaction in IB
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_IB_TXN_TYPE_NOT_FOUND,
				               p_token1       => G_TXN_TYPE_TOKEN,
				               p_token1_value => p_transaction_type
				            );
           Raise OKL_API.G_EXCEPTION_ERROR;
        End If;
     close okl_trx_type_csr;
     --dbms_output.put_line('Found trx type id '||to_char(l_trx_type_id));
     --Assign transaction Type id to seeded value in cs_lookups
     x_trx_rec.transaction_type_id := l_trx_type_id;
     --Assign Source Line Ref id to contract line id of IB instance line
     x_trx_rec.source_line_ref_id := p_cle_id;
     x_trx_rec.transaction_date := sysdate;
     --confirm whether this has to be sysdate or creation date on line
     x_trx_rec.source_transaction_date := sysdate;
    Exception
    When OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_trx_rec;
--------------------------------------------------------------------------------
--Start of comments
--
--API Name : initialize_instance_rec
--Purpose  : Private procedure to initialize instance_rec to default values
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Initialize_instance_rec(x_instance_rec OUT NOCOPY inst_rec_type) IS
Begin
         x_instance_rec.INSTANCE_ID                :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTANCE_NUMBER            :=  FND_API.G_MISS_CHAR;
         x_instance_rec.EXTERNAL_REFERENCE         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.INVENTORY_ITEM_ID          :=  FND_API.G_MISS_NUM;
         x_instance_rec.VLD_ORGANIZATION_ID        :=  FND_API.G_MISS_NUM;
         x_instance_rec.INVENTORY_REVISION         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.INV_MASTER_ORGANIZATION_ID :=  FND_API.G_MISS_NUM;
         x_instance_rec.SERIAL_NUMBER              :=  FND_API.G_MISS_CHAR;
         x_instance_rec.MFG_SERIAL_NUMBER_FLAG     :=  FND_API.G_MISS_CHAR;
         x_instance_rec.LOT_NUMBER                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.QUANTITY                   :=  FND_API.G_MISS_NUM;
         x_instance_rec.UNIT_OF_MEASURE            :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ACCOUNTING_CLASS_CODE      :=  FND_API.G_MISS_CHAR;
         x_instance_rec.INSTANCE_CONDITION_ID      :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTANCE_STATUS_ID         :=  FND_API.G_MISS_NUM;
         x_instance_rec.CUSTOMER_VIEW_FLAG         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.MERCHANT_VIEW_FLAG         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.SELLABLE_FLAG              :=  FND_API.G_MISS_CHAR;
         x_instance_rec.SYSTEM_ID                  :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTANCE_TYPE_CODE         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ACTIVE_START_DATE          :=  FND_API.G_MISS_DATE;
         x_instance_rec.ACTIVE_END_DATE            :=  FND_API.G_MISS_DATE;
         x_instance_rec.LOCATION_TYPE_CODE         :=  FND_API.G_MISS_CHAR;
         x_instance_rec.LOCATION_ID                :=  FND_API.G_MISS_NUM;
         x_instance_rec.INV_ORGANIZATION_ID        :=  FND_API.G_MISS_NUM;
         x_instance_rec.INV_SUBINVENTORY_NAME      :=  FND_API.G_MISS_CHAR;
         x_instance_rec.INV_LOCATOR_ID             :=  FND_API.G_MISS_NUM;
         x_instance_rec.PA_PROJECT_ID              :=  FND_API.G_MISS_NUM;
         x_instance_rec.PA_PROJECT_TASK_ID         :=  FND_API.G_MISS_NUM;
         x_instance_rec.IN_TRANSIT_ORDER_LINE_ID   :=  FND_API.G_MISS_NUM;
         x_instance_rec.WIP_JOB_ID                 :=  FND_API.G_MISS_NUM;
         x_instance_rec.PO_ORDER_LINE_ID           :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_OE_ORDER_LINE_ID      :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_OE_RMA_LINE_ID        :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_PO_PO_LINE_ID         :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_OE_PO_NUMBER          :=  FND_API.G_MISS_CHAR;
         x_instance_rec.LAST_WIP_JOB_ID            :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_PA_PROJECT_ID         :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_PA_TASK_ID            :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_OE_AGREEMENT_ID       :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTALL_DATE               :=  FND_API.G_MISS_DATE;
         x_instance_rec.MANUALLY_CREATED_FLAG      :=  FND_API.G_MISS_CHAR;
         x_instance_rec.RETURN_BY_DATE             :=  FND_API.G_MISS_DATE;
         x_instance_rec.ACTUAL_RETURN_DATE         :=  FND_API.G_MISS_DATE;
         x_instance_rec.CREATION_COMPLETE_FLAG     :=  FND_API.G_MISS_CHAR;
         x_instance_rec.COMPLETENESS_FLAG          :=  FND_API.G_MISS_CHAR;
         x_instance_rec.VERSION_LABEL              :=  FND_API.G_MISS_CHAR;
         x_instance_rec.VERSION_LABEL_DESCRIPTION  :=  FND_API.G_MISS_CHAR;
         x_instance_rec.CONTEXT                    :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE1                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE2                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE3                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE4                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE5                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE6                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE7                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE8                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE9                 :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE10                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE11                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE12                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE13                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE14                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.ATTRIBUTE15                :=  FND_API.G_MISS_CHAR;
         x_instance_rec.OBJECT_VERSION_NUMBER      :=  FND_API.G_MISS_NUM;
         x_instance_rec.LAST_TXN_LINE_DETAIL_ID    :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTALL_LOCATION_TYPE_CODE :=  FND_API.G_MISS_CHAR;
         x_instance_rec.INSTALL_LOCATION_ID        :=  FND_API.G_MISS_NUM;
         x_instance_rec.INSTANCE_USAGE_CODE        :=  FND_API.G_MISS_CHAR;
         x_instance_rec.CHECK_FOR_INSTANCE_EXPIRY  :=  FND_API.G_TRUE;
End Initialize_instance_rec;
--------------------------------------------------------------------------------
--Start of comments
--
--API Name : initialize_txn_rec
--Purpose  : Private procedure to initialize transaction_rec to default values
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Initialize_txn_rec(x_txn_rec OUT NOCOPY trx_rec_type) IS
BEGIN
       x_txn_rec.TRANSACTION_ID                  := FND_API.G_MISS_NUM;
       x_txn_rec.TRANSACTION_DATE                := FND_API.G_MISS_DATE;
       x_txn_rec.SOURCE_TRANSACTION_DATE         := FND_API.G_MISS_DATE;
       x_txn_rec.TRANSACTION_TYPE_ID             := FND_API.G_MISS_NUM;
       x_txn_rec.TXN_SUB_TYPE_ID                 := FND_API.G_MISS_NUM;
       x_txn_rec.SOURCE_GROUP_REF_ID             := FND_API.G_MISS_NUM;
       x_txn_rec.SOURCE_GROUP_REF                := NULL;
       x_txn_rec.SOURCE_HEADER_REF_ID            := FND_API.G_MISS_NUM;
       x_txn_rec.SOURCE_HEADER_REF               := NULL;
       x_txn_rec.SOURCE_LINE_REF_ID              := FND_API.G_MISS_NUM;
       x_txn_rec.SOURCE_LINE_REF                 := NULL;
       x_txn_rec.SOURCE_DIST_REF_ID1             := FND_API.G_MISS_NUM;
       x_txn_rec.SOURCE_DIST_REF_ID2             := FND_API.G_MISS_NUM;
       x_txn_rec.INV_MATERIAL_TRANSACTION_ID     := FND_API.G_MISS_NUM;
       x_txn_rec.TRANSACTION_QUANTITY            := FND_API.G_MISS_NUM;
       x_txn_rec.TRANSACTION_UOM_CODE            := FND_API.G_MISS_CHAR;
       x_txn_rec.TRANSACTED_BY                   := FND_API.G_MISS_NUM;
       x_txn_rec.TRANSACTION_STATUS_CODE         := FND_API.G_MISS_CHAR;
       x_txn_rec.TRANSACTION_ACTION_CODE         := FND_API.G_MISS_CHAR;
       x_txn_rec.MESSAGE_ID                      := FND_API.G_MISS_NUM;
       x_txn_rec.CONTEXT                         := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE1                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE2                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE3                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE4                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE5                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE6                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE7                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE8                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE9                      := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE10                     := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE11                     := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE12                     := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE13                     := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE14                     := FND_API.G_MISS_CHAR;
       x_txn_rec.ATTRIBUTE15                     := FND_API.G_MISS_CHAR;
       x_txn_rec.OBJECT_VERSION_NUMBER           := FND_API.G_MISS_NUM;
       x_txn_rec.SPLIT_REASON_CODE               := FND_API.G_MISS_CHAR;
END Initialize_txn_rec;
--------------------------------------------------------------------------------
--Start of comments
--
--API Name : initialize_Account_tbl
--Purpose  : Private procedure to initialize party_account table to defaultvalues
--End of comments
--------------------------------------------------------------------------------
PROCEDURE Initialize_Account_Tbl(x_account_tbl OUT NOCOPY party_account_tbl_type) IS
i Number;
BEGIN
  If nvl(x_account_tbl.LAST,0) > 0 Then
     FOR i in 1..x_account_tbl.LAST LOOP
     x_account_tbl(i).ip_account_id             :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).parent_tbl_index          :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).instance_party_id         :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).party_account_id          :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).relationship_type_code    :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).bill_to_address           :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).ship_to_address           :=  FND_API.G_MISS_NUM;
     x_account_tbl(i).active_start_date         :=  FND_API.G_MISS_DATE;
     x_account_tbl(i).active_end_date           :=  FND_API.G_MISS_DATE;
     x_account_tbl(i).context                   :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute1                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute2                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute3                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute4                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute5                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute6                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute7                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute8                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute9                :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute10               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute11               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute12               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute13               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute14               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).attribute15               :=  FND_API.G_MISS_CHAR;
     x_account_tbl(i).object_version_number     :=  FND_API.G_MISS_NUM ;
     x_account_tbl(i).call_contracts            :=  FND_API.G_TRUE;
     x_account_tbl(i).vld_organization_id       :=  FND_API.G_MISS_NUM;
     END LOOP;
  End If;
END Initialize_account_tbl;
--------------------------------------------------------------------------------
--Start of comments
--
--API Name : initialize_party_tbl
--Purpose  : Private procedure to initialize party table to defaultvalues
--End of comments
--------------------------------------------------------------------------------
PROCEDURE initialize_party_tbl(p_in  IN  party_tbl_type,
                               x_out OUT NOCOPY party_tbl_type) IS
i    NUMBER;
BEGIN
     If nvl(p_in.LAST,0) > 0 Then
     FOR i in 1..p_in.LAST LOOP
         x_out(i).instance_party_id                :=  FND_API.G_MISS_NUM;
         x_out(i).instance_id                      :=  FND_API.G_MISS_NUM;
         x_out(i).party_source_table               :=  p_in(i).party_source_table;
         x_out(i).party_id                         :=  p_in(i).party_id;
         x_out(i).relationship_type_code           :=  p_in(i).relationship_type_code;
         x_out(i).contact_flag                     :=  p_in(i).contact_flag;
         x_out(i).contact_ip_id                    :=  FND_API.G_MISS_NUM;
         x_out(i).active_start_date                :=  FND_API.G_MISS_DATE;
         x_out(i).active_end_date                  :=  FND_API.G_MISS_DATE;
         x_out(i).context                          :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute1                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute2                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute3                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute4                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute5                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute6                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute7                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute8                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute9                       :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute10                      :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute11                      :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute12                      :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute13                      :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute14                      :=  FND_API.G_MISS_CHAR;
         x_out(i).attribute15                      :=  FND_API.G_MISS_CHAR;
         x_out(i).object_version_number            :=  FND_API.G_MISS_NUM;
         x_out(i).primary_flag                     :=  FND_API.G_MISS_CHAR;
         x_out(i).preferred_flag                   :=  FND_API.G_MISS_CHAR;
    END LOOP;
    End If;
END Initialize_Party_tbl;
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : Process_IB_Line_1
  --Purpose               : Local API called from Activate_IB_Instance API
  --                        Does processing contract header level processing
  --                        validations , which are pre-req for calling IB
  --                        create item instance API.
  --                        Logic taken out of Activate_IB_Instance to
  --                        make modular
  --Modification History  :
  --01-May-2002    avsingh  Created
  --End of Comments
------------------------------------------------------------------------------
Procedure Process_IB_Line_1(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                    x_return_status       OUT NOCOPY VARCHAR2,
	                    x_msg_count           OUT NOCOPY NUMBER,
	                    x_msg_data            OUT NOCOPY VARCHAR2,
                            p_chrv_id             IN  Number,
                            p_inst_cle_id         IN  NUMBER,
                            p_ib_cle_id           IN  NUMBER,
                            x_party_tbl           OUT NOCOPY party_tbl_type,
                            x_party_account       OUT NOCOPY NUMBER,
                            x_inv_mstr_org_id     OUT NOCOPY NUMBER,
                            x_model_line_qty      OUT NOCOPY NUMBER,
                            --bug#2845959
                            x_primary_uom_code    OUT NOCOPY VARCHAR2,
                            --bug# 3222804
                            x_inv_org_id          OUT NOCOPY NUMBER
                            ) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_IB_LINE_1';
  l_api_version	     CONSTANT NUMBER	:= 1.0;

  l_party_tbl                    party_tbl_type;

  --cursor to fetch ib master org id
  CURSOR mstr_org_csr (p_chr_id IN NUMBER) is
  SELECT MP.master_organization_id
  FROM   MTL_PARAMETERS   MP,
         OKC_K_HEADERS_B  CHR
  WHERE  MP.organization_id = CHR.inv_organization_id
  AND    CHR.id = p_chr_id;

  l_inv_mstr_org_id             NUMBER;

  l_inst_cle_id                 NUMBER;

  CURSOR get_qty_csr (p_inst_line_id IN NUMBER) is
  SELECT cim.number_of_items,
         cim.object1_id1,
         cim.object1_id2
  FROM   OKC_K_ITEMS        CIM,
         OKC_K_LINES_B      MDL,
         OKC_LINE_STYLES_B MDL_LSE,
         OKC_K_LINES_B      INST
  WHERE  CIM.CLE_ID       = MDL.ID
  AND    MDL.CLE_ID       = INST.CLE_ID
  AND    MDL.LSE_ID       = MDL_LSE.ID
  AND    MDL_LSE.LTY_CODE = G_MODEL_LINE_LTY_CODE
  AND    INST.ID          = p_inst_line_id;

  l_model_line_qty   NUMBER;
  l_mdl_line_inv_item_id      Varchar2(40);
  l_mdl_line_inv_org_id       Varchar2(200);

   --cursor to check trackable flag and if inv item on model line is valid
   CURSOR chk_track_flag_csr(p_inv_item_id IN NUMBER,
                             p_inv_org_id  IN NUMBER) IS
   SELECT  nvl(comms_nl_trackable_flag,'N'),
           segment1,
           description,
           --Bug#2845959
           primary_uom_code
   FROM    MTL_SYSTEM_ITEMS
   WHERE   inventory_item_id = p_inv_item_id
   AND     organization_id = p_inv_org_id;

  l_track_flag                  VARCHAR2(1);
  l_item_name                   MTL_SYSTEM_ITEMS.SEGMENT1%TYPE;
  l_item_description            MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE;
  --Bug#2845959
  l_primary_uom_code            MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE;

  /*-Bug# 3124577 : 11.5.10:Rule Migration----------------------------------------------
  --cursor to fetch customer account
  CURSOR party_account_csr(p_chrv_id IN NUMBER) is
  SELECT  to_number(rulv.object1_id1)
  FROM    OKC_RULES_V rulv
  WHERE   rulv.rule_information_category = G_CUST_ACCT_RULE
  AND     rulv.dnz_chr_id = p_chrv_id
  AND     exists (select '1'
                  from    OKC_RULE_GROUPS_V rgpv
                  where   rgpv.chr_id = p_chrv_id
                  and     rgpv.rgd_code = G_CUST_ACCT_RULE_GROUP
                  and     rgpv.id       = rulv.rgp_id);

  l_party_account              NUMBER;
  ------------------------------------11.5.10:Rule Migration----*/
  CURSOR party_account_csr(p_chrv_id IN NUMBER) is
  SELECT chrb.cust_acct_id
  FROM   OKC_K_HEADERS_B chrb
  WHERE  chrb.id = p_chrv_id;

  l_party_account            NUMBER;


Begin
    --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_inst_cle_id := p_inst_cle_id;
    --initialize party tbl
    get_party_rec(p_api_version      => p_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_chrv_id          => p_chrv_id,
                  x_party_tbl        => l_party_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --get inventory master org id
    l_inv_mstr_org_id := null;
    OPEN  mstr_org_csr (p_chr_id => p_chrv_id);
        FETCH mstr_org_csr into
                           l_inv_mstr_org_id;
        IF mstr_org_csr%NOTFOUND Then
            --raise error for unable to find inv mstr org
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_INV_MSTR_ORG_NOT_FOUND,
                                p_token1       =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value =>  to_char(p_chrv_id)
                                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
                --l_inv_mstr_org_id := 204;
        ELSE
            Null;
        END IF;
    CLOSE mstr_org_csr;

    --get model line quantity
    l_model_line_qty := 0;
    OPEN get_qty_csr (p_inst_line_id => l_inst_cle_id );
        FETCH get_qty_csr into
                          l_model_line_qty,
                          l_mdl_line_inv_item_id,
                          l_mdl_line_inv_org_id;
        IF get_qty_csr%NOTFOUND Then
            l_model_line_qty := 1;
        ELSE
            Null;
        END IF;
    CLOSE get_qty_csr;

    --check for trackable flag for inventory item
    --This is an IB prereq.
    l_track_flag := 'N';
    l_item_name  := Null;
    If l_mdl_line_inv_item_id is not null and l_mdl_line_inv_org_id is not null Then
        Open chk_track_flag_csr(p_inv_item_id => to_number(l_mdl_line_inv_item_id),
                                p_inv_org_id  => to_number(l_mdl_line_inv_org_id));
            Fetch chk_track_flag_csr into l_track_flag,
                                          l_item_name,
                                          l_item_description,
                                          --bug#2845959
                                          l_primary_uom_code;
            If chk_track_flag_csr%NOTFOUND Then
               --raise error for trackable flag is 'N'
               OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                   p_msg_name     =>  G_INV_ITEM_NOT_FOUND,
                                   p_token1       =>  G_INV_ITEM_ID_TOKEN,
                                   p_token1_value =>  l_mdl_line_inv_item_id,
                                   p_token2       =>  G_INV_ORG_ID_TOKEN,
                                   p_token2_value =>  l_mdl_line_inv_org_id
                                   );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
        Close chk_track_flag_csr;
        If l_track_flag <> 'Y' Then
            --raise error for trackable flag is 'N'
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_MODEL_ITEM_NOT_TRACKABLE,
                                p_token1       =>  G_ITEM_NAME_TOKEN,
                                --p_token1_value =>  l_item_name
                                --Bug#2372065
                                p_token1_value =>  l_item_description
                                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Elsif l_track_flag = 'Y' Then
            --everything is fine here
            Null;
        End If;
    Elsif l_mdl_line_inv_item_id is null OR l_mdl_line_inv_org_id is null Then
        --raise error for trackable flag is 'N'
        OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                            p_msg_name     =>  G_MODEL_LINE_ITEM_NOT_FOUND
                            );
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    --get party accoutnt id
    l_party_account := null;
    OPEN party_account_csr(p_chrv_id => p_chrv_id);
        FETCH party_account_csr into
                                l_party_account;
        IF party_account_csr%NOTFOUND Then
            --raise error for unable to find inv mstr org
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_CUST_ACCOUNT_FOUND,
                                p_token1       =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value =>  to_char(p_chrv_id)
                                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            NULL;
        END IF;
    CLOSE party_account_csr;

     x_party_tbl       := l_party_tbl;
     x_party_account   := l_party_account;
     x_inv_mstr_org_id := l_inv_mstr_org_id;
     x_model_line_qty  := l_model_line_qty;
     --bug#2845959
     x_primary_uom_code := l_primary_uom_code;

     --bug#3222804
     x_inv_org_id := to_number(l_mdl_line_inv_org_id);

    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End Process_IB_Line_1;
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : Process_IB_Line_2
  --Purpose               : Local API called from Activate_IB_Instance API
  --                        Does processing for each ib instance line
  --                        and calls IB create_item_instance API
  --                        Logic taken out of Activate_IB_Instance to
  --                        make modular
  --Modification History  :
  --01-May-2002    avsingh  Created
  --End of Comments
------------------------------------------------------------------------------
Procedure Process_IB_Line_2(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                    x_return_status       OUT NOCOPY VARCHAR2,
	                    x_msg_count           OUT NOCOPY NUMBER,
	                    x_msg_data            OUT NOCOPY VARCHAR2,
                            p_chrv_id             IN  NUMBER,
                            p_inst_cle_id         IN  NUMBER,
                            p_ib_cle_id           IN  NUMBER,
                            p_party_tbl           IN  party_tbl_type,
                            p_party_account       IN NUMBER,
                            p_inv_mstr_org_id     IN NUMBER,
                            p_model_line_qty      IN NUMBER,
                            --bug# 2845959
                            p_uom_code            IN VARCHAR2,
                            p_trx_type            IN VARCHAR2,
                           --Bug# 3222804
                            p_inv_org_id          IN  NUMBER,
                            --Bug# 5207066
                            p_rbk_ib_cle_id       IN  NUMBER DEFAULT NULL,
                            x_cimv_rec            OUT NOCOPY cimv_rec_type) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_IB_LINE_2';
  l_api_version	     CONSTANT NUMBER	:= 1.0;

  l_no_data_found_cimv          BOOLEAN;
  l_no_data_found_iipv          BOOLEAN;
  l_cimv_rec                    cimv_rec_type;
  l_cimv_rec_out                cimv_rec_type;
  l_iipv_rec                    iipv_rec_type;
  l_ib_cle_id                   NUMBER;

  l_party_account               NUMBER;
  l_inv_mstr_org_id             NUMBER;
  l_model_line_qty              NUMBER;

  l_instance_rec                 inst_rec_type;
  l_ext_attrib_values_tbl        ext_attrib_tbl_type;
  l_party_tbl                    party_tbl_type;
  l_party_tbl_in                 party_tbl_type;
  l_account_tbl                  party_account_tbl_type;
  l_pricing_attrib_tbl           pricing_attribs_tbl_type;
  l_org_assignments_tbl          org_units_tbl_type;
  l_asset_assignment_tbl         instance_asset_tbl_type;
  l_txn_rec                      trx_rec_type;

   --cursor to fetch party location id
  CURSOR instance_loc_csr (p_site_use_id1 IN VARCHAR2,
                           p_site_use_id2 IN VARCHAR2) is
  SELECT location_id,
         party_site_id
  FROM   OKX_PARTY_SITE_USES_V
  WHERE  id1 = p_site_use_id1
  AND    id2 = p_site_use_id2;

  l_location_id                 NUMBER;
  l_party_site_id               NUMBER;

  --Bug# 3222804 :
  l_inv_org_id                  NUMBER;

Begin
    --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_ib_cle_id := p_ib_cle_id;
    l_party_account := p_party_account;
    l_inv_mstr_org_id := p_inv_mstr_org_id;
    l_model_line_qty  := p_model_line_qty;
    l_party_tbl := p_party_tbl;
    --Bug# 3222804 :
    l_inv_org_id   := p_inv_org_id;


    --initialize l_cimv_rec here
    l_cimv_rec := get_cimv_rec(l_ib_cle_id,l_no_data_found_cimv);
    If (l_cimv_rec.jtot_object1_code is not null) and (l_cimv_rec.object1_id1) is not null Then
        --ib instance is already plugged in (do nothing)
        x_cimv_rec := l_cimv_rec;
    Elsif (l_no_data_found_cimv) OR (l_cimv_rec.jtot_object1_code is null OR l_cimv_rec.object1_id1 is null) Then
        -- Call get_iipv_rec
        --Bug# 5207066
        l_iipv_rec := get_iipv_rec(p_kle_id => NVL(p_rbk_ib_cle_id,l_ib_cle_id), p_trx_type => p_trx_type, x_no_data_found => l_no_data_found_iipv);
        --dbms_output.put_line('after fetch iipv rec '||to_char(l_iipv_rec.id));
        If l_no_data_found_iipv Then
            --dbms_output.put_line('no ib creation transaction records ...!');
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                p_msg_name     => G_IB_TRX_REC_NOT_FOUND,
                                p_token1       => G_IB_LINE_ID_TOKEN,
                                p_token1_value => to_char(NVL(p_rbk_ib_cle_id,l_ib_cle_id))
				                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            --initialize instance rec
            --dbms_output.put_line('before initialize instance rec');
            Initialize_instance_rec(l_instance_rec);
            l_instance_rec.inventory_item_id          := l_iipv_rec.inventory_item_id;
            l_instance_rec.inv_master_organization_id := l_inv_mstr_org_id;
            --Bug# 3222804 :
            l_instance_rec.vld_organization_id        := p_inv_org_id;
            --do not require to give inv_org_id
            --l_instance_rec.inv_organization_id        := 204;
            --l_instance_rec.mfg_serial_number_flag     := l_iipv_rec.mfg_serial_number_yn;
            l_instance_rec.mfg_serial_number_flag     := G_MFG_SERIAL_NUMBER_FLAG;
            --l_instance_rec.location_id              := to_number(l_iipv_rec.object_id1_new);
            --get instance location id
            l_location_id   := null;
            l_party_site_id := null;
            OPEN instance_loc_csr (p_site_use_id1 => l_iipv_rec.object_id1_new,
                                   p_site_use_id2 => l_iipv_rec.object_id2_new);
                FETCH instance_loc_csr into
                                       l_location_id,
                                       l_party_site_id;
                --dbms_output.put_line('Location '||to_char(l_location_id));
                IF instance_loc_csr%NOTFOUND Then
                    --dbms_output.put_line('party site use records not found ...!');
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                        p_msg_name     => G_INSTALL_LOC_NOT_FOUND,
                                        p_token1       => G_INST_SITE_USE_TOKEN,
                                        p_token1_value => l_iipv_rec.object_id1_new
				                        );
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                ELSE
                    l_instance_rec.location_id := l_location_id;
                    l_instance_rec.INSTALL_LOCATION_ID :=  l_party_site_id;
                End If;
            CLOSE instance_loc_csr;

            --l_instance_rec.location_id                := 929;
            l_instance_rec.serial_number              := l_iipv_rec.serial_number;
            l_instance_rec.location_type_code         := G_LOC_TYPE_CODE;
            --l_instance_rec.active_start_date          := sysdate-30; --not mandatory
            --l_instance_rec.instance_type_code         := '10203'; --not mandatory
            If l_iipv_rec.serial_number is not null Then
                l_instance_rec.quantity                   := 1;
            Elsif l_iipv_rec.serial_number is null Then
                l_instance_rec.quantity :=l_model_line_qty;
            End If;
            --bug# 2845959:
            --l_instance_rec.unit_of_measure            := G_UOM_CODE;
            l_instance_rec.unit_of_measure            := p_uom_code;
            l_instance_rec.INSTALL_LOCATION_TYPE_CODE := G_INSTALL_LOC_TYPE_CODE;
            --l_instance_rec.INSTALL_LOCATION_ID :=  to_number(l_iipv_rec.object_id1_new);

            --get transaction line record
            --initialize txn rec
            --dbms_output.put_line('before initialize txn rec');
            initialize_txn_rec(l_txn_rec);
            --Call get_trx_rec
            get_trx_rec(p_api_version      => p_api_version,
                        p_init_msg_list    => p_init_msg_list,
                        x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_cle_id           => l_ib_cle_id,
                        p_transaction_type => G_IB_BKNG_TXN_TYPE,
                        x_trx_rec          => l_txn_rec);
             --dbms_output.put_line('after initialize txn rec '|| x_return_status);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --initialize other parameter records to default
             --dbms_output.put_line('before initialize account tbl '||to_char(l_party_tbl(1).party_id));
             initialize_account_tbl(l_account_tbl);
             l_account_tbl(1).instance_party_id := l_party_tbl(1).party_id;
             l_account_tbl(1).party_account_id  := l_party_account;
             l_account_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
             --l_account_tbl(1).active_start_date := sysdate;
             l_account_tbl(1).parent_tbl_index := 1;

             --initialize party tbl
             --dbms_output.put_line('before initialize party tbl');
             initialize_party_tbl(p_in  => l_party_tbl,
                                  x_out => l_party_tbl_in);

             --Following code taken care of in initializations :
             --l_party_tbl(1).instance_party_id := FND_API.G_MISS_NUM;
             --l_party_tbl(1).instance_id := FND_API.G_MISS_NUM;
             --
             --l_account_tbl(1).ip_account_id := FND_API.G_MISS_NUM;
             --
             --l_txn_rec.transaction_id := FND_API.G_MISS_NUM;

             --call create item instance
             --dbms_output.put_line('before calling create item instance');
             csi_item_instance_pub.create_item_instance(p_api_version           =>  p_api_version,
                                                        p_commit                =>  fnd_api.g_false,
                                                        p_init_msg_list         =>  p_init_msg_list,
                                                        p_instance_rec          =>  l_instance_rec,
                                                        p_validation_level      =>  fnd_api.g_valid_level_full,
                                                        p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                        p_party_tbl             =>  l_party_tbl_in,
                                                        p_account_tbl           =>  l_account_tbl,
                                                        p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                        p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                        p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                        p_txn_rec               =>  l_txn_rec,
                                                        x_return_status         =>  x_return_status,
                                                        x_msg_count             =>  x_msg_count,
                                                        x_msg_data              =>  x_msg_data);

             --dbms_output.put_line('status '||x_return_status);
             --dbms_output.put_line('instance_id '||to_char(l_instance_rec.instance_id));

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --update line source (okc_k_items)
             If l_no_data_found_cimv then
                l_cimv_rec.cle_id      := l_ib_cle_id;
                l_cimv_rec.dnz_chr_id  := p_chrv_id;
                l_cimv_rec.object1_id1 := l_instance_rec.instance_id;
                l_cimv_rec.object1_id2 := '#';
                l_cimv_rec.jtot_object1_code := G_IB_LINE_SRC_CODE;
                l_cimv_rec.exception_yn := 'N';

                okl_okc_migration_pvt.create_contract_item
                                         (p_api_version	    => p_api_version,
                                          p_init_msg_list	=> p_init_msg_list,
                                          x_return_status	=> x_return_status,
                                          x_msg_count	    => x_msg_count,
                                          x_msg_data	    => x_msg_data,
                                          p_cimv_rec	    => l_cimv_rec,
                                          x_cimv_rec	    => l_cimv_rec_out);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             Else
                l_cimv_rec.object1_id1 := l_instance_rec.instance_id;
                l_cimv_rec.object1_id2 := '#';
                l_cimv_rec.jtot_object1_code := G_IB_LINE_SRC_CODE;

                okl_okc_migration_pvt.update_contract_item
                                   (p_api_version	=> p_api_version,
                                    p_init_msg_list	=> p_init_msg_list,
                                    x_return_status	=> x_return_status,
                                    x_msg_count	    => x_msg_count,
                                    x_msg_data	    => x_msg_data,
                                    p_cimv_rec	    => l_cimv_rec,
                                    x_cimv_rec	    => l_cimv_rec_out);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                x_cimv_rec := l_cimv_rec_out;
             End If;
             -- gboomina Bug 5362977 - Start
             -- Only update transaction status if a new Asset is being added
             -- and the transaction being updated is on the original contract
             IF p_rbk_ib_cle_id IS NULL THEN
            -- gboomina Bug 5362977 - End
                --update transaction status
                update_trx_status(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
	                  x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_tas_id        => l_iipv_rec.tas_id,
                      p_tsu_code      => G_TSU_CODE_PROCESSED);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            -- gboomina Bug 5362977 - Start
	    END IF;
            -- gboomina Bug 5362977 - End
             End If;--get iipv rec
         End If;--cimv_rec
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End Process_IB_Line_2;
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : Process_IB_Line
  --Purpose               : Local API called from Activate_IB_Instance API
  --                        Does processing for each ib instance line
  --                        and calls IB create_item_instance API.
  --                        API created by merging Process_IB_Line1 and
  --                        Process_IB_Line2
  --Modification History  :
  --15-Mar-2004    rseela  Created
  --End of Comments
------------------------------------------------------------------------------

Procedure Process_IB_Line(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                    x_return_status       OUT NOCOPY VARCHAR2,
	                    x_msg_count           OUT NOCOPY NUMBER,
	                    x_msg_data            OUT NOCOPY VARCHAR2,
                            p_chrv_id             IN  NUMBER,
                            p_start_date          IN  DATE,
                            p_inst_cle_id         IN  NUMBER,
                            p_ib_cle_id           IN  NUMBER,
                            p_party_tbl           IN  party_tbl_type,
                            p_party_account       IN NUMBER,
                            p_inv_mstr_org_id     IN NUMBER,
                            p_model_line_qty      IN NUMBER,
                            --bug# 2845959
                            p_uom_code            IN VARCHAR2,
                            p_trx_type            IN VARCHAR2,
                           --Bug# 3222804
                            p_inv_org_id          IN  NUMBER,
                            x_cimv_rec            OUT NOCOPY cimv_rec_type) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'PROCESS_IB_LINE_2';
  l_api_version	     CONSTANT NUMBER	:= 1.0;

  l_no_data_found_cimv          BOOLEAN;
  l_no_data_found_iipv          BOOLEAN;
  l_cimv_rec                    cimv_rec_type;
  l_cimv_rec_out                cimv_rec_type;
  l_iipv_rec                    iipv_rec_type;
  l_ib_cle_id                   NUMBER;
  l_inst_cle_id                 NUMBER;

  l_party_account               NUMBER;
  l_inv_mstr_org_id             NUMBER;
  l_model_line_qty              NUMBER;
  l_mdl_line_inv_item_id      Varchar2(40);
  l_mdl_line_inv_org_id       Varchar2(200);


  l_instance_rec                 inst_rec_type;
  l_ext_attrib_values_tbl        ext_attrib_tbl_type;
  l_party_tbl                    party_tbl_type;
  l_party_tbl_in                 party_tbl_type;
  l_account_tbl                  party_account_tbl_type;
  l_pricing_attrib_tbl           pricing_attribs_tbl_type;
  l_org_assignments_tbl          org_units_tbl_type;
  l_asset_assignment_tbl         instance_asset_tbl_type;
  l_txn_rec                      trx_rec_type;

  l_track_flag                  VARCHAR2(1);
  l_item_name                   MTL_SYSTEM_ITEMS.SEGMENT1%TYPE;
  l_item_description            MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE;
  --Bug#2845959
  l_primary_uom_code            MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE;


  CURSOR get_qty_csr (p_inst_line_id IN NUMBER) is
  SELECT cim.number_of_items,
         cim.object1_id1,
         cim.object1_id2
  FROM   OKC_K_ITEMS        CIM,
         OKC_K_LINES_B      MDL,
         OKC_K_LINES_B      INST
  WHERE  CIM.CLE_ID       = MDL.ID
  AND    MDL.CLE_ID       = INST.CLE_ID
  AND    MDL.LSE_ID       = G_MODEL_LINE_LTY_ID
  AND    INST.ID          = p_inst_line_id;

   --cursor to check trackable flag and if inv item on model line is valid
   CURSOR chk_track_flag_csr(p_inv_item_id IN NUMBER,
                             p_inv_org_id  IN NUMBER) IS
   SELECT  nvl(comms_nl_trackable_flag,'N'),
           segment1,
           description,
           --Bug#2845959
           primary_uom_code
   FROM    MTL_SYSTEM_ITEMS
   WHERE   inventory_item_id = p_inv_item_id
   AND     organization_id = p_inv_org_id;

   --cursor to fetch party location id
  CURSOR instance_loc_csr (p_site_use_id1 IN VARCHAR2) is
  SELECT HPS.location_id,
         HPS.party_site_id
  FROM   HZ_PARTY_SITE_USES HPSU, HZ_PARTY_SITES HPS
  WHERE  HPS.party_site_id = HPSU.party_site_id
  AND    HPSU.party_site_use_id = p_site_use_id1;

  --rkuttiya added for IB Link User story 22-jan-2008 sprint 7
  -- verify existence of the serial number
  CURSOR c_serial_no_exists(p_serial_number   IN VARCHAR2,
                            p_inv_item_id     IN NUMBER,
                            p_inv_mstr_org_id IN NUMBER,
                            p_khr_start_date  IN DATE) IS
  SELECT INSTANCE_ID
  FROM CSI_ITEM_INSTANCES CSI
  WHERE SERIAL_NUMBER = p_serial_number
  AND INVENTORY_ITEM_ID = p_inv_item_id
  AND INV_MASTER_ORGANIZATION_ID = p_inv_mstr_org_id
  AND INSTANCE_STATUS_ID IN (SELECT INSTANCE_STATUS_ID
                                 FROM CSI_INSTANCE_STATUSES
                                 WHERE TERMINATED_FLAG = 'N')
  AND NVL(ACTIVE_END_DATE,(p_khr_start_date+1)) > p_khr_start_date
  AND ROWNUM = 1
  AND NOT EXISTS
  (SELECT CLE.DNZ_CHR_ID
   FROM   OKC_K_LINES_B CLE,
          OKC_LINE_STYLES_B CLS,
          OKC_K_ITEMS       CIM,
          OKX_INSTALL_ITEMS_V CIX,
          OKL_K_HEADERS KHR
   WHERE  CLE.LSE_ID = CLS.ID
   AND    CLE.DNZ_CHR_ID = KHR.ID
   AND    CLS.LTY_CODE = 'INST_ITEM'
   AND    CLE.ID = CIM.CLE_ID
   AND    CIM.OBJECT1_ID1 = CIX.ID1
   AND    CIM.OBJECT1_ID2 = CIX.ID2
   AND    CIM.JTOT_OBJECT1_CODE = 'OKX_IB_ITEM'
   AND    CIX.INSTANCE_ID = CSI.INSTANCE_ID);

  CURSOR c_check_usage(p_contract_id IN NUMBER) IS
  SELECT '!'
  FROM okc_k_headers_b CHR
  WHERE chr.id = p_contract_id
  AND EXISTS (SELECT '1'
              FROM okc_line_styles_b lse,
                   okc_k_lines_b     cle
              WHERE cle.sts_code = 'APPROVED'
              AND   lse.id = cle.lse_id
              AND   lse.lty_code = 'USAGE'
              AND   cle.dnz_chr_id = chr.id);


  l_usage_khr    VARCHAR2(1) DEFAULT '?';

  l_serial_number               VARCHAR2(30);
  l_inv_item_id                 NUMBER;
  l_instance_id                 NUMBER;

  l_location_id                 NUMBER;
  l_party_site_id               NUMBER;

  --Bug# 3222804 :
  l_inv_org_id                  NUMBER;

Begin
    --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_inst_cle_id := p_inst_cle_id;

    --get model line quantity
    l_model_line_qty := 0;
    OPEN get_qty_csr (p_inst_line_id => l_inst_cle_id );
        FETCH get_qty_csr into
                          l_model_line_qty,
                          l_mdl_line_inv_item_id,
                          l_mdl_line_inv_org_id;
        IF get_qty_csr%NOTFOUND Then
            l_model_line_qty := 1;
        ELSE
            Null;
        END IF;
    CLOSE get_qty_csr;

    --check for trackable flag for inventory item
    --This is an IB prereq.
    l_track_flag := 'N';
    l_item_name  := Null;
    If l_mdl_line_inv_item_id is not null and l_mdl_line_inv_org_id is not null Then
        Open chk_track_flag_csr(p_inv_item_id => to_number(l_mdl_line_inv_item_id),
                                p_inv_org_id  => to_number(l_mdl_line_inv_org_id));
            Fetch chk_track_flag_csr into l_track_flag,
                                          l_item_name,
                                          l_item_description,
                                          --bug#2845959
                                          l_primary_uom_code;
            If chk_track_flag_csr%NOTFOUND Then
               --raise error for trackable flag is 'N'
               OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                   p_msg_name     =>  G_INV_ITEM_NOT_FOUND,
                                   p_token1       =>  G_INV_ITEM_ID_TOKEN,
                                   p_token1_value =>  l_mdl_line_inv_item_id,
                                   p_token2       =>  G_INV_ORG_ID_TOKEN,
                                   p_token2_value =>  l_mdl_line_inv_org_id
                                   );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
        Close chk_track_flag_csr;
        If l_track_flag <> 'Y' Then
            --raise error for trackable flag is 'N'
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_MODEL_ITEM_NOT_TRACKABLE,
                                p_token1       =>  G_ITEM_NAME_TOKEN,
                                --p_token1_value =>  l_item_name
                                --Bug#2372065
                                p_token1_value =>  l_item_description
                                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Elsif l_track_flag = 'Y' Then
            --everything is fine here
            Null;
        End If;
    Elsif l_mdl_line_inv_item_id is null OR l_mdl_line_inv_org_id is null Then
        --raise error for trackable flag is 'N'
        OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                            p_msg_name     =>  G_MODEL_LINE_ITEM_NOT_FOUND
                            );
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_ib_cle_id := p_ib_cle_id;
    l_party_account := p_party_account;
    l_inv_mstr_org_id := p_inv_mstr_org_id;
    l_party_tbl := p_party_tbl;
    --Bug# 3222804 :
    l_inv_org_id := to_number(l_mdl_line_inv_org_id);


    --initialize l_cimv_rec here
    l_cimv_rec := get_cimv_rec(l_ib_cle_id,l_no_data_found_cimv);
    If (l_cimv_rec.jtot_object1_code is not null) and (l_cimv_rec.object1_id1) is not null Then
        --ib instance is already plugged in (do nothing)
        x_cimv_rec := l_cimv_rec;
    Elsif (l_no_data_found_cimv) OR (l_cimv_rec.jtot_object1_code is null OR l_cimv_rec.object1_id1 is null) Then
        -- Call get_iipv_rec
        l_iipv_rec := get_iipv_rec(p_kle_id => l_ib_cle_id, p_trx_type => p_trx_type, x_no_data_found => l_no_data_found_iipv);
        --dbms_output.put_line('after fetch iipv rec '||to_char(l_iipv_rec.id));
        If l_no_data_found_iipv Then
            --dbms_output.put_line('no ib creation transaction records ...!');
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                p_msg_name     => G_IB_TRX_REC_NOT_FOUND,
                                p_token1       => G_IB_LINE_ID_TOKEN,
                                p_token1_value => to_char(l_ib_cle_id)
				                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
          --rkuttiya added for IB Link user story 22-jan-08
          -- validate the existence of a serial number instance created by
          -- applications. If matching serial number inventory item combination
          -- exists, then link the contract to that IB item instance
          -- instead of creating  a new one
          -- This linking of existing IB instance is not currently opened for
          -- contracts with usage lines

-- check if there is usage line on the contract
          OPEN c_check_usage(p_chrv_id);
          FETCH c_check_usage INTO l_usage_khr;
          CLOSE c_check_usage;

    --     okl_debug_pub.logmessage('Usage check  '||l_usage_khr);
         IF l_usage_khr <> '!' THEN
            l_serial_number := l_iipv_rec.serial_number;
            l_inv_item_id   := l_iipv_rec.inventory_item_id;

            OPEN
c_serial_no_exists(l_serial_number,l_inv_item_id,p_inv_mstr_org_id,p_start_date);
            FETCH c_serial_no_exists INTO l_instance_id;
            CLOSE c_serial_no_exists;
         END IF;

        -- okl_debug_pub.logmessage('serial number '|| l_serial_number);
        -- okl_debug_pub.logmessage('inventory item id '||l_inv_item_id);
        -- okl_debug_pub.logmessage('instance id ' ||l_instance_id);

         --If IB instance already exists do not create a new instance else
         -- create
          IF l_instance_id IS NOT NULL THEN
            l_instance_rec.instance_id := l_instance_id;
           --okl_debug_pub.logmessage('linking IB instance');
          ELSIF (l_usage_khr = '!') OR (l_instance_id IS NULL) THEN
           --okl_debug_pub.logmessage('creating IB instance');

             --initialize instance rec
            --dbms_output.put_line('before initialize instance rec');
            Initialize_instance_rec(l_instance_rec);
            l_instance_rec.inventory_item_id          := l_iipv_rec.inventory_item_id;
            l_instance_rec.inv_master_organization_id := l_inv_mstr_org_id;
            --Bug# 3222804 :
            l_instance_rec.vld_organization_id        := l_inv_org_id;
            --do not require to give inv_org_id
            --l_instance_rec.inv_organization_id        := 204;
            --l_instance_rec.mfg_serial_number_flag     := l_iipv_rec.mfg_serial_number_yn;
            l_instance_rec.mfg_serial_number_flag     := G_MFG_SERIAL_NUMBER_FLAG;
            --l_instance_rec.location_id              := to_number(l_iipv_rec.object_id1_new);
            --get instance location id
            l_location_id   := null;
            l_party_site_id := null;
            OPEN instance_loc_csr (p_site_use_id1 => l_iipv_rec.object_id1_new);
                FETCH instance_loc_csr into
                                       l_location_id,
                                       l_party_site_id;
                --dbms_output.put_line('Location '||to_char(l_location_id));
                IF instance_loc_csr%NOTFOUND Then
                    --dbms_output.put_line('party site use records not found ...!');
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                        p_msg_name     => G_INSTALL_LOC_NOT_FOUND,
                                        p_token1       => G_INST_SITE_USE_TOKEN,
                                        p_token1_value => l_iipv_rec.object_id1_new
				                        );
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                ELSE
                    l_instance_rec.location_id := l_location_id;
                    l_instance_rec.INSTALL_LOCATION_ID :=  l_party_site_id;
                End If;
            CLOSE instance_loc_csr;

            --l_instance_rec.location_id                := 929;
            l_instance_rec.serial_number              := l_iipv_rec.serial_number;
            l_instance_rec.location_type_code         := G_LOC_TYPE_CODE;
            --l_instance_rec.active_start_date          := sysdate-30; --not mandatory
            --l_instance_rec.instance_type_code         := '10203'; --not mandatory
            If l_iipv_rec.serial_number is not null Then
                l_instance_rec.quantity                   := 1;
            Elsif l_iipv_rec.serial_number is null Then
                l_instance_rec.quantity :=l_model_line_qty;
            End If;
            --bug# 2845959:
            --l_instance_rec.unit_of_measure            := G_UOM_CODE;
            l_instance_rec.unit_of_measure            := l_primary_uom_code;
            l_instance_rec.INSTALL_LOCATION_TYPE_CODE := G_INSTALL_LOC_TYPE_CODE;
            --l_instance_rec.INSTALL_LOCATION_ID :=  to_number(l_iipv_rec.object_id1_new);

            --get transaction line record
            --initialize txn rec
            --dbms_output.put_line('before initialize txn rec');
            initialize_txn_rec(l_txn_rec);
            --Call get_trx_rec
            get_trx_rec(p_api_version      => p_api_version,
                        p_init_msg_list    => p_init_msg_list,
                        x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_cle_id           => l_ib_cle_id,
                        p_transaction_type => G_IB_BKNG_TXN_TYPE,
                        x_trx_rec          => l_txn_rec);
             --dbms_output.put_line('after initialize txn rec '|| x_return_status);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             --initialize other parameter records to default
             --dbms_output.put_line('before initialize account tbl '||to_char(l_party_tbl(1).party_id));
             initialize_account_tbl(l_account_tbl);
             l_account_tbl(1).instance_party_id := l_party_tbl(1).party_id;
             l_account_tbl(1).party_account_id  := l_party_account;
             l_account_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
             --l_account_tbl(1).active_start_date := sysdate;
             l_account_tbl(1).parent_tbl_index := 1;

             --initialize party tbl
             --dbms_output.put_line('before initialize party tbl');
             initialize_party_tbl(p_in  => l_party_tbl,
                                  x_out => l_party_tbl_in);

             --Following code taken care of in initializations :
             --l_party_tbl(1).instance_party_id := FND_API.G_MISS_NUM;
             --l_party_tbl(1).instance_id := FND_API.G_MISS_NUM;
             --
             --l_account_tbl(1).ip_account_id := FND_API.G_MISS_NUM;
             --
             --l_txn_rec.transaction_id := FND_API.G_MISS_NUM;

             --call create item instance
             --dbms_output.put_line('before calling create item instance');

             csi_item_instance_pub.create_item_instance(p_api_version           =>  p_api_version,
                                                        p_commit                =>  fnd_api.g_false,
                                                        p_init_msg_list         =>  p_init_msg_list,
                                                        p_instance_rec          =>  l_instance_rec,
                                                        p_validation_level      =>  fnd_api.g_valid_level_full,
                                                        p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
                                                        p_party_tbl             =>  l_party_tbl_in,
                                                        p_account_tbl           =>  l_account_tbl,
                                                        p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
                                                        p_org_assignments_tbl   =>  l_org_assignments_tbl,
                                                        p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
                                                        p_txn_rec               =>  l_txn_rec,
                                                        x_return_status         =>  x_return_status,
                                                        x_msg_count             =>  x_msg_count,
                                                        x_msg_data              =>  x_msg_data);

             --dbms_output.put_line('status '||x_return_status);
             --dbms_output.put_line('instance_id '||to_char(l_instance_rec.instance_id));

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF;--check for existing serial no instance

             --update line source (okc_k_items)
             If l_no_data_found_cimv then
                l_cimv_rec.cle_id      := l_ib_cle_id;
                l_cimv_rec.dnz_chr_id  := p_chrv_id;
                l_cimv_rec.object1_id1 := l_instance_rec.instance_id;
                l_cimv_rec.object1_id2 := '#';
                l_cimv_rec.jtot_object1_code := G_IB_LINE_SRC_CODE;
                l_cimv_rec.exception_yn := 'N';
                okl_okc_migration_pvt.create_contract_item
                                         (p_api_version	    => p_api_version,
                                          p_init_msg_list	=> p_init_msg_list,
                                          x_return_status	=> x_return_status,
                                          x_msg_count	    => x_msg_count,
                                          x_msg_data	    => x_msg_data,
                                          p_cimv_rec	    => l_cimv_rec,
                                          x_cimv_rec	    => l_cimv_rec_out);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             Else
                l_cimv_rec.object1_id1 := l_instance_rec.instance_id;
                l_cimv_rec.object1_id2 := '#';
                l_cimv_rec.jtot_object1_code := G_IB_LINE_SRC_CODE;
                okl_okc_migration_pvt.update_contract_item
                                   (p_api_version	=> p_api_version,
                                    p_init_msg_list	=> p_init_msg_list,
                                    x_return_status	=> x_return_status,
                                    x_msg_count	    => x_msg_count,
                                    x_msg_data	    => x_msg_data,
                                    p_cimv_rec	    => l_cimv_rec,
                                    x_cimv_rec	    => l_cimv_rec_out);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                x_cimv_rec := l_cimv_rec_out;
             End If;
                --update transaction status
                update_trx_status(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
	                  x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_tas_id        => l_iipv_rec.tas_id,
                      p_tsu_code      => G_TSU_CODE_PROCESSED);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
             End If;--get iipv rec
         End If;--cimv_rec
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
End Process_IB_Line;


--------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : ACTIVATE_IB_INSTANCE
  --Purpose               : Calls IB API to create an item instance in IB
  --                        Selects ib instance to create given a top line
  --                        and line style codes for instance line and ib
  --                        line.
  --Modification History  :
  --15-Jun-2001    avsingh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
--------------------------------------------------------------------------------
Procedure ACTIVATE_IB_INSTANCE(p_api_version   IN  NUMBER,
	                       p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                       x_return_status OUT NOCOPY VARCHAR2,
	                       x_msg_count     OUT NOCOPY NUMBER,
	                       x_msg_data      OUT NOCOPY VARCHAR2,
                               p_chrv_id       IN  NUMBER,
                               p_call_mode     IN  VARCHAR2,
                               x_cimv_tbl      OUT NOCOPY cimv_tbl_type) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'ACTIVATE_IB_INSTANCE';
  l_api_version	      CONSTANT NUMBER	:= 1.0;
  l_trx_type          VARCHAR2(30) := G_TRX_LINE_TYPE_BOOK;

  --cursor to verify the subclass code
  --contract has to be a 'LEASE' subclass contract to qualify for FA_ADDITION
  Cursor chk_subclass_csr(p_chrv_id IN NUMBER) is
  SELECT SCS_CODE,
         STS_CODE,
         INV_ORGANIZATION_ID,
         START_DATE -- rkuttiya added for bug # 6795295
  From   OKC_K_HEADERS_B
  WHERE  ID = P_CHRV_ID;

  l_scs_code    OKC_K_HEADERS_B.SCS_CODE%TYPE;
  l_sts_code    OKC_K_HEADERS_B.STS_CODE%TYPE;
  l_inv_org_id  OKC_K_HEADERS_B.INV_ORGANIZATION_ID%TYPE;

  --cursor to get ib line
   Cursor ib_line_csr(p_chrv_id IN Number) is
   SELECT cle.id,
          cle.cle_id
   from   okc_k_lines_b cle,
          okc_statuses_b sts  -- 4698117
   where  cle.lse_id = G_IB_LINE_LTY_ID
   and    cle.dnz_chr_id = p_chrv_id
   and    cle.sts_code = sts.code
   and    sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED');
   --and sts_code not in ('AMENDED', 'BANKRUPTCY_HOLD', 'EXPIRED', 'LITIGATION_HOLD','REVERSED', 'TERMINATED', 'TERMINATION_HOLD');

  --cursor to fetch ib master org id
  CURSOR mstr_org_csr (p_chr_id IN NUMBER) is
  SELECT MP.master_organization_id
  FROM   MTL_PARAMETERS   MP,
         OKC_K_HEADERS_B  CHR
  WHERE  MP.organization_id = CHR.inv_organization_id
  AND    CHR.id = p_chr_id;

  CURSOR party_account_csr(p_chrv_id IN NUMBER) is
  SELECT chrb.cust_acct_id
  FROM   OKC_K_HEADERS_B chrb
  WHERE  chrb.id = p_chrv_id;


  l_inv_mstr_org_id             NUMBER;
  l_party_account               NUMBER;
  l_inst_cle_id                 NUMBER;
  l_ib_cle_id                   NUMBER;
  l_ib_line_count               NUMBER;
  l_cimv_rec                    cimv_rec_type;
  l_cimv_tbl                    cimv_tbl_type;
  l_ib_line_lty_code            VARCHAR2(200) := G_IB_LINE_LTY_CODE;
  l_party_tbl                   party_tbl_type;
  l_model_line_qty              NUMBER;
  --bug# 2845959
  l_primary_uom_code            mtl_system_items.primary_uom_code%TYPE;
  --rkuttiya added for bug #6795295
  l_start_date                 DATE;

  TYPE ib_cle_id_tbl is table of okc_k_lines_b.id%TYPE INDEX BY BINARY_INTEGER;
  l_ib_cle_id_tbl    ib_cle_id_tbl;

  TYPE inst_cle_id_tbl is table of okc_k_lines_b.cle_id%TYPE INDEX BY BINARY_INTEGER;
  l_inst_cle_id_tbl inst_cle_id_tbl;

  TYPE ib_inst_rec_type IS RECORD (
     ib_cle_id          OKC_K_LINES_B.id%TYPE    ,
     inst_cle_id     OKC_K_LINES_B.cle_id %TYPE);

  TYPE ib_inst_tbl_type IS TABLE OF ib_inst_rec_type  INDEX BY BINARY_INTEGER;
  l_ib_inst_tbl      ib_inst_tbl_type;
  l_counter NUMBER;
  l_loop_index NUMBER;


Begin
    --call start activity to set savepoint
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    Open chk_subclass_csr(p_chrv_id);
        Fetch chk_subclass_csr into
                               l_scs_code,
                               l_sts_code,
                               l_inv_org_id,
                               l_start_date;
        If chk_subclass_csr%NOTFOUND Then
           --dbms_output.put_line('Contract Not Found ....!');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_CONTRACT_NOT_FOUND,
				               p_token1       => G_CONTRACT_ID_TOKEN,
				               p_token1_value => to_char(p_chrv_id)
				               );
           RAISE OKL_API.G_EXCEPTION_ERROR;
           --Handle error appropriately
        ElsIf upper(l_sts_code) <> G_APPROVED_STS_CODE Then
           --dbms_output.put_line('Contract has not been approved...!');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_CONTRACT_NOT_APPROVED
				               );
           RAISE OKL_API.G_EXCEPTION_ERROR;
           --raise appropriate exception
        ElsIf l_scs_code <> G_LEASE_SCS_CODE and upper(l_sts_code) = G_APPROVED_STS_CODE Then
            --dbms_output.put_line('Contract is not a lease contract...');
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                 p_msg_name     => G_CONTRACT_NOT_LEASE
				                 );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        ElsIf l_scs_code = G_LEASE_SCS_CODE  and upper(l_sts_code) = G_APPROVED_STS_CODE Then
         --get inventory master org id
         l_inv_mstr_org_id := null;
         OPEN  mstr_org_csr (p_chr_id => p_chrv_id);
         FETCH mstr_org_csr into
               l_inv_mstr_org_id;
         IF mstr_org_csr%NOTFOUND Then
              --raise error for unable to find inv mstr org
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_INV_MSTR_ORG_NOT_FOUND,
                                p_token1       =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value =>  to_char(p_chrv_id)
                                );
          RAISE OKL_API.G_EXCEPTION_ERROR;
              --l_inv_mstr_org_id := 204;
        ELSE
           Null;
        END IF;
        CLOSE mstr_org_csr;
        --get party accoutnt id
        l_party_account := null;
        OPEN party_account_csr(p_chrv_id => p_chrv_id);
        FETCH party_account_csr into
              l_party_account;
        IF party_account_csr%NOTFOUND Then
            --raise error for unable to find inv mstr org
            OKL_API.SET_MESSAGE(p_app_name     =>  g_app_name,
                                p_msg_name     =>  G_CUST_ACCOUNT_FOUND,
                                p_token1       =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value =>  to_char(p_chrv_id)
                                );
            RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
            NULL;
        END IF;
        CLOSE party_account_csr;
        --initialize party tbl
        get_party_rec(p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_chrv_id          => p_chrv_id,
                      x_party_tbl        => l_party_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        l_counter := 1;
        l_ib_line_count := 1;

        -- get the transaction records
        Open ib_line_csr(p_chrv_id => p_chrv_id);
        Loop
           l_ib_cle_id_tbl.delete;
           l_inst_cle_id_tbl.delete;

           Fetch ib_line_csr BULK COLLECT
           into l_ib_cle_id_tbl, l_inst_cle_id_tbl
           LIMIT G_BULK_BATCH_SIZE;

           if (l_ib_cle_id_tbl.COUNT > 0) then
              for i in l_ib_cle_id_tbl.FIRST .. l_ib_cle_id_tbl.LAST LOOP
                  l_ib_inst_tbl(l_counter).ib_cle_id := l_ib_cle_id_tbl(i);
                  l_ib_inst_tbl(l_counter).inst_cle_id := l_inst_cle_id_tbl(i);
                  l_counter := l_counter + 1;
              End Loop;
           end if;
           Exit When ib_line_csr%NotFound;
        End Loop;
        CLOSE ib_line_csr;

        IF (l_ib_inst_tbl.COUNT > 0) THEN

           l_loop_index := l_ib_inst_tbl.FIRST;
           LOOP
              l_ib_cle_id := l_ib_inst_tbl(l_loop_index).ib_cle_id;
              l_inst_cle_id := l_ib_inst_tbl(l_loop_index).inst_cle_id;


            --Bug Fix# 2781900 : This processing will have to be done for each IB line
            --If l_ib_line_count = 1 Then
            --do contract level one time processing
            Process_IB_Line(p_api_version         => p_api_version,
                              p_init_msg_list       => p_init_msg_list,
	                          x_return_status       => x_return_status,
	                          x_msg_count           => x_msg_count,
	                          x_msg_data            => x_msg_data,
                              p_chrv_id             => p_chrv_id,
                              p_start_date          => l_start_date,
                              p_inst_cle_id         => l_inst_cle_id,
                              p_ib_cle_id           => l_ib_cle_id,
                              p_party_tbl           => l_party_tbl,
                              p_party_account       => l_party_account,
                              p_inv_mstr_org_id     => l_inv_mstr_org_id,
                              p_model_line_qty      => l_model_line_qty,
                              --bug#2845959
                              p_uom_code            => l_primary_uom_code,
                              p_trx_type            => l_trx_type,
                              --bug#3222804
                              p_inv_org_id          => l_inv_org_id,
                              x_cimv_rec            => l_cimv_rec);

              --dbms_output.put_line('After Process_Line_1 '||x_return_status);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		          RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
	      l_cimv_tbl(l_ib_line_count) := l_cimv_rec;
              l_ib_line_count := l_ib_line_count+1;

           EXIT WHEN l_loop_index = l_ib_inst_tbl.LAST;
           l_loop_index := l_ib_inst_tbl.NEXT(l_loop_index);

           End Loop; -- ib line csr
         End IF;

       End If;
    Close chk_subclass_csr;
    x_cimv_tbl := l_cimv_tbl;
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END ACTIVATE_IB_INSTANCE;
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : ACTIVATE_RBK_IB_INST
  --Purpose               : Calls IB API to create an item instance in IB
  --                        Selects ib instance to create given a top line
  --                        for a new line created during rebook
  --Modification History  :
  --01-May-2002    avsingh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
Procedure ACTIVATE_RBK_IB_INST(p_api_version         IN  NUMBER,
	                           p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                           x_return_status       OUT NOCOPY VARCHAR2,
	                           x_msg_count           OUT NOCOPY NUMBER,
	                           x_msg_data            OUT NOCOPY VARCHAR2,
                               p_fin_ast_cle_id      IN  NUMBER,
                               x_cimv_tbl            OUT NOCOPY cimv_tbl_type) is

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name          CONSTANT VARCHAR2(30) := 'ACTIVATE_RBK_IB_INST';
  l_api_version	      CONSTANT NUMBER	:= 1.0;
  l_trx_type          VARCHAR2(30)      := G_TRX_LINE_TYPE_REBOOK;

--cursor to fetch active IB lines under the given top line
   Cursor ib_line_csr(p_fin_ast_cle_id IN Number, p_lty_code IN VARCHAR2) is
   SELECT cle.id,
          cle.cle_id,
          cle.dnz_chr_id
   from   okc_k_lines_b     cle,
          okc_line_styles_b lse,
          okc_k_lines_b     inst_cle,
          okc_line_styles_b inst_cle_lse
   where  lse.id          = cle.lse_id
   and    lse.lty_code    = p_lty_code
   and    cle.cle_id      = inst_cle.id
   and    cle.dnz_chr_id  = inst_cle.dnz_chr_id
   and    inst_cle_lse.id = inst_cle.lse_id
   and    inst_cle_lse.lty_code = 'FREE_FORM2'
   and    inst_cle.cle_id       = p_fin_ast_cle_id
   AND    not exists (select '1'
                   from   OKC_STATUSES_B sts
                   Where  sts.code = cle.sts_code
                   --Bug#2522268
                   --And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELED'))
                   And    sts.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED'))
  AND    not exists (select '1'
                     from   OKC_STATUSES_B sts2
                     Where  sts2.code = inst_cle.sts_code
                     --Bug#2522268
                     --And    sts2.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELED'));
                     And    sts2.ste_code in ('HOLD','EXPIRED','TERMINATED','CANCELLED'));

  l_ib_cle_id    OKC_K_LINES_B.ID%TYPE;
  l_inst_cle_id  OKC_K_LINES_B.ID%TYPE;
  l_chr_id       OKC_K_LINES_B.DNZ_CHR_ID%TYPE;

  l_ib_line_lty_code            VARCHAR2(200) := G_IB_LINE_LTY_CODE;
  l_ib_line_count               NUMBER default 0;
  l_cimv_tbl                    cimv_tbl_type;

  l_party_tbl                   party_tbl_type;
  l_party_account               NUMBER;
  l_inv_mstr_org_id             NUMBER;
  l_cimv_rec                    cimv_rec_type;
  l_model_line_qty				NUMBER;
  --bug# 2845959
  l_primary_uom_code            mtl_system_items.primary_uom_code%TYPE;
  --bug# 3222804
  l_inv_org_id                  NUMBER;


Begin
   --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Open cursor to get IB lines
    Open ib_line_csr(p_fin_ast_cle_id => p_fin_ast_cle_id , p_lty_code => l_ib_line_lty_code);
    Loop
        Fetch ib_line_csr into l_ib_cle_id, l_inst_cle_id, l_chr_id;
        Exit when ib_line_csr%NOTFOUND;
        l_ib_line_count := ib_line_csr%RowCount;
        --Fixed as part of Bug# 3222804
        --If l_ib_line_count = 1 Then
            --do contract level one time processing
            Process_IB_Line_1(p_api_version         => p_api_version,
                              p_init_msg_list       => p_init_msg_list,
	                          x_return_status       => x_return_status,
	                          x_msg_count           => x_msg_count,
	                          x_msg_data            => x_msg_data,
                              p_chrv_id             => l_chr_id,
                              p_inst_cle_id         => l_inst_cle_id,
                              p_ib_cle_id           => l_ib_cle_id,
                              x_party_tbl           => l_party_tbl,
                              x_party_account       => l_party_account,
                              x_inv_mstr_org_id     => l_inv_mstr_org_id,
                              x_model_line_qty      => l_model_line_qty,
                              --bug#2845959
                              x_primary_uom_code    => l_primary_uom_code,
                              --bug# 3222804
                              x_inv_org_id          => l_inv_org_id);

            --dbms_output.put_line('After Process_Line_1 '||x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		        RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        --End If;
        --process for each ib line (this calls ib create item instance api)
        Process_IB_Line_2(p_api_version         => p_api_version,
                          p_init_msg_list       => p_init_msg_list,
	                      x_return_status       => x_return_status,
	                      x_msg_count           => x_msg_count,
	                      x_msg_data            => x_msg_data,
                          p_chrv_id             => l_chr_id,
                          p_inst_cle_id         => l_inst_cle_id,
                          p_ib_cle_id           => l_ib_cle_id,
                          p_party_tbl           => l_party_tbl,
                          p_party_account       => l_party_account,
                          p_inv_mstr_org_id     => l_inv_mstr_org_id,
                          p_model_line_qty      => l_model_line_qty,
                          --bug#2845959
                          p_uom_code            => l_primary_uom_code,
                          p_trx_type            => l_trx_type,
                          --bug#3222804
                          p_inv_org_id          => l_inv_org_id,
                          x_cimv_rec            => l_cimv_rec);
        --dbms_output.put_line('After Process_Line_1 '||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  		    RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_cimv_tbl(l_ib_line_count) := l_cimv_rec;
    End Loop;
    Close ib_line_csr;
    x_cimv_tbl := l_cimv_tbl;
    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END ACTIVATE_RBK_IB_INST;
--Bug# 3533936 :
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  RELEASE_IB_INSTANCE (Activate code branch for release)
--Description    :  Will be called from activate contract and make re-lease updates
--                  in IB
--History        :
--                 29-Mar-2004  ashish.singh Created
-- Notes         :
--      IN Parameters -
--                     p_rel_chr_id    - contract id of released contract
--
--End of Comments
--------------------------------------------------------------------------------
  PROCEDURE RELEASE_IB_INSTANCE
                        (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER
                        ) IS

 l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
 l_api_name             CONSTANT varchar2(30) := 'RELEASE_IB_INSTANCE';
 l_api_version          CONSTANT NUMBER := 1.0;

  ------------------------------------------------
  --Cursor to get the k header info
  ------------------------------------------------
  CURSOR l_hdr_csr (p_rel_chr_id IN NUMBER) IS
  SELECT khr.deal_type,
         chr.id,
         chr.sts_code,
         chr.orig_system_id1,
         khr.pdt_id,
         chr.start_date,
         cplb.object1_id1,
         chr.cust_acct_id,
         chr.scs_code
  FROM   OKC_K_PARTY_ROLES_B cplb,
         OKC_RULES_B       rul,
         OKL_K_HEADERS     khr,
         OKC_K_HEADERS_B   chr
  WHERE  cplb.chr_id                     = chr.id
  AND    cplb.dnz_chr_id                 = chr.id
  AND    cplb.rle_code                   = 'LESSEE'
  AND    rul.dnz_chr_id                  = chr.id
  AND    rul.rule_information_category   = 'LARLES'
  AND    rul.dnz_chr_id                  = khr.id  --added as part of performance tuning by dkagrawa
  AND    khr.id                          = chr.id
  AND    chr.id                          = p_rel_chr_id
  AND    nvl(rul.Rule_information1,'N')  = 'Y';

  l_hdr_rec l_hdr_csr%ROWTYPE;

  ---------------------------------------------------------------------------
  --Cursor to find out the instance id and its location on the re-lease asset
  --Contract
  --------------------------------------------------------------------------
  Cursor l_ib_line_csr (p_rel_chr_id in Number) is
  Select cim_ib.object1_id1,
         iti.object_id1_new,
         trx.id           tas_id,
         cleb_ib.id       cleb_ib_id
  From   okc_k_items        cim_ib,
         okc_k_lines_b      cleb_ib,
         okc_line_styles_b  lseb_ib,
         okc_statuses_b     stsb,
         okl_txl_itm_insts  iti,
         okl_trx_assets     trx,
         okl_trx_types_tl   ttyt
  where  iti.kle_id          = cleb_ib.id
  and    iti.tas_id          = trx.id
  and    trx.tas_type        = 'CRL'
  and    trx.tsu_code        = 'ENTERED'
  and    trx.try_id          = ttyt.id
  and    ttyt.language       = userenv('LANG')
  and    ttyt.name           = 'Internal Asset Creation'
  and    cim_ib.cle_id       = cleb_ib.id
  and    cim_ib.dnz_chr_id   = cleb_ib.dnz_chr_id
  and    cleb_ib.dnz_chr_id  = p_rel_chr_id
  and    lseb_ib.id          = cleb_ib.lse_id
  and    lseb_ib.lty_code    = 'INST_ITEM'
  and    cleb_ib.sts_code    = stsb.code
  and    stsb.ste_code not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

  l_ib_line_rec    l_ib_line_csr%ROWTYPE;


  ----------------------------------------------------------------------------
  --Cursor to get owner party and account  and location info from install base
  ---------------------------------------------------------------------------
  Cursor l_csi_csr(p_instance_id in number)  is
  Select *
  from   csi_item_instances
  where  instance_id = p_instance_id;

  l_csi_rec l_csi_csr%ROWTYPE;

  --------------------------------------------------------------------------
  --Cursor to get party site id
  -------------------------------------------------------------------------
  Cursor l_party_site_csr (p_site_use_id in number) is
  Select hps.location_id,
         hpsu.party_site_id
  from   hz_party_sites hps,
         hz_party_site_uses hpsu
  where  hps.party_site_id      = hpsu.party_site_id
  and    hpsu.party_site_use_id = p_site_use_id;

  l_party_site_rec    l_party_site_csr%ROWTYPE;

  --cursor to get owner party rec
  cursor l_csi_owner_csr(p_instance_id in number) is
  select *
  from   csi_i_parties
  where  instance_id = p_instance_id
  and    relationship_type_code = 'OWNER'
  and    active_end_date is null;

  l_csi_owner_rec    l_csi_owner_csr%ROWTYPE;


  l_instance_rec                       csi_datastructures_pub.instance_rec;
  l_extend_attrib_values_tbl           csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                          csi_datastructures_pub.party_tbl;
  l_party_account_tbl                  csi_datastructures_pub.party_account_tbl;
  l_pricing_attribs_tbl                csi_datastructures_pub.pricing_attribs_tbl;
  l_organization_units_tbl             csi_datastructures_pub.organization_units_tbl;
  l_instance_Asset_tbl                 csi_datastructures_pub.instance_asset_tbl;
  l_transaction_rec                    csi_datastructures_pub.transaction_rec;
  l_id_tbl                             csi_datastructures_pub.id_tbl;

  l_update_required                    varchar2(1) default 'N';
  l_count                              NUMBER      default 0;

  --instance query recs
  l_instance_query_rec           CSI_DATASTRUCTURES_PUB.instance_query_rec;
  l_party_query_rec              CSI_DATASTRUCTURES_PUB.party_query_rec;
  l_account_query_rec            CSI_DATASTRUCTURES_PUB.party_account_query_rec;
  l_instance_header_tbl          CSI_DATASTRUCTURES_PUB.instance_header_tbl;
  l_instance_header_rec          CSI_DATASTRUCTURES_PUB.instance_header_rec;

begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --1.0 Get the release asset customer and account
    Open l_hdr_csr(p_rel_chr_id => p_rel_chr_id);
    Fetch l_hdr_csr into l_hdr_rec;
    If l_hdr_csr%NOTFOUND then
        --error : contract header data not found
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => G_CONTRACT_NOT_FOUND,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_rel_chr_id)
                            );
           RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;
    Close l_hdr_csr;

    --1.1 check if the contract status is 'APPROVED' and that it is a LEASE contract
    If upper(l_hdr_rec.sts_code) <> G_APPROVED_STS_CODE Then
        --error : contract is not APPROVED
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => G_CONTRACT_NOT_APPROVED
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ElsIf l_hdr_rec.scs_code <> G_LEASE_SCS_CODE and upper(l_hdr_rec.sts_code) = G_APPROVED_STS_CODE Then
        --error : Contract is not lease
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => G_CONTRACT_NOT_LEASE
                            );
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    --2.0 Get the ib instance id and install at location party site use id
    Open  l_ib_line_csr(p_rel_chr_id => p_rel_chr_id);
    Loop
        Fetch l_ib_line_csr into l_ib_line_rec;
        Exit when l_ib_line_csr%NOTFOUND;

        --3.0 Get original values from install base
        l_instance_query_rec.instance_id  :=  to_number(l_ib_line_rec.object1_id1);

        csi_item_instance_pub.get_item_instances (
         p_api_version           => p_api_version,
         p_commit                => FND_API.G_FALSE,
         p_init_msg_list         => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_instance_query_rec    => l_instance_query_rec,
         p_party_query_rec       => l_party_query_rec,
         p_account_query_rec     => l_account_query_rec,
         p_transaction_id        => NULL,
         p_resolve_id_columns    => FND_API.G_FALSE,
         p_active_instance_only  => FND_API.G_TRUE,
         x_instance_header_tbl   => l_instance_header_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        If l_instance_header_tbl.COUNT > 0 then
            l_instance_header_rec := l_instance_header_tbl(1);


            --4.0 Get party_site_id
            Open l_party_site_csr (p_site_use_id => to_number(l_ib_line_rec.object_id1_new));
            Fetch l_party_site_csr into l_party_site_rec;
            If l_party_site_csr%NOTFOUND then
                --error : instance location id not found
                OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                    p_msg_name     => G_INSTALL_LOC_NOT_FOUND,
                                    p_token1       => G_INST_SITE_USE_TOKEN,
                                    p_token1_value => l_ib_line_rec.object_id1_new
                                   );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
            close l_party_site_csr;

            --5.0 Decide if it is required to call instance update API
            l_update_required := 'N';

            Open l_csi_csr(p_instance_id =>  l_instance_header_rec.instance_id);
            Fetch l_csi_csr into l_csi_rec;
            If l_csi_csr%NOTFOUND then
                null; --should not happen as we have already queried the instance
            End If;
            CLose l_csi_csr;

            --check for party and account changes
            If nvl(l_csi_rec.owner_party_source_table,OKL_API.G_MISS_CHAR) = 'HZ_PARTIES' then
                If to_number(l_hdr_rec.object1_id1) <> l_csi_rec.owner_party_id then
                    l_update_required := 'Y';
                    l_count := l_party_tbl.COUNT;
                    Open l_csi_owner_csr(p_instance_id => l_instance_header_rec.instance_id);
                    Fetch l_csi_owner_csr into l_csi_owner_rec;
                    If l_csi_owner_csr%NOTFOUND then
                        null;
                    Else
                        l_count := l_count + 1;
                        l_party_tbl(l_count).instance_party_id      := l_csi_owner_rec.instance_party_id;
                        l_party_tbl(l_count).object_version_number  := l_csi_owner_rec.object_version_number;
                        l_party_tbl(l_count).relationship_type_code := 'OWNER';
                        l_party_tbl(l_count).party_id               := to_number(l_hdr_rec.object1_id1);
                    End If;
                    Close l_csi_owner_csr;
                End If;
                If l_hdr_rec.cust_acct_id <> l_csi_rec.owner_party_account_id then
                    l_update_required := 'Y';
                    If l_party_tbl.COUNT <> 0 then
                        l_party_account_tbl(1).instance_party_id      := l_csi_owner_rec.instance_party_id;
                        l_party_account_tbl(1).party_account_id       := l_hdr_rec.cust_acct_id;
                        l_party_account_tbl(1).relationship_type_code := G_PARTY_RELATIONSHIP;
                        --l_party_account_tbl(1).parent_tbl_index       := l_count;
                     End If;

                End If;
            End If;

            --check for install location changes
            If nvl(l_instance_header_rec.location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' then
                If l_party_site_rec.location_id <> l_instance_header_rec.location_id then
                   l_update_required := 'Y';
                   l_instance_rec.location_id := l_party_site_rec.location_id;
                End If;
            Elsif nvl(l_instance_header_rec.location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_PARTY_SITES' then
                if l_party_site_rec.party_site_id <> l_instance_header_rec.location_id then
                    l_update_required := 'Y';
                    l_instance_rec.location_id := l_party_site_rec.party_site_id;
                end If;
            End If;

            If nvl(l_instance_header_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' then
                If l_party_site_rec.location_id <> l_instance_header_rec.install_location_id then
                   l_update_required := 'Y';
                   l_instance_rec.install_location_id := l_party_site_rec.location_id;
                End If;
            Elsif nvl(l_instance_header_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_PARTY_SITES' then
                if l_party_site_rec.party_site_id <> l_instance_header_rec.install_location_id then
                   l_update_required := 'Y';
                   l_instance_rec.install_location_id := l_party_site_rec.party_site_id;
                end If;
            End If;


            --6.0 call ib api if required
            If l_update_required = 'Y' then

                okl_context.set_okc_org_context(p_chr_id => p_rel_chr_id);
                --Call get_trx_rec
                get_trx_rec(p_api_version      => p_api_version,
                            p_init_msg_list    => p_init_msg_list,
                            x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            p_cle_id           => l_ib_line_rec.cleb_ib_id,
                            p_transaction_type => G_IB_BKNG_TXN_TYPE,
                            x_trx_rec          => l_transaction_rec);

                 IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                     RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;

                l_instance_rec.instance_id    := l_instance_header_rec.instance_id;
                l_instance_rec.object_version_number := l_instance_header_rec.object_version_number;
                csi_item_instance_pub.update_item_instance
                (
                 p_api_version           => p_api_version
                ,p_commit                => fnd_api.g_false
                ,p_init_msg_list         => p_init_msg_list
                ,p_validation_level      => fnd_api.g_valid_level_full
                ,p_instance_rec          => l_instance_rec
                ,p_ext_attrib_values_tbl => l_extend_attrib_values_tbl
                ,p_party_tbl             => l_party_tbl
                ,p_account_tbl           => l_party_account_tbl
                ,p_pricing_attrib_tbl    => l_pricing_attribs_tbl
                ,p_org_assignments_tbl   => l_organization_units_tbl
                ,p_asset_assignment_tbl  => l_instance_Asset_tbl
                ,p_txn_rec               => l_transaction_rec
                ,x_instance_id_lst       => l_id_tbl
                ,x_return_status         => x_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data
                );

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

            End If;

            l_extend_attrib_values_tbl.delete;
            l_party_tbl.delete;
            l_party_account_tbl.delete;
            l_pricing_attribs_tbl.delete;
            l_organization_units_tbl.delete;
            l_instance_Asset_tbl.delete;
            l_instance_header_tbl.delete;
            initialize_txn_rec(l_transaction_rec);
            Initialize_instance_rec(l_instance_rec);

            --7.0 update the transaction status to processed
            update_trx_status(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_tas_id        => l_ib_line_rec.tas_id,
                              p_tsu_code      => G_TSU_CODE_PROCESSED);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

        End If;

    End Loop;
    close l_ib_line_csr;

    --Call end Activity
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  End RELEASE_IB_INSTANCE;


 --Bug# 5207066
 PROCEDURE Is_Inv_Item_Serialized(p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 p_inv_item_id      IN  NUMBER,
                                 p_chr_id           IN  NUMBER,
                                 p_cle_id           IN  NUMBER,
                                 x_serialized       OUT NOCOPY VARCHAR2) IS
l_api_version CONSTANT NUMBER := 1.0;
l_api_name    VARCHAR2(30) := 'IS_INV_ITEM_SERIALIZED';

l_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;

--cursor to find serialized
CURSOR srl_ctrl_csr (p_inv_item_id IN NUMBER,
                     p_chr_id IN NUMBER) IS
SELECT mtl.serial_number_control_code
FROM   mtl_system_items  mtl,
       okc_k_headers_b chrb
WHERE  mtl.inventory_item_id = p_inv_item_id
AND    mtl.organization_id   = chrb.inv_organization_id
--BUG# 3489089
AND    chrb.id               = p_chr_id;

--cursor2  to find serialized
CURSOR srl_ctrl_csr2 (p_inv_item_id IN NUMBER,
                      p_cle_id IN NUMBER) IS
SELECT mtl.serial_number_control_code
FROM   mtl_system_items     mtl,
       okc_k_headers_b      chrb,
       okc_k_lines_b        cleb
WHERE  mtl.inventory_item_id = p_inv_item_id
AND    mtl.organization_id   = chrb.inv_organization_id
AND    chrb.id               = cleb.dnz_chr_id
AND    cleb.id               = p_cle_id;

l_srl_control_code   mtl_system_items.serial_number_control_code%TYPE;

l_exception_halt     EXCEPTION;

BEGIN
   x_serialized := OKL_API.G_FALSE;
   x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_serialized := OKL_API.G_FALSE;
    IF p_chr_id IS NOT NULL OR p_chr_id <> OKL_API.G_MISS_NUM THEN
        OPEN srl_ctrl_csr (p_inv_item_id => p_inv_item_id,
                           p_chr_id      => p_chr_id);
        FETCH srl_ctrl_csr INTO
          l_srl_control_code;
        CLOSE srl_ctrl_csr;
    ELSIF p_cle_id IS NOT NULL OR p_cle_id <> OKL_API.G_MISS_NUM THEN
        OPEN srl_ctrl_csr2 (p_inv_item_id => p_inv_item_id,
                            p_cle_id      => p_cle_id);
        FETCH srl_ctrl_csr2 INTO
          l_srl_control_code;
        CLOSE srl_ctrl_csr2;
    ELSE
         RAISE l_exception_halt;
    END IF;

    IF NVL(l_srl_control_code,0) IN (2,5,6) THEN
        l_serialized := OKL_API.G_TRUE;
    END IF;
   x_serialized := l_serialized;
   OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN l_exception_halt THEN
        NULL;
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Is_Inv_Item_Serialized;

  --Bug# 5207066
  PROCEDURE RBK_SRL_NUM_IB_INSTANCE
                        (p_api_version        IN  NUMBER,
                         p_init_msg_list      IN  VARCHAR2,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2,
                         p_rbk_fin_ast_cle_id IN  NUMBER,
                         p_rbk_chr_id         IN  NUMBER
                        ) IS


   --cursor to get ib line
   Cursor ib_line_csr(p_chrv_id IN Number,
                    p_fin_ast_cle_id IN Number) is
   SELECT ib_cle.id,
          ib_cle.cle_id
   from   okc_k_lines_b ib_cle,
          okc_k_lines_b inst_cle,
          okc_statuses_b inst_sts
   where  ib_cle.lse_id = G_IB_LINE_LTY_ID
   and    ib_cle.dnz_chr_id = p_chrv_id
   AND    inst_sts.code      = ib_cle.sts_code
   AND    inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
   AND    ib_cle.cle_id = inst_cle.id
   and    inst_cle.dnz_chr_id = p_chrv_id
   and    inst_cle.cle_id = p_fin_ast_cle_id;

   -- cursor to get instance_id from okc_k_items
   Cursor get_instance_id_csr(p_cle_id IN Number) is
   SELECT  cim.object1_id1
   from    okc_k_items cim
   where   cim.cle_id = p_cle_id;

   -- cursor to get original contract id
   cursor get_orig_k_id (p_chr_id in number,
                         p_fin_ast_cle_id in number) is
   select chr.ORIG_SYSTEM_ID1 orig_chr_id,
          cle.orig_system_id1 orig_fin_ast_cle_id
   from okc_k_headers_b chr,
        okc_k_lines_b cle
   where chr.id = p_chr_id
   and   cle.id = p_fin_ast_cle_id
   and   cle.chr_id = p_chr_id
   and   cle.dnz_chr_id = p_chr_id;

   -- gboomina Bug 5362977 - Start
   CURSOR srl_num_to_add_csr(p_orig_fin_ast_cle_id IN NUMBER,
                             p_rbk_fin_ast_cle_id  IN NUMBER,
                             p_orig_chr_id         IN NUMBER,
                             p_rbk_chr_id          IN NUMBER ) IS

   SELECT orig_ib_cle.id       orig_ib_cle_id,
          orig_ib_cle.cle_id   orig_inst_cle_id,
          orig_ib_cle.orig_system_id1 rbk_ib_cle_id
   FROM   okc_k_lines_b  orig_ib_cle,
          okc_k_lines_b  orig_inst_cle,
          okc_k_lines_b  rbk_inst_cle,
          okc_statuses_b inst_sts,
          --Bug# 8766336
          okc_statuses_b rbk_inst_sts
   WHERE orig_inst_cle.dnz_chr_id = p_orig_chr_id
   AND   orig_inst_cle.cle_id = p_orig_fin_ast_cle_id
   AND   orig_inst_cle.lse_id = G_INST_LINE_LTY_ID
   AND   orig_ib_cle.cle_id = orig_inst_cle.id
   AND   orig_ib_cle.dnz_chr_id =  p_orig_chr_id
   AND   orig_ib_cle.lse_id = G_IB_LINE_LTY_ID
   AND   rbk_inst_cle.id  = orig_inst_cle.orig_system_id1
   AND   rbk_inst_cle.dnz_chr_id = p_rbk_chr_id
   AND   rbk_inst_cle.cle_id = p_rbk_fin_ast_cle_id
   AND   rbk_inst_cle.lse_id = G_INST_LINE_LTY_ID
   AND   inst_sts.code = orig_ib_cle.sts_code
   AND   inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
   --Bug# 8766336
   AND   rbk_inst_sts.code = rbk_inst_cle.sts_code
   AND   rbk_inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED');


   -- Modified query to only fetch IB lines deleted during rebook
   CURSOR srl_num_to_exp_csr(p_orig_fin_ast_cle_id IN NUMBER,
                             p_rbk_fin_ast_cle_id  IN NUMBER,
                             p_orig_chr_id         IN NUMBER,
                             p_rbk_chr_id          IN NUMBER) IS
   SELECT orig_ib_cle.id          ib_cle_id,
          orig_ib_cle.cle_id      inst_cle_id,
          orig_ib_cim.object1_id1 instance_id
    FROM  okc_k_items         orig_ib_cim,
          okc_k_lines_b       orig_ib_cle,
          okc_k_lines_b       orig_inst_cle,
          okc_statuses_b      inst_sts
    WHERE orig_inst_cle.dnz_chr_id = p_orig_chr_id
    AND   orig_inst_cle.cle_id = p_orig_fin_ast_cle_id
    AND   orig_inst_cle.lse_id = G_INST_LINE_LTY_ID
    AND   orig_ib_cle.cle_id = orig_inst_cle.id
    AND   orig_ib_cle.dnz_chr_id =  p_orig_chr_id
    AND   orig_ib_cle.lse_id = G_IB_LINE_LTY_ID
    AND   orig_ib_cim.cle_id = orig_ib_cle.id
    AND   orig_ib_cim.dnz_chr_id = p_orig_chr_id
    AND   orig_ib_cim.object1_id1 IS NOT NULL
    AND   inst_sts.code = orig_ib_cle.sts_code
    AND   inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
    AND   NOT EXISTS (
           SELECT 1
           FROM okc_k_lines_b  rbk_inst_cle,
                okc_statuses_b rbk_inst_sts
           WHERE rbk_inst_cle.orig_system_id1  = orig_inst_cle.id
           AND   rbk_inst_cle.lse_id = G_INST_LINE_LTY_ID
           AND   rbk_inst_cle.dnz_chr_id = p_rbk_chr_id
           AND   rbk_inst_cle.cle_id = p_rbk_fin_ast_cle_id
           AND   rbk_inst_sts.code = rbk_inst_cle.sts_code
           AND   rbk_inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED'));

   CURSOR srl_num_to_update_csr(p_orig_fin_ast_cle_id IN NUMBER,
                                p_rbk_fin_ast_cle_id  IN NUMBER,
                                p_orig_chr_id         IN NUMBER,
                                p_rbk_chr_id          IN NUMBER ) IS

   SELECT orig_ib_cle.id       orig_ib_cle_id,
          orig_ib_cle.cle_id   orig_inst_cle_id,
          rbk_ib_cle.id        rbk_ib_cle_id,
          rbk_ib_cle.cle_id    rbk_inst_cle_id,
          TO_NUMBER(ib_cim.object1_id1) instance_id,
          ib_cim.id            orig_ib_cim_id
   FROM   okc_k_lines_b  orig_ib_cle,
          okc_k_lines_b  orig_inst_cle,
          okc_k_lines_b  rbk_inst_cle,
          okc_k_lines_b  rbk_ib_cle,
          okc_statuses_b inst_sts,
          okc_k_items ib_cim,
          --Bug# 8766336
          okc_statuses_b  rbk_inst_sts
   WHERE orig_inst_cle.dnz_chr_id = p_orig_chr_id
   AND   orig_inst_cle.cle_id = p_orig_fin_ast_cle_id
   AND   orig_inst_cle.lse_id = G_INST_LINE_LTY_ID
   AND   orig_ib_cle.cle_id = orig_inst_cle.id
   AND   orig_ib_cle.dnz_chr_id =  p_orig_chr_id
   AND   orig_ib_cle.lse_id = G_IB_LINE_LTY_ID
   AND   rbk_inst_cle.orig_system_id1  = orig_inst_cle.id
   AND   rbk_inst_cle.dnz_chr_id = p_rbk_chr_id
   AND   rbk_inst_cle.cle_id = p_rbk_fin_ast_cle_id
   AND   rbk_inst_cle.lse_id = G_INST_LINE_LTY_ID
   AND   rbk_ib_cle.cle_id = rbk_inst_cle.id
   AND   rbk_ib_cle.dnz_chr_id =  p_rbk_chr_id
   AND   rbk_ib_cle.lse_id = G_IB_LINE_LTY_ID
   AND   inst_sts.code = orig_ib_cle.sts_code
   AND   inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
   --Bug# 8766336
   AND   rbk_inst_sts.code = rbk_ib_cle.sts_code
   AND   rbk_inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
   AND   ib_cim.cle_id = orig_ib_cle.id
   AND   ib_cim.dnz_chr_id = p_orig_chr_id;

   CURSOR srl_num_old_csr(p_instance_id IN NUMBER) IS
   SELECT csi_item.serial_number
   FROM   csi_item_instances  csi_item
   WHERE  csi_item.instance_id = p_instance_id;

   l_srl_num_old_rec  srl_num_old_csr%ROWTYPE;

   CURSOR srl_num_new_csr(p_rbk_fin_ast_cle_id IN NUMBER,
                          p_rbk_ib_cle_id IN NUMBER) IS
   SELECT serial_number
   FROM   okl_txl_itm_insts iti,
          okl_trx_assets tas
   WHERE iti.dnz_cle_id = P_rbk_fin_ast_cle_id
   AND   iti.kle_id = p_rbk_ib_cle_id
   AND   iti.tal_type = G_TRX_LINE_TYPE_REBOOK
   AND   tas.tas_type = G_TRX_LINE_TYPE_REBOOK
   AND   tas.tsu_code = G_TSU_CODE_ENTERED
   AND   tas.id = iti.tas_id;

   l_srl_num_new_rec srl_num_new_csr%ROWTYPE;

   -- gboomina Bug 5362977 - End

   -- Get Original Inventory Item
   CURSOR orig_instance_dtls_csr (p_fin_ast_cle_id IN NUMBER,
                                  p_chr_id         IN NUMBER) is
   SELECT csi_item.inventory_item_id
   FROM   csi_item_instances csi_item,
          okc_k_items   ib_cim,
          okc_k_lines_b ib_cle,
          okc_k_lines_b inst_cle,
          okc_statuses_b inst_sts
   WHERE  ib_cim.cle_id        = ib_cle.id
   AND    ib_cim.dnz_chr_id    = p_chr_id
   AND    inst_cle.cle_id      = p_fin_ast_cle_id
   AND    inst_cle.lse_id      = G_INST_LINE_LTY_ID
   AND    inst_cle.dnz_chr_id  = p_chr_id
   AND    ib_cle.cle_id        = inst_cle.id
   AND    ib_cle.lse_id        = G_IB_LINE_LTY_ID
   AND    ib_cle.dnz_chr_id    = p_chr_id
   AND    csi_item.instance_id = TO_NUMBER(ib_cim.object1_id1)
   AND    inst_sts.code        = ib_cle.sts_code
   AND    inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED');

  --- Get quantity cursor
  CURSOR get_qty_csr (p_fin_ast_cle_id IN NUMBER) is
  SELECT cim.number_of_items,
         cim.object1_id1,
         cim.object1_id2
  FROM   OKC_K_ITEMS        CIM,
         OKC_K_LINES_B      MDL,
         OKC_LINE_STYLES_B MDL_LSE
  WHERE  CIM.CLE_ID       = MDL.ID
  AND    MDL.CLE_ID       = p_fin_ast_cle_id
  AND    MDL.LSE_ID       = MDL_LSE.ID
  AND    MDL_LSE.LTY_CODE = G_MODEL_LINE_LTY_CODE;

  -- gboomina Bug 5362977 - End

  l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT varchar2(30) := 'RBK_SRL_NUM_IB_INSTANCE';
  l_api_version          CONSTANT NUMBER := 1.0;

  l_orig_inv_org_id      okc_k_items.object1_id1%TYPE;
  l_orig_inv_item_id     okc_k_items.object1_id2%TYPE;

  -- gboomina Bug 5362977 - Start
  l_orig_serialized VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
  l_rbk_serialized  VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
  -- gboomina Bug 5362977 - End

  l_orig_k_id     okc_k_headers_b.id%type;
  l_orig_fin_ast_cle_id okc_k_lines_b.id%type;
  l_instance_id   okc_k_items.id%type;
  l_instance_cle_id okc_k_items.cle_id%type;

  l_instance_rec                     CSI_DATASTRUCTURES_PUB.instance_rec;
  l_upd_instance_rec                 CSI_DATASTRUCTURES_PUB.instance_rec;

  l_upd_ext_attrib_values_tbl        CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
  l_upd_party_tbl                    CSI_DATASTRUCTURES_PUB.party_tbl;
  l_upd_party_tbl_in                 CSI_DATASTRUCTURES_PUB.party_tbl;
  l_upd_account_tbl                  CSI_DATASTRUCTURES_PUB.party_account_tbl;
  l_upd_pricing_attrib_tbl           CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
  l_upd_org_assignments_tbl          CSI_DATASTRUCTURES_PUB.organization_units_tbl;
  l_upd_asset_assignment_tbl         CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
  l_upd_txn_rec                      CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_upd_instance_id_lst              CSI_DATASTRUCTURES_PUB.id_tbl;
  l_account_tbl                      party_account_tbl_type;

  -- gboomina Bug 5362977 - Start
  l_rbk_model_line_qty        okc_k_items.number_of_items%TYPE;
  l_rbk_inv_item_id           okc_k_items.object1_id1%TYPE;
  l_rbk_inv_org_id            okc_k_items.object1_id2%TYPE;
  l_instance_query_temp_rec           CSI_DATASTRUCTURES_PUB.instance_query_rec;
  l_instance_header_temp_rec          CSI_DATASTRUCTURES_PUB.instance_header_rec;
  l_instance_temp_rec                 CSI_DATASTRUCTURES_PUB.instance_rec;
  l_model_line_qty                    okc_k_items.number_of_items%TYPE;
  l_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
  x_cim_rec                      okl_okc_migration_pvt.cimv_rec_type;
  -- gboomina Bug 5362977 - End

  l_trx_type          VARCHAR2(30)      := G_TRX_LINE_TYPE_REBOOK;

  ib_line_id          okc_k_lines_b.id%type;
  ib_line_cle_id      okc_k_lines_b.cle_id%type;

  rbk_ib_line_id      okc_k_lines_b.id%type;
  rbk_ib_line_cle_id  okc_k_lines_b.cle_id%type;

  l_party_tbl                    party_tbl_type;
  l_party_account                NUMBER;
  l_inv_mstr_org_id              NUMBER;
  l_primary_uom_code            MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE%TYPE;
  l_cimv_rec                    cimv_rec_type;
  l_clev_rec                    okl_okc_migration_pvt.clev_rec_type;
  l_klev_rec                    okl_kle_pvt.klev_rec_type;
  x_clev_rec                    okl_okc_migration_pvt.clev_rec_type;
  x_klev_rec                    okl_kle_pvt.klev_rec_type;

  l_transaction_rec              CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_instance_query_rec           CSI_DATASTRUCTURES_PUB.instance_query_rec;
  l_party_query_rec              CSI_DATASTRUCTURES_PUB.party_query_rec;
  l_account_query_rec            CSI_DATASTRUCTURES_PUB.party_account_query_rec;
  l_instance_header_tbl          CSI_DATASTRUCTURES_PUB.instance_header_tbl;
  l_instance_header_rec          CSI_DATASTRUCTURES_PUB.instance_header_rec;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    --call start activity to set savepoint
    x_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get original contract_id
    Open get_orig_k_id(p_rbk_chr_id,p_rbk_fin_ast_cle_id);
    Fetch get_orig_k_id into l_orig_k_id,l_orig_fin_ast_cle_id;
    If get_orig_k_id%NOTFOUND then
      null; --should not happen
    End If;
    CLose get_orig_k_id;

    --okl_debug_pub.logmessage(' original contract id = ' ||l_orig_k_id );
    --dbms_output.put_line(' original contract id = ' ||l_orig_k_id);

    --okl_debug_pub.logmessage(' original fin asset line id = ' ||l_orig_fin_ast_cle_id );
    --dbms_output.put_line(' original fin asset line id = ' ||l_orig_fin_ast_cle_id);

    -- get original k inv item details
    -- gboomina Bug 5362977 - Start
    l_orig_inv_item_id  := 0;
    OPEN  orig_instance_dtls_csr(p_fin_ast_cle_id => l_orig_fin_ast_cle_id,
                                    p_chr_id         => l_orig_k_id);
       FETCH orig_instance_dtls_csr INTO l_orig_inv_item_id;
       CLOSE orig_instance_dtls_csr;

       --okl_debug_pub.logmessage(' orig inventory item id  = ' ||l_orig_inv_item_id );
       --dbms_output.put_line(' orig inventory item id  = ' ||l_orig_inv_item_id);

       -- get the number of qty
       l_rbk_model_line_qty := 0;
       OPEN get_qty_csr (p_fin_ast_cle_id => p_rbk_fin_ast_cle_id ); --l_instance_id
    FETCH get_qty_csr into
                           l_rbk_model_line_qty,
                           l_rbk_inv_item_id,
                           l_rbk_inv_org_id;
    IF get_qty_csr%NOTFOUND Then
         --okl_debug_pub.logmessage(' get_qty_csr not found');
         --dbms_output.put_line(' get_qty_csr not found');
           l_rbk_model_line_qty := 1;
    ELSE
         Null;
    END IF;
    CLOSE get_qty_csr;

    --okl_debug_pub.logmessage(' inventory org id = ' ||l_orig_inv_org_id );
    --okl_debug_pub.logmessage(' inventory item id  = ' ||l_orig_inv_item_id );
    --dbms_output.put_line(' inventory org id = ' ||l_orig_inv_org_id);
    --dbms_output.put_line(' inventory item id  = ' ||l_orig_inv_item_id);

    l_orig_serialized := OKL_API.G_FALSE;

    Is_Inv_Item_Serialized(p_api_version     => p_api_version,
                          p_init_msg_list   => p_init_msg_list,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data,
                          p_inv_item_id     => l_orig_inv_item_id,
                          p_chr_id          => l_orig_k_id,
                          p_cle_id          => l_orig_fin_ast_cle_id,
                          x_serialized      =>  l_orig_serialized);
    -- gboomina Bug 5362977 - End

    --okl_debug_pub.logmessage(' Is_Inv_Item_Serialized x_return_status = ' ||x_return_status );
    --dbms_output.put_line(' Is_Inv_Item_Serialized x_return_status = ' ||x_return_status );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- gboomina Bug 5362977 - Start
    l_rbk_serialized := OKL_API.G_FALSE;
    Is_Inv_Item_Serialized(p_api_version     => p_api_version,
                          p_init_msg_list   => p_init_msg_list,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data,
                          p_inv_item_id     => l_rbk_inv_item_id,
                          p_chr_id          => p_rbk_chr_id,
                          p_cle_id          => p_rbk_fin_ast_cle_id,
                          x_serialized      => l_rbk_serialized);

    --okl_debug_pub.logmessage(' Is_Inv_Item_Serialized x_return_status = ' ||x_return_status );
    --dbms_output.put_line(' Is_Inv_Item_Serialized x_return_status = ' ||x_return_status );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Expire and Re-create IB instance if Inventory item is changed.
    IF (l_orig_inv_item_id <> l_rbk_inv_item_id) THEN

      FOR srl_num_to_update_rec IN srl_num_to_update_csr(p_orig_fin_ast_cle_id => l_orig_fin_ast_cle_id,
                                                         p_rbk_fin_ast_cle_id  => p_rbk_fin_ast_cle_id,
                                                         p_orig_chr_id         => l_orig_k_id,
                                                         p_rbk_chr_id          => p_rbk_chr_id) LOOP
        --
        -- Expire IB instance with old inventory item
        --

        l_instance_query_rec := l_instance_query_temp_rec;
        l_instance_header_rec := l_instance_header_temp_rec;
        l_instance_rec := l_instance_temp_rec;

        l_instance_query_rec.instance_id  :=  srl_num_to_update_rec.instance_id;
        -- gboomina Bug 5362977 - End

      csi_item_instance_pub.get_item_instances (
         p_api_version           => p_api_version,
         p_commit                => FND_API.G_FALSE,
         p_init_msg_list         => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_instance_query_rec    => l_instance_query_rec,
         p_party_query_rec       => l_party_query_rec,
         p_account_query_rec     => l_account_query_rec,
         p_transaction_id        => NULL,
         p_resolve_id_columns    => FND_API.G_FALSE,
         p_active_instance_only  => FND_API.G_TRUE,
         x_instance_header_tbl   => l_instance_header_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      If l_instance_header_tbl.COUNT > 0 then
          l_instance_header_rec := l_instance_header_tbl(1);
      end if;

      -- gboomina Bug 5362977 - Start
       l_instance_rec.instance_id           := l_instance_header_rec.instance_id;
       l_instance_rec.object_version_number := l_instance_header_rec.object_version_number;

       --Call get_trx_rec
       get_trx_rec(p_api_version      => p_api_version,
                   p_init_msg_list    => p_init_msg_list,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_cle_id           => srl_num_to_update_rec.orig_ib_cle_id,
                   p_transaction_type => G_IB_BKNG_TXN_TYPE,
                   x_trx_rec          => l_transaction_rec);
      -- gboomina Bug 5362977 - End

      --okl_debug_pub.logmessage(' get_trx_rec  x_return_status= ' || x_return_status);
      --dbms_output.put_line(' get_trx_rec  x_return_status= ' || x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

       csi_item_instance_pub.expire_item_instance
                   (
                    p_api_version           => p_api_version
                   ,p_commit                => fnd_api.g_false
                   ,p_init_msg_list         => p_init_msg_list
                   ,p_validation_level      => fnd_api.g_valid_level_full
                   ,p_instance_rec          => l_instance_rec
                   ,p_expire_children       => fnd_api.g_false
                   ,p_txn_rec               => l_transaction_rec
                   ,x_instance_id_lst       => l_upd_instance_id_lst
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data);

      --okl_debug_pub.logmessage(' csi_item_instance_pub.update_item_instance x_return_status = ' || x_return_status);
      --dbms_output.put_line(' csi_item_instance_pub.update_item_instance x_return_status = ' || x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

	  l_cim_rec.id          := srl_num_to_update_rec.orig_ib_cim_id;
          l_cim_rec.object1_id1 := NULL;
          l_cim_rec.object1_id2 := NULL;
          l_cim_rec.jtot_object1_code := NULL;

          okl_okc_migration_pvt.update_contract_item(
            p_api_version                  => 1.0,
            p_init_msg_list                => okc_api.g_false,
            x_return_status                =>x_return_status,
            x_msg_count                    =>x_msg_count,
            x_msg_data                     =>x_msg_data,
            p_cimv_rec                     =>l_cim_rec,
            x_cimv_rec                     =>x_cim_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

     -- Create IB instance with new inventory item
          --

          Process_IB_Line_1(p_api_version      => p_api_version,
                            p_init_msg_list    => p_init_msg_list,
                              x_return_status    => x_return_status,
                              x_msg_count        => x_msg_count,
                              x_msg_data         => x_msg_data,
                            p_chrv_id          => l_orig_k_id,
                            p_inst_cle_id      => srl_num_to_update_rec.orig_inst_cle_id,
                            p_ib_cle_id        => srl_num_to_update_rec.orig_ib_cle_id,
                            x_party_tbl        => l_party_tbl,
                            x_party_account    => l_party_account,
                            x_inv_mstr_org_id  => l_inv_mstr_org_id,
                            x_model_line_qty   => l_model_line_qty,
                            x_primary_uom_code => l_primary_uom_code,
                            x_inv_org_id       => l_orig_inv_org_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       Process_IB_Line_2(p_api_version         => p_api_version,
                             p_init_msg_list       => p_init_msg_list,
                               x_return_status       => x_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data,
                             p_chrv_id             => l_orig_k_id,
                             p_inst_cle_id         => srl_num_to_update_rec.orig_inst_cle_id,
                             p_ib_cle_id           => srl_num_to_update_rec.orig_ib_cle_id,
                             p_party_tbl           => l_party_tbl,
                             p_party_account       => l_party_account,
                             p_inv_mstr_org_id     => l_inv_mstr_org_id,
                             p_model_line_qty      => l_model_line_qty,
                             p_uom_code            => l_primary_uom_code,
                             p_trx_type            => 'CRB',
                             p_inv_org_id          => l_orig_inv_org_id,
                             p_rbk_ib_cle_id       => srl_num_to_update_rec.rbk_ib_cle_id,
                             x_cimv_rec            => l_cimv_rec);
           --dbms_output.put_line('After Process_Line_2 1'||x_return_status);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

         END LOOP;

       END IF;

       IF (l_rbk_serialized = OKL_API.G_TRUE OR l_orig_serialized = OKL_API.G_TRUE) THEN

     --okl_debug_pub.logmessage(' IN serialized section ');
     --dbms_output.put_line(' IN serialized section ');

     --okl_debug_pub.logmessage(' rebook contract fin line id  = ' || p_rbk_fin_ast_cle_id);
     --okl_debug_pub.logmessage(' original contract fin line id  = ' || l_orig_fin_ast_cle_id);

     --dbms_output.put_line(' rebook contract fin line id  = ' || p_rbk_fin_ast_cle_id);
     --dbms_output.put_line(' original contract fin line id  = ' || l_orig_fin_ast_cle_id);

     -- to expire the instance items
      FOR srl_num_to_exp_rec IN srl_num_to_exp_csr(p_orig_fin_ast_cle_id => l_orig_fin_ast_cle_id,
                                                   p_rbk_fin_ast_cle_id  => p_rbk_fin_ast_cle_id,
                                                   p_orig_chr_id         => l_orig_k_id,
                                                   p_rbk_chr_id          => p_rbk_chr_id) LOOP
        --okl_debug_pub.logmessage('Expire IB Instance');
        --dbms_output.put_line('Expire IB Instance');

        --okl_debug_pub.logmessage('srl_num_to_exp_rec.ib_cle_id  = ' || srl_num_to_exp_rec.ib_cle_id);
        --dbms_output.put_line('srl_num_to_exp_rec.ib_cle_id  = ' || srl_num_to_exp_rec.ib_cle_id);

        --okl_debug_pub.logmessage('srl_num_to_exp_rec.inst_cle_id  = ' || srl_num_to_exp_rec.inst_cle_id);
        --dbms_output.put_line('srl_num_to_exp_rec.inst_cle_id  = ' || srl_num_to_exp_rec.inst_cle_id);

        l_instance_query_rec := l_instance_query_temp_rec;
        l_instance_header_rec := l_instance_header_temp_rec;
        l_instance_rec := l_instance_temp_rec;

        l_instance_query_rec.instance_id  :=  to_number(srl_num_to_exp_rec.instance_id);

        csi_item_instance_pub.get_item_instances (
         p_api_version           => p_api_version,
         p_commit                => FND_API.G_FALSE,
         p_init_msg_list         => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_instance_query_rec    => l_instance_query_rec,
         p_party_query_rec       => l_party_query_rec,
         p_account_query_rec     => l_account_query_rec,
         p_transaction_id        => NULL,
         p_resolve_id_columns    => FND_API.G_FALSE,
         p_active_instance_only  => FND_API.G_TRUE,
         x_instance_header_tbl   => l_instance_header_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);


        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        If l_instance_header_tbl.COUNT > 0 then
            l_instance_header_rec := l_instance_header_tbl(1);
        end if;

       l_instance_rec.instance_id           := l_instance_header_rec.instance_id;
       l_instance_rec.object_version_number := l_instance_header_rec.object_version_number;

       --Call get_trx_rec
       get_trx_rec(p_api_version      => p_api_version,
                   p_init_msg_list    => p_init_msg_list,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_cle_id           => srl_num_to_exp_rec.ib_cle_id,
                   p_transaction_type => G_IB_BKNG_TXN_TYPE,
                   x_trx_rec          => l_transaction_rec);

       --okl_debug_pub.logmessage('get_trx_rec  x_return_status = ' || x_return_status);
       --dbms_output.put_line('get_trx_rec  x_return_status = ' || x_return_status);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       csi_item_instance_pub.expire_item_instance
                   (
                    p_api_version           => p_api_version
                   ,p_commit                => fnd_api.g_false
                   ,p_init_msg_list         => p_init_msg_list
                   ,p_validation_level      => fnd_api.g_valid_level_full
                   ,p_instance_rec          => l_instance_rec
                   ,p_expire_children       => fnd_api.g_false
                   ,p_txn_rec               => l_transaction_rec
                   ,x_instance_id_lst       => l_upd_instance_id_lst
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data);

       --okl_debug_pub.logmessage('csi_item_instance_pub.expire_item_instance x_return_status= ' || x_return_status);
       --dbms_output.put_line('csi_item_instance_pub.expire_item_instance x_return_status= ' || x_return_status);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --okl_debug_pub.logmessage('Abandon Instance line: '||srl_num_to_exp_rec.inst_cle_id);
       --dbms_output.put_line('Abandon Instance line: '||srl_num_to_exp_rec.inst_cle_id);

       l_clev_rec.id := srl_num_to_exp_rec.inst_cle_id;
       l_klev_rec.id := srl_num_to_exp_rec.inst_cle_id;
       l_clev_rec.sts_code := 'ABANDONED';

       okl_contract_pub.update_contract_line(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_clev_rec      => l_clev_rec,
                                               p_klev_rec      => l_klev_rec,
                                               x_clev_rec      => x_clev_rec,
                                               x_klev_rec      => x_klev_rec
                                              );

       --okl_debug_pub.logmessage('okl_contract_pub.update_contract_line x_return_status= ' || x_return_status);
       --dbms_output.put_line('okl_contract_pub.update_contract_line x_return_status= ' || x_return_status);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --okl_debug_pub.logmessage('Abandon IB line: '||srl_num_to_exp_rec.ib_cle_id);
       --dbms_output.put_line('Abandon IB line: '||srl_num_to_exp_rec.ib_cle_id);

       l_clev_rec.id := srl_num_to_exp_rec.ib_cle_id;
       l_klev_rec.id := srl_num_to_exp_rec.ib_cle_id;
       l_clev_rec.sts_code := 'ABANDONED';

       okl_contract_pub.update_contract_line(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_clev_rec      => l_clev_rec,
                                               p_klev_rec      => l_klev_rec,
                                               x_clev_rec      => x_clev_rec,
                                               x_klev_rec      => x_klev_rec
                                              );

       --okl_debug_pub.logmessage('okl_contract_pub.update_contract_line x_return_status= ' || x_return_status);
       --dbms_output.put_line('okl_contract_pub.update_contract_line x_return_status= ' || x_return_status);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     END LOOP;

     -- Sync New IB instances added

     FOR srl_num_to_add_rec IN srl_num_to_add_csr(p_orig_fin_ast_cle_id => l_orig_fin_ast_cle_id,
                                                  p_rbk_fin_ast_cle_id  => p_rbk_fin_ast_cle_id,
                                                  p_orig_chr_id         => l_orig_k_id,
                                                  p_rbk_chr_id          => p_rbk_chr_id) LOOP

       --okl_debug_pub.logmessage('Add IB Instance');
       --dbms_output.put_line('Add IB Instance');

       --okl_debug_pub.logmessage('srl_num_to_add_rec.orig_ib_cle_id  = ' || srl_num_to_add_rec.orig_ib_cle_id);
       --dbms_output.put_line('srl_num_to_add_rec.orig_ib_cle_id  = ' || srl_num_to_add_rec.orig_ib_cle_id);

       --okl_debug_pub.logmessage('srl_num_to_add_rec.orig_inst_cle_id  = ' || srl_num_to_add_rec.orig_inst_cle_id);
       --dbms_output.put_line('srl_num_to_add_rec.orig_inst_cle_id  = ' || srl_num_to_add_rec.orig_inst_cle_id);

       Process_IB_Line_1(p_api_version      => p_api_version,
                         p_init_msg_list    => p_init_msg_list,
	                   x_return_status    => x_return_status,
	                   x_msg_count        => x_msg_count,
	                   x_msg_data         => x_msg_data,
                         p_chrv_id          => l_orig_k_id,
                         p_inst_cle_id      => srl_num_to_add_rec.orig_inst_cle_id,
                         p_ib_cle_id        => srl_num_to_add_rec.orig_ib_cle_id,
                         x_party_tbl        => l_party_tbl,
                         x_party_account    => l_party_account,
                         x_inv_mstr_org_id  => l_inv_mstr_org_id,
                         x_model_line_qty   => l_model_line_qty,
                         x_primary_uom_code => l_primary_uom_code,
                         x_inv_org_id       => l_orig_inv_org_id);

        --dbms_output.put_line('After Process_Line_1 '||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  	    RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        Process_IB_Line_2(p_api_version         => p_api_version,
                          p_init_msg_list       => p_init_msg_list,
	                    x_return_status       => x_return_status,
	                    x_msg_count           => x_msg_count,
	                    x_msg_data            => x_msg_data,
                          p_chrv_id             => l_orig_k_id,
                          p_inst_cle_id         => srl_num_to_add_rec.orig_inst_cle_id,
                          p_ib_cle_id           => srl_num_to_add_rec.orig_ib_cle_id,
                          p_party_tbl           => l_party_tbl,
                          p_party_account       => l_party_account,
                          p_inv_mstr_org_id     => l_inv_mstr_org_id,
                          p_model_line_qty      => l_model_line_qty,
                          p_uom_code            => l_primary_uom_code,
                          p_trx_type            => 'CFA',
                          p_inv_org_id          => l_orig_inv_org_id,
                          p_rbk_ib_cle_id       => srl_num_to_add_rec.rbk_ib_cle_id,
                          x_cimv_rec            => l_cimv_rec);
        --dbms_output.put_line('After Process_Line_1 '||x_return_status);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
  	    RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
     END LOOP;
     END IF;

       IF l_rbk_serialized = OKL_API.G_FALSE THEN --- not serialized
         --okl_debug_pub.logmessage(' l_serialized  is false -> is not serialized' );
         --dbms_output.put_line(' l_serialized  is false -> is not serialized');

         Open ib_line_csr(l_orig_k_id,l_orig_fin_ast_cle_id);
         Fetch ib_line_csr into ib_line_id,ib_line_cle_id;
         If ib_line_csr%NOTFOUND then
              null; --should not happen
         End If;
         CLose ib_line_csr;

         --okl_debug_pub.logmessage(' ib_line_id = ' ||ib_line_id );
         --dbms_output.put_line(' ib_line_id = ' ||ib_line_id);
         --okl_debug_pub.logmessage(' ib_line_cle_id = ' ||ib_line_cle_id );
         --dbms_output.put_line(' ib_line_cle_id = ' ||ib_line_cle_id);

         -- get the instance - id
         Open get_instance_id_csr(ib_line_id);
         Fetch get_instance_id_csr into l_instance_id;
         If get_instance_id_csr%NOTFOUND then
              null; --should not happen
         End If;
         Close get_instance_id_csr;

         --okl_debug_pub.logmessage(' instance id = ' || l_instance_id );
         --dbms_output.put_line(' instance id = ' || l_instance_id);

         Open ib_line_csr(p_rbk_chr_id,p_rbk_fin_ast_cle_id);
         Fetch ib_line_csr into rbk_ib_line_id,rbk_ib_line_cle_id;
         If ib_line_csr%NOTFOUND then
              null; --should not happen
         End If;
         CLose ib_line_csr;

         l_instance_query_rec.instance_id  :=  to_number(l_instance_id);

         csi_item_instance_pub.get_item_instances (
            p_api_version           => p_api_version,
            p_commit                => FND_API.G_FALSE,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            p_instance_query_rec    => l_instance_query_rec,
            p_party_query_rec       => l_party_query_rec,
            p_account_query_rec     => l_account_query_rec,
            p_transaction_id        => NULL,
            p_resolve_id_columns    => FND_API.G_FALSE,
            p_active_instance_only  => FND_API.G_TRUE,
            x_instance_header_tbl   => l_instance_header_tbl,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);


         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         If l_instance_header_tbl.COUNT > 0 then
             l_instance_header_rec := l_instance_header_tbl(1);
         end if;

         l_upd_instance_rec.instance_id           := l_instance_header_rec.instance_id;
         l_upd_instance_rec.object_version_number := l_instance_header_rec.object_version_number;
         l_upd_instance_rec.quantity              := l_rbk_model_line_qty;

         --get trx record
         get_trx_rec(p_api_version      => p_api_version,
                     p_init_msg_list    => p_init_msg_list,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     p_cle_id           => ib_line_id,
                     p_transaction_type => G_IB_BKNG_TXN_TYPE,
                     x_trx_rec          => l_upd_txn_rec);

         --okl_debug_pub.logmessage(' get_trx_rec  x_return_status= ' || x_return_status);
         --dbms_output.put_line(' get_trx_rec  x_return_status= ' || x_return_status);

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         csi_item_instance_pub.update_item_instance
                      (
                       p_api_version           => p_api_version
                      ,p_commit                => fnd_api.g_false
                      ,p_init_msg_list         => p_init_msg_list
                      ,p_validation_level      => fnd_api.g_valid_level_full
                      ,p_instance_rec          => l_upd_instance_rec
                      ,p_ext_attrib_values_tbl => l_upd_ext_attrib_values_tbl
                      ,p_party_tbl             => l_upd_party_tbl
                      ,p_account_tbl           => l_upd_account_tbl
                      ,p_pricing_attrib_tbl    => l_upd_pricing_attrib_tbl
                      ,p_org_assignments_tbl   => l_upd_org_assignments_tbl
                      ,p_asset_assignment_tbl  => l_upd_asset_assignment_tbl
                      ,p_txn_rec               => l_upd_txn_rec
                      ,x_instance_id_lst       => l_upd_instance_id_lst
                      ,x_return_status         => x_return_status
                      ,x_msg_count             => x_msg_count
                      ,x_msg_data              => x_msg_data
                      );
       --serialized
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

      IF l_rbk_serialized = OKL_API.G_TRUE THEN
        -- Sync Serial Numbers
        FOR srl_num_to_update_rec IN srl_num_to_update_csr(p_orig_fin_ast_cle_id => l_orig_fin_ast_cle_id,
                                                           p_rbk_fin_ast_cle_id  => p_rbk_fin_ast_cle_id,
                                                           p_orig_chr_id         => l_orig_k_id,
                                                           p_rbk_chr_id          => p_rbk_chr_id) LOOP


          l_srl_num_old_rec := NULL;
          OPEN srl_num_old_csr(p_instance_id => srl_num_to_update_rec.instance_id);
          FETCH srl_num_old_csr INTO l_srl_num_old_rec;
          CLOSE srl_num_old_csr;

          l_srl_num_new_rec := NULL;
          OPEN srl_num_new_csr(p_rbk_fin_ast_cle_id => p_rbk_fin_ast_cle_id,
                               p_rbk_ib_cle_id      =>  srl_num_to_update_rec.rbk_ib_cle_id);
          FETCH srl_num_new_csr INTO l_srl_num_new_rec;
          CLOSE srl_num_new_csr;

          IF NVL(l_srl_num_old_rec.serial_number,OKL_API.G_MISS_CHAR) <>
             NVL(l_srl_num_new_rec.serial_number,OKL_API.G_MISS_CHAR) THEN

            --okl_debug_pub.logmessage('Update IB Instance');
            --dbms_output.put_line('Update IB Instance');

            --okl_debug_pub.logmessage('srl_num_to_update_rec.orig_ib_cle_id  = ' || srl_num_to_update_rec.orig_ib_cle_id);
            --dbms_output.put_line('srl_num_to_update_rec.orig_ib_cle_id  = ' || srl_num_to_update_rec.orig_ib_cle_id);

            l_instance_query_rec := l_instance_query_temp_rec;
            l_instance_header_rec := l_instance_header_temp_rec;
            l_upd_instance_rec := l_instance_temp_rec;

            l_instance_query_rec.instance_id  :=  srl_num_to_update_rec.instance_id;

            csi_item_instance_pub.get_item_instances (
              p_api_version           => p_api_version,
              p_commit                => FND_API.G_FALSE,
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
              p_instance_query_rec    => l_instance_query_rec,
              p_party_query_rec       => l_party_query_rec,
              p_account_query_rec     => l_account_query_rec,
              p_transaction_id        => NULL,
              p_resolve_id_columns    => FND_API.G_FALSE,
              p_active_instance_only  => FND_API.G_TRUE,
              x_instance_header_tbl   => l_instance_header_tbl,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);


            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            If l_instance_header_tbl.COUNT > 0 then
               l_instance_header_rec := l_instance_header_tbl(1);
   end if;

               l_upd_instance_rec.instance_id           := l_instance_header_rec.instance_id;
            l_upd_instance_rec.object_version_number := l_instance_header_rec.object_version_number;
            l_upd_instance_rec.serial_number         := l_srl_num_new_rec.serial_number;

            --Call get_trx_rec
            get_trx_rec(p_api_version      => p_api_version,
                        p_init_msg_list    => p_init_msg_list,
                        x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_cle_id           => srl_num_to_update_rec.orig_ib_cle_id,
                        p_transaction_type => G_IB_BKNG_TXN_TYPE,
                        x_trx_rec          => l_upd_txn_rec);

            --okl_debug_pub.logmessage('get_trx_rec  x_return_status = ' || x_return_status);
            --dbms_output.put_line('get_trx_rec  x_return_status = ' || x_return_status);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            csi_item_instance_pub.update_item_instance
            (
              p_api_version           => p_api_version
             ,p_commit                => fnd_api.g_false
             ,p_init_msg_list         => p_init_msg_list
             ,p_validation_level      => fnd_api.g_valid_level_full
             ,p_instance_rec          => l_upd_instance_rec
             ,p_ext_attrib_values_tbl => l_upd_ext_attrib_values_tbl
             ,p_party_tbl             => l_upd_party_tbl
             ,p_account_tbl           => l_upd_account_tbl
             ,p_pricing_attrib_tbl    => l_upd_pricing_attrib_tbl
             ,p_org_assignments_tbl   => l_upd_org_assignments_tbl
             ,p_asset_assignment_tbl  => l_upd_asset_assignment_tbl
             ,p_txn_rec               => l_upd_txn_rec
             ,x_instance_id_lst       => l_upd_instance_id_lst
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
            );

            --okl_debug_pub.logmessage('csi_item_instance_pub.update_item_instance 2 x_return_status= ' || x_return_status);
            --dbms_output.put_line('csi_item_instance_pub.update_item_instance 2 x_return_status= ' || x_return_status);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

          END IF;
        END LOOP;
      END IF;

    -- gboomina Bug 5362977 - End
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
    When OKL_API.G_EXCEPTION_ERROR Then
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
        (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
        );
    WHEN OTHERS THEN
        x_return_status :=OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  END RBK_SRL_NUM_IB_INSTANCE;

End OKL_ACTIVATE_IB_PVT;

/
