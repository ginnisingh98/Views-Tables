--------------------------------------------------------
--  DDL for Package Body OKS_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CHANGE_STATUS_PVT" as
/* $Header: OKSVCSTB.pls 120.27.12010000.4 2010/01/13 11:22:18 cgopinee ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := 'OKS';
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKS_CHANGE_STATUS_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'oks.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKS';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  g_api_version                 constant number :=1;
  g_init_msg_list varchar2(1) := 'T';
  g_msg_count NUMBER;
  g_msg_data varchar2(240);
  p_count number := 0;
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

/*
**  This procedure accepts contract_id and the new_sts_code and
**  changes the status the Contract, the lines and sub-lines are
**  also updated to the same status.
**  If the Contract has to be Cancelled then the source for the
**  cancel action needs to be passed (i.e, MANUAL or IBTRANSFER). -- made change from 'TRANSFER' to 'IBTRANSFER'
**  In cancellation case the amount for the Header and Lines is
**  updated to reflect the cancel action.
*/

procedure Update_header_status(x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               p_init_msg_list       in  varchar2,
                               p_id                 in number,
                               p_new_sts_code       in varchar2,
                               p_canc_reason_code   in varchar2,
                               p_old_sts_code       in varchar2,
                               p_comments           in varchar2,
                               p_term_cancel_source in varchar2,
                               p_date_cancelled     in date,
                               p_validate_status    in varchar2) is


l_chr_id            number;
l_new_ste_code      varchar2(30);
l_old_ste_code      varchar2(30);
l_old_sts_code      varchar2(30);
l_chrv_tbl          chrv_tbl_type;
l_new_sts_code      varchar2(30);
l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_HEADER_STATUS';

begin

OKC_CVM_PVT.clear_g_transaction_id; /*Added for bug6418582*/

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '100: Entered UPDATE_HEADER_STATUS');
  END IF;

  if ((p_new_sts_code is NULL) OR (p_id is null) OR (p_canc_reason_code is NULL)) then
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_init_msg_list = FND_API.G_TRUE) then
     fnd_msg_pub.initialize();
  end if;

  l_new_sts_code := p_new_sts_code;
  l_old_sts_code := p_old_sts_code;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '110: Parameter Values ' ||
                            'contract_id - '|| p_id ||
                            'new_sts_code - '||l_new_sts_code ||
                            'old_sts_code - '||l_old_sts_code );
  END IF;

  OKS_CHANGE_STATUS_PVT.check_allowed_status(x_return_status => x_return_status,
                                             x_msg_count    => x_msg_count,
                                             x_msg_data     => x_msg_data,
                                             p_id           => p_id,
                                             p_old_sts_code => l_old_sts_code,
                                             p_new_sts_code => p_new_sts_code,
                                             p_old_ste_code => l_old_ste_code,
                                             p_new_ste_code => l_new_ste_code,
                                             p_cle_id       => NULL);


  if (x_return_status = FND_API.G_RET_STS_ERROR) then
    raise FND_API.G_EXC_ERROR;
  elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '120: Completed check_allowed_status() ');
  END IF;

  l_chrv_tbl(1).id := p_id;
  l_chrv_tbl(1).old_sts_code := l_old_sts_code;
  l_chrv_tbl(1).old_ste_code := l_old_ste_code;
  l_chrv_tbl(1).new_sts_code := l_new_sts_code;
  l_chrv_tbl(1).new_ste_code := l_new_ste_code;

  if (l_new_ste_code = 'CANCELLED') then
      l_chrv_tbl(1).datetime_cancelled := p_date_cancelled;
      l_chrv_tbl(1).trn_code := p_canc_reason_code;
      l_chrv_tbl(1).term_cancel_source := p_term_cancel_source;
  elsif (l_new_ste_code = 'ENTERED') then
      l_chrv_tbl(1).datetime_cancelled := NULL;
      l_chrv_tbl(1).trn_code := NULL;
      l_chrv_tbl(1).term_cancel_source := NULL;
  end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '130: Calling Update_Header_status with chrv_tbl populated');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '140: l_chrv_tbl(1).id '|| l_chrv_tbl(1).id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '150: l_chrv_tbl(1).old_sts_code '|| l_chrv_tbl(1).old_sts_code);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '160: l_chrv_tbl(1).new_sts_code '|| l_chrv_tbl(1).new_sts_code);
  END IF;

  Update_header_status( x_return_status => x_return_status,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_chrv_tbl => l_chrv_tbl,
                        p_canc_reason_code => p_canc_reason_code,
                        p_comments => p_comments,
                        p_term_cancel_source => p_term_cancel_source,
                        p_date_cancelled => p_date_cancelled);

  if (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  elsif (x_return_status = FND_API.G_RET_STS_ERROR) then
    raise FND_API.G_EXC_ERROR;
  end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '170: Completed Update_header_status succesfully');
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

Exception
 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'180: Leaving OKS_CHANGE_STATUS_PVT, one or more mandatory parameters missing :FND_API.G_EXC_ERROR');
      END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'190: Leaving OKS_CHANGE_STATUS_PVT: FND_API.G_EXC_UNEXPECTED_ERROR '|| SQLERRM);
      END IF;

 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'200: Leaving OKS_CHANGE_STATUS_PVT because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
end;

/*
** This procedure accepts multiple contracts for status change.
** The plsql table chrv_tbl should be passed to the API containing
** the contract which needs status change.
*/
procedure Update_header_status(x_return_status     OUT NOCOPY VARCHAR2,
                               x_msg_data          OUT NOCOPY VARCHAR2,
                               x_msg_count         OUT NOCOPY NUMBER,
                               p_init_msg_list      in varchar2,
                               p_chrv_tbl           in OUT NOCOPY chrv_tbl_type,
                               p_canc_reason_code   in varchar2,
                               p_comments           in varchar2,
                               p_term_cancel_source in varchar2,
                               p_date_cancelled     in date,
                               p_validate_status    in varchar2) is

p_control_rec           okc_util.okc_control_rec_type;
l_chrv_tbl              chrv_tbl_type;
l_new_ste_code          varchar2(30);
l_old_ste_code          varchar2(30);
l_ste_code1             varchar2(30);
l_return_status         boolean;
l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_HEADER_STATUS';
l_line_update               varchar2(1);
i                       number := 0;
l_return_status             boolean;
l_cle_id                number := NULL;
l_chr_id                number;
l_init_msg_list         varchar2(1) := 'N';
l_wf_attr_details       wf_attr_details;
l_wf_item_key           oks_k_headers_b.wf_item_key%type;
l_valid_flag            varchar2(1) := 'Y';

CURSOR csr_k_item_key(p_contract_id in number) IS
SELECT wf_item_key
  FROM oks_k_headers_b
WHERE chr_id = p_contract_id;

begin
p_count := p_chrv_tbl.count;

if (p_init_msg_list = FND_API.G_TRUE) then
    fnd_msg_pub.initialize();
end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '400: Entere Update_Header_Status');
  END IF;

for i in p_chrv_tbl.first .. p_chrv_tbl.last
Loop
    populate_table(p_chrv_tbl, i); -- p_chrv_tbl;

  if (p_chrv_tbl(i).new_ste_code = 'CANCELLED') then
      p_chrv_tbl(i).datetime_cancelled := p_date_cancelled;
      p_chrv_tbl(i).trn_code := p_canc_reason_code;
      p_chrv_tbl(i).term_cancel_source := p_term_cancel_source;
  elsif (p_chrv_tbl(i).new_ste_code = 'ENTERED') then
      p_chrv_tbl(i).datetime_cancelled := NULL;
      p_chrv_tbl(i).trn_code := NULL;
      p_chrv_tbl(i).term_cancel_source := NULL;
  end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '410: Calling validate_Status p_chrv_tbl(i).id - '||p_chrv_tbl(i).id);
  END IF;

    if (p_validate_status = 'Y') then
     Begin
       Validate_Status(x_return_status,
                       x_msg_count,
                       x_msg_data,
                       p_chrv_tbl(i).id,
                       p_chrv_tbl(i).new_ste_code,
                       p_chrv_tbl(i).old_ste_code,
                       p_chrv_tbl(i).new_sts_code,
                       p_chrv_tbl(i).old_sts_code,
                       l_cle_id,
                       p_validate_status);

       if (x_return_status = FND_API.G_RET_STS_ERROR) then
          raise FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
       l_valid_flag := 'Y';

      EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        l_valid_flag := 'N';
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name, FND_MSG_PUB.Get('F', 1));
         END IF;
      End;
     end if; -- p_validate_status

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '420: l_valid_flag - '|| l_valid_flag );
     END IF;

     if l_valid_flag = 'Y' then
      p_control_rec.flag         := 'Y';
      p_control_rec.code         := p_canc_reason_code;
      p_control_rec.comments := p_comments;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '430: calling okc_contract_pub.update_contract_header');
     END IF;

--bug 5710909
-- Added the following code to place a lock on contract header.
okc_contract_pub.lock_contract_header(
      		 		p_api_version                  =>     1.0,
     		 		p_init_msg_list                =>     'T',
    				x_return_status                =>     x_return_status,
    				x_msg_count                    =>     g_msg_count,
    				x_msg_data                     =>     g_msg_data,
    				p_chrv_rec                     =>     p_chrv_tbl(i));

       if (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) Then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_ERROR) Then
            RAISE FND_API.G_EXC_ERROR;
        end if;

--end of 5710909

      OKC_CONTRACT_PUB.update_contract_header(
        p_api_version           => g_api_version,
        P_INIT_MSG_LIST         => 'F',
        x_return_status         => x_return_status,
        x_msg_count             => g_msg_count,
        x_msg_data              => g_msg_data,
        p_restricted_update     => 'T',
        p_chrv_rec              => p_chrv_tbl(i),
        p_control_rec           => p_control_rec,
        x_chrv_rec              => l_chrv_tbl(i));


        if (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) Then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_ERROR) Then
            RAISE FND_API.G_EXC_ERROR;
        end if;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '440: Calling oks_change_status_pvt.update_line_status ');
     END IF;

     --   cgopinee bugfix for 9259068
     IF (p_chrv_tbl(i).new_sts_code<>p_chrv_tbl(i).old_sts_code) THEN
         OKS_CHANGE_STATUS_PVT.G_HEADER_STATUS_CHANGED :='Y';
     END if;

     OKS_CHANGE_STATUS_PVT.update_line_status(
                        x_return_status => x_return_status,
                        x_msg_data => x_msg_data,
                        x_msg_count => x_msg_count,
                        p_init_msg_list => l_init_msg_list,
                        p_id => p_chrv_tbl(i).id,
                        p_cle_id => l_cle_id,
                        p_new_sts_code => p_chrv_tbl(i).new_sts_code,
                        p_canc_reason_code => p_canc_reason_code,
                        p_old_sts_code => p_chrv_tbl(i).old_sts_code,
                        p_old_ste_code => p_chrv_tbl(i).old_ste_code,
                        p_new_ste_code => p_chrv_tbl(i).new_ste_code,
                        p_term_cancel_source => p_term_cancel_source,
                        p_date_cancelled => p_date_cancelled,
                        p_comments => p_comments,
                        p_validate_status => 'N');

    If (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    elsIf (x_return_status = FND_API.G_RET_STS_ERROR) then
        RAISE FND_API.G_EXC_ERROR;
    End if;

    -- Call API for Cleaning the Renewal links which are due to
    -- cancel action on the contract.
    if (p_chrv_tbl(i).old_ste_code = 'ENTERED' and p_chrv_tbl(i).new_ste_code = 'CANCELLED') then

       -- Check if the contract is a renewed contract
       IF (Renewed_YN(p_chrv_tbl(i).id)) then
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                '450: Calling okc_contract_pvt.clean_ren_links, Entered => Canceled ');
         END IF;

         OKC_CONTRACT_PVT.CLEAN_REN_LINKS(p_target_chr_id => p_chrv_tbl(i).id,
                                         p_api_version   => g_api_version,
                                         p_init_msg_list => 'F',
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data);

         if (x_return_status = FND_API.G_RET_STS_ERROR) then
             Raise FND_API.G_EXC_ERROR;
         elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
             Raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
       END IF; -- Renewed_YN

     -- Abort the Renewal workflow process as the contract is getting
     -- cancelled.
        open csr_k_item_key(p_chrv_tbl(i).id);
        fetch csr_k_item_key into l_wf_item_key;
        close csr_k_item_key;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '460: Calling oks_wf_k_process_pvt.cancel_contract
                                        for l_wf_item_key - ' || l_wf_item_key);
     END IF;

-- Changed by MKS/SKK
        OKS_WF_K_PROCESS_PVT.cancel_contract
            (
              p_api_version          => 1.0,
              p_init_msg_list        => 'F',
              p_contract_id          => p_chrv_tbl(i).id,
              p_item_key             => l_wf_item_key,
              p_cancellation_reason  => p_canc_reason_code,
              p_cancellation_date    => p_date_cancelled,
              p_cancel_source        => p_term_cancel_source,
              p_comments             => p_comments,
              x_return_status        => x_return_status,
              x_msg_count            => x_msg_count,
              x_msg_data             => x_msg_data);

        if (x_return_status = FND_API.G_RET_STS_ERROR) then
            Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

-- End of Changed by MKS/SKK
        elsif (p_chrv_tbl(i).old_ste_code = 'CANCELLED' and p_chrv_tbl(i).new_ste_code = 'ENTERED') then

          -- Check if the contract is renewed
          IF (Renewed_YN(p_chrv_tbl(i).id)) then
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                '470: okc_contract_pvt.relink_renew, Canceled => Entered ');
            END IF;
            -- Reinstantiate the renewal link as the contract is getting into 'Entererd' status

              OKC_CONTRACT_PVT.RELINK_RENEW(p_target_chr_id   => p_chrv_tbl(i).id,
                                     p_api_version         => g_api_version,
                                     P_INIT_MSG_LIST   => 'F',
                                     x_return_status   => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data);

              if (x_return_status = FND_API.G_RET_STS_ERROR) then
                Raise FND_API.G_EXC_ERROR;
              elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

         END IF; -- Renewed_YN

        -- if the above call is succesful then reinstantiate the renewal workflow process

-- Changed by MKS/SKK
        l_wf_attr_details.CONTRACT_ID := l_chrv_tbl(i).id;
        l_wf_attr_details.NEGOTIATION_STATUS := 'DRAFT';
        l_wf_attr_details.PROCESS_TYPE := 'MANUAL';
        l_wf_attr_details.IRR_FLAG := 'Y';
--
-- MKS: Commented below as we want wf launch process to generate the id AND update the oks_k_headers table with the item key and
-- Negotiation Status
--
--        l_wf_attr_details.ITEM_KEY := l_chrv_tbl(i).id || to_char(sysdate, 'YYYYMMDDHH24MISS');

-- End of Changed by MKS/SKK

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '480: Launching workflow process ');
     END IF;

        OKS_WF_K_PROCESS_PVT.launch_k_process_wf (
                     p_api_version          => 1.0,
                     p_init_msg_list        => 'F',
                     p_wf_attributes        => l_wf_attr_details,
                     x_return_status        => x_return_status,
                     x_msg_count            => x_msg_count,
                     x_msg_data             => x_msg_data);

        if (x_return_status = FND_API.G_RET_STS_ERROR) then
            Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        end if;
    end if; -- l_validate_flag
  end loop;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                          '485: exiting Update_header_status ');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'490: Leaving OKS_CHANGE_STATUS_PVT: FND_API.G_EXC_ERROR');
      END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving OKS_CHANGE_STATUS_PVT: FND_API.G_EXC_UNEXPECTED_ERROR '||SQLERRM);
      END IF;

 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'510: Leaving OKS_CHANGE_STATUS_PVT because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
end;


PROCEDURE populate_table(x_chrv_tbl in out NOCOPY chrv_tbl_type, i in number) IS
    l_object_version_number     NUMBER;
    l_new_sts_code              VARCHAR2(100);

     CURSOR c_obj_ver(p_id NUMBER) IS
     SELECT object_version_number, decode(
            NVL(sign(months_between(START_DATE,sysdate+1)),1),-1,decode(
            NVL(sign(months_between(END_DATE,sysdate-1)),1),1,'ACTIVE','EXPIRED'),'SIGNED' )
     FROM okc_k_headers_b
     WHERE id = p_id;
BEGIN
    x_chrv_tbl(i).VALIDATE_YN           := 'N';
    Open c_obj_ver(x_chrv_tbl(i).id);
    Fetch c_obj_ver Into l_object_version_number, l_new_sts_code;
    Close c_obj_ver;

    x_chrv_tbl(1).object_version_number := l_object_version_number;
    x_chrv_tbl(1).STS_CODE    := x_chrv_tbl(i).new_sts_code;

    If p_count = 1 Then
       x_chrv_tbl(i).STS_CODE    := x_chrv_tbl(i).new_sts_code;
    Else
       If x_chrv_tbl(i).old_ste_code  = 'HOLD' Then  -- old sts cdoe
          If x_chrv_tbl(i).new_ste_code IN ('ACTIVE', 'SIGNED', 'EXPIRED') Then -- new ste code
              x_chrv_tbl(i).STS_CODE :=l_new_sts_code;
          End If;
       End If;
    End If;

END;

-- This procedure validates the status change and throws error
-- if the status change is not allowed due to Renewal links.

procedure VALIDATE_STATUS(x_return_status   OUT NOCOPY varchar2,
                          x_msg_count       OUT NOCOPY number,
                          x_msg_data        OUT NOCOPY varchar2,
                          p_id              in number,
                          p_new_ste_code    in varchar2,
                          p_old_ste_code    in varchar2,
                          p_new_sts_code    in varchar2,
                          p_old_sts_code    in varchar2,
                          p_cle_id          in number,
                          p_validate_status  in varchar2
                         )
 is
  l_chr_id            number := p_id;
  l_validate          varchar2(1) := 'Y';
  l_return_status     varchar2(1);
  l_api_name         varchar2(100) := 'Validate Status';
begin
      IF RENEWED_YN(l_chr_id) THEN
        -- Changing from 'Canceled' to 'Entered' Status
        If p_old_ste_code ='CANCELLED'  and p_new_ste_code = 'ENTERED' then
            If target_exists(l_chr_id, p_cle_id) then
                If Is_Entered(l_chr_id, p_cle_id) then
                        fnd_message.set_name('OKC', 'OKC_CONT_CAN_ENT_1');
                        fnd_message.set_token('PARENT_K',get_source_list(l_chr_id, p_cle_id));
                        fnd_message.set_token('RENEW_K',get_target_list(l_chr_id, p_cle_id));
                        fnd_msg_pub.add;
                        Raise FND_API.G_EXC_ERROR;
                Elsif Is_Not_Entered_Cancelled(l_chr_id, p_cle_id) then
                            l_validate := 'N';
                        fnd_message.set_name('OKC', 'OKC_CONT_CAN_ENT_2');
                        fnd_message.set_token('PARENT_K',get_source_list(l_chr_id, p_cle_id));
                        fnd_message.set_token('RENEW_K',get_target_list(l_chr_id, p_cle_id));
                        fnd_msg_pub.add;
                        Raise FND_API.G_EXC_ERROR;
                Else
                        fnd_message.set_name('OKC', 'OKC_CONT_CAN_ENT_3');
                        fnd_message.set_token('PARENT_K',get_source_list(l_chr_id, p_cle_id));
                        fnd_msg_pub.add;
                        Raise OKC_API.G_EXC_WARNING;
                End If; -- Is_entered
        -- Even if any other target contract does not exist, the contract is still being resurrected
         Else  -- target_exists
              fnd_message.set_name('OKC', 'OKC_CONT_CAN_ENT_3');
              fnd_message.set_token('PARENT_K',get_source_list(l_chr_id,p_cle_id));
              fnd_msg_pub.add;
              Raise OKC_API.G_EXC_WARNING;
         End If;  -- target_exists
      End If; -- p_cancelled to entered
    END IF; -- Renewed_YN

-- This should be only for mass status change need to put if clause
     If (p_old_sts_code = 'QA_HOLD') OR (p_old_sts_code = p_new_sts_code) Then
        x_return_status := FND_API.G_RET_STS_ERROR;
     End If;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
------------------------------
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving OKS_CHANGE_STATUS_PVT : FND_API.G_EXC_ERROR');
      END IF;
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'310: Leaving OKS_CHANGE_STATUS_PVT : FND_API.G_EXC_UNEXPECTED_ERROR '||SQLERRM);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN OKC_API.G_EXC_WARNING THEN
      x_return_status := OKC_API.G_RET_STS_WARNING;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'320: Leaving OKS_CHANGE_STATUS_PVT : OKC_API.G_EXC_WARNING');
      END IF;

 WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'330: Leaving OKS_CHANGE_STATUS_PVT  because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
end;

function RENEWED_YN(p_id in number) return boolean is
  l_chr_id            number := p_id;
  l_renewed           varchar2(1):= 'N';
begin
 select 'Y'
   into l_renewed
   from okc_operation_instances OIE,
        okc_class_operations COP
  where OIE.cop_id=COP.id
    and COP.opn_code in ('RENEWAL', 'REN_CON')
    and target_chr_id = l_chr_id
    and rownum = 1;
--
 if l_renewed = 'Y' then
   return(TRUE);
 else
   return(FALSE);
 end if;
 exception
   when no_data_found then
    return(FALSE);
end;
--

function get_source_list(p_id in number, p_cle_id in number) return varchar2 is
  l_chr_id            number := p_id;
  l_source_chr        varchar2(1000);

-- building a list of source contract for the renewed contract being resurrected
cursor C1 is
     select distinct contract_number, contract_number_modifier,
            contract_number||decode(contract_number_modifier, NULL,'','-'||contract_number_modifier) contracts
       from okc_k_headers_b CHR,
            okc_operation_lines OLI,
            okc_operation_instances OIE,             --**
            okc_class_operations    COP              --**
      where OLI.subject_chr_id = l_chr_id
        and OLI.object_chr_id = chr.id
        and OLI.oie_id = OIE.id                     --**
        and OIE.cop_id = COP.id                     --**
        and COP.opn_code in ('RENEWAL', 'REN_CON')  --**
        and OLI.subject_cle_id > 0;

-- Line Level Check, introduced for LLC

Cursor C2 is
     select contract_number, contract_number_modifier,
            contract_number||decode(contract_number_modifier, NULL,'','-'||contract_number_modifier) contracts
       from okc_k_headers_b CHR,
            okc_operation_lines OLI,
            okc_operation_instances OIE,             --**
            okc_class_operations    COP              --**
      where OLI.subject_chr_id = l_chr_id
        and OLI.subject_cle_id = p_cle_id
        and OLI.object_chr_id = chr.id
        and OLI.oie_id = OIE.id                     --**
        and OIE.cop_id = COP.id                     --**
        and COP.opn_code in ('RENEWAL', 'REN_CON')  --**
        and OLI.subject_cle_id > 0;
begin
if (p_cle_id is NULL) then
  for C1_rec in C1 loop
      l_source_chr := l_source_chr||','||C1_rec.contracts;
  end loop;
else
  for C2_rec in C2 Loop
      l_source_chr := l_source_chr||','||C2_rec.contracts;
  end loop;
end if;
  return(l_source_chr);
end;
--

function get_target_list(p_id in number, p_cle_id in number) return varchar2 is
  l_chr_id            number := p_id;
  l_target_chr        varchar2(1000);

-- building list of target contracts for the same source contracts
CURSOR C1 IS
     SELECT distinct contract_number, contract_number_modifier,
            contract_number||decode(contract_number_modifier, NULL,'','-'||contract_number_modifier) contracts
       FROM okc_k_headers_b CHR,
            okc_operation_lines OLI1,
            okc_operation_lines OLI2,
            okc_operation_instances OIE1,
            okc_class_operations    COP1,
            okc_operation_instances OIE2,
            okc_class_operations    COP2
      WHERE CHR.id = OLI1.subject_chr_id
        and OLI1.object_chr_id = OLI2.object_chr_id
        and OLI1.oie_id = OIE1.id
        and OIE1.cop_id = COP1.id
        and COP1.opn_code in ('RENEWAL', 'REN_CON')
        and OLI2.oie_id = OIE2.id
        and OIE2.cop_id = COP2.id
        and COP2.opn_code in ('RENEWAL', 'REN_CON')
        and OLI2.subject_chr_id = l_chr_id
        and OLI1.subject_chr_id <> l_chr_id
        and OLI2.subject_cle_id > 0
        and OLI1.subject_cle_id > 0;
--
-- Line Level Check added as part of LLC
CURSOR C2 is
SELECT  contract_number, contract_number_modifier,
            contract_number||decode(contract_number_modifier, NULL,'','-'||contract_number_modifier) contracts
       FROM okc_k_headers_b CHR,
            okc_k_lines_b CLE,
            okc_statuses_b STE,
            okc_operation_lines OLI1,
                okc_operation_lines OLI2,
            okc_operation_instances OIE1,
            okc_class_operations    COP1,
            okc_operation_instances OIE2,
            okc_class_operations    COP2
      WHERE CHR.id = OLI1.subject_chr_id
    and OLI1.object_chr_id = OLI2.object_chr_id
    and OLI1.oie_id = OIE1.id
        and OIE1.cop_id = COP1.id
        and COP1.opn_code in ('RENEWAL', 'REN_CON')
        and OLI2.oie_id = OIE2.id
        and OIE2.cop_id = COP2.id
        and COP2.opn_code in ('RENEWAL', 'REN_CON')
        and CHR.id = CLE.dnz_chr_id
        and CLE.sts_code = STE.Code
        and STE.STE_CODE = 'ENTERED'   -- this is a retrictive condn.
        and CLE.id = OLI1.subject_cle_id
        and OLI2.subject_chr_id = l_chr_id
        and OLI1.subject_chr_id <> l_chr_id
        and OLI2.subject_cle_id = p_cle_id
        and OLI1.object_cle_id = OLI2.object_cle_id
        and OLI1.subject_cle_id <> p_cle_id;

begin
if (p_cle_id is NULL) then
  for C1_rec in C1 loop
      l_target_chr := l_target_chr||','||C1_rec.contracts;
  end loop;
else
  for C2_rec in C2 loop
      l_target_chr := l_target_chr||','||C2_rec.contracts;
  end loop;
end if;
  return(l_target_chr);
end;
--
--

function target_cancelled(p_id in Number, p_cle_id in number) return boolean is
  l_chr_id            number := p_id;
  l_cle_cncl varchar2(1);
  l_chr_cncl varchar2(1);
--
-- Following two statements will verify if all other contracts renewed using
-- the same header/lines as used for the target contract being resurected are
-- CANCELLED status (DATE_RENEWED is NULL).
--
cursor c1 is
   select distinct 'Y'
     from OKC_K_HEADERS_B CHR,
          okc_operation_lines OLI,
          okc_operation_instances OIE,
          okc_class_operations    COP
    where chr.id = oli.object_chr_id
      and OLI.oie_id = OIE.id
      and OIE.cop_id = COP.id
      and COP.opn_code in ('RENEWAL', 'REN_CON')
      and oli.subject_chr_id = l_chr_id
      and CHR.date_renewed is NOT NULL;

cursor c2 is
   select distinct 'Y'
     from OKC_K_LINES_B CLE,
          okc_operation_lines OLI,
          okc_operation_instances OIE,
          okc_class_operations    COP
    where cle.id = oli.object_cle_id
      and OLI.oie_id = OIE.id
      and OIE.cop_id = COP.id
      and COP.opn_code in ('RENEWAL', 'REN_CON')
      and oli.subject_chr_id = l_chr_id
      and Cle.date_renewed is NOT NULL;
begin
  open c1;
  fetch c1 into l_chr_cncl;
  close c1;
--
  open c1;
  fetch c1 into l_cle_cncl;
  close c1;
--
  if (l_chr_cncl = 'Y' and l_cle_cncl = 'Y') then
    return(TRUE);
  else
    return(FALSE);
  end if;
end;


function Is_Entered(p_id in Number, p_cle_id in Number) return boolean is
  l_chr_id            number := p_id;
  l_status            varchar2(1);
CURSOR c1 IS
     SELECT distinct 'Y'
       FROM okc_k_headers_b CHR,
            okc_statuses_b  STS,
            okc_operation_lines OLI1,
            okc_operation_lines OLI2,
            okc_operation_instances OIE1,             --**
            okc_class_operations    COP1,             --**
            okc_operation_instances OIE2,             --**
            okc_class_operations    COP2              --**
      WHERE CHR.id = OLI1.subject_chr_id
        and OLI1.oie_id = OIE1.id                     --**
        and OIE1.cop_id = COP1.id                     --**
        and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
        and OLI2.oie_id = OIE2.id                     --**
        and OIE2.cop_id = COP2.id                     --**
        and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
        AND OLI1.object_chr_id = OLI2.object_chr_id
        AND OLI2.subject_chr_id = l_chr_id
        AND OLI1.subject_cle_id IS NULL
        AND OLI2.subject_cle_id IS NULL
        AND CHR.sts_code = STS.code
        AND STS.ste_code = 'ENTERED'
	AND OLI1.active_yn = 'Y'
        AND OLI1.process_flag = 'P'
        AND OLI2.process_flag = 'P';

-- Line Level Check added as part of LLC

CURSOR c2 IS
   SELECT  distinct 'Y'
       FROM okc_k_headers_b CHR,
        okc_k_lines_b CLE,
            okc_statuses_b  STS,
            okc_operation_lines OLI1,
            okc_operation_lines OLI2,
            okc_operation_instances OIE1,             --**
            okc_class_operations    COP1,             --**
            okc_operation_instances OIE2,             --**
            okc_class_operations    COP2              --**
      WHERE CHR.id = OLI1.subject_chr_id
        and OLI1.oie_id = OIE1.id                     --**
        and OIE1.cop_id = COP1.id                     --**
        and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
        and OLI2.oie_id = OIE2.id                     --**
        and OIE2.cop_id = COP2.id                     --**
        and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
        AND OLI1.object_chr_id = OLI2.object_chr_id
        AND OLI2.subject_chr_id =  l_chr_id
        AND OLI1.subject_chr_id <> l_chr_id
        AND OLI1.subject_cle_id <> p_cle_id
        AND OLI2.subject_cle_id = p_cle_id
    AND CLE.sts_code = STS.code
    AND STS.ste_code <> 'ENTERED'
    AND CHR.id = CLE.DNZ_CHR_ID
    AND CLE.ID = OLI1.subject_cle_id
        AND OLI1.object_cle_id = OLI2.object_cle_id
 AND OLI1.active_yn = 'Y'
        AND OLI1.process_flag = 'P'
        AND OLI2.process_flag = 'P';
--
begin
if (p_cle_id is NULL) then
  open c1;
  fetch c1 into l_status;
  close c1;
else
  open c2;
  fetch c2 into l_status;
  close c2;
end if;

 if l_status = 'Y' then
  return(TRUE);
 else
  return(FALSE);
 end if;
end;
--
--

function Is_Not_Entered_Cancelled(p_id in Number, p_cle_id in Number) return boolean is
  l_chr_id            number := p_id;
  l_status            varchar2(1);
--
--
  CURSOR c1 IS
     SELECT distinct 'Y'
       FROM okc_k_headers_b     CHR,
            okc_statuses_b      STS,
            okc_operation_lines OLI1,
            okc_operation_lines OLI2,
            okc_operation_instances OIE1,             --**
            okc_class_operations    COP1,             --**
            okc_operation_instances OIE2,             --**
            okc_class_operations    COP2              --**
      WHERE CHR.id = OLI1.subject_chr_id
        and OLI1.oie_id = OIE1.id                     --**
        and OIE1.cop_id = COP1.id                     --**
        and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
        and OLI2.oie_id = OIE2.id                     --**
        and OIE2.cop_id = COP2.id                     --**
        and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
        AND OLI1.object_chr_id = OLI2.object_chr_id
        AND OLI2.subject_chr_id = l_chr_id
        AND OLI1.subject_cle_id IS NULL
        AND OLI2.subject_cle_id IS NULL
        AND CHR.STS_CODE = STS.CODE
        AND STS.ste_code not in ('ENTERED', 'CANCELLED')
	AND OLI1.active_yn = 'Y'
        AND OLI1.process_flag = 'P'
        AND OLI2.process_flag = 'P';
--
-- Line Level Check added as part of LLC

  CURSOR c2 IS
     SELECT distinct 'Y'
       FROM okc_k_headers_b     CHR,
        okc_k_lines_b CLE,
            okc_statuses_b      STS,
            okc_operation_lines OLI1,
            okc_operation_lines OLI2,
            okc_operation_instances OIE1,             --**
            okc_class_operations    COP1,             --**
            okc_operation_instances OIE2,             --**
            okc_class_operations    COP2              --**
      WHERE CHR.id = OLI1.subject_chr_id
        and CHR.id = CLE.dnz_chr_id
        and OLI1.oie_id = OIE1.id                     --**
        and OIE1.cop_id = COP1.id                     --**
        and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
        and OLI2.oie_id = OIE2.id                     --**
        and OIE2.cop_id = COP2.id                     --**
        and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
        AND OLI1.object_chr_id = OLI2.object_chr_id
        AND OLI2.subject_chr_id = l_chr_id
        AND OLI1.subject_cle_id IS NULL
        AND OLI2.subject_cle_id IS NULL
        AND CLE.STS_CODE = STS.CODE
        AND STS.ste_code not in ('ENTERED', 'CANCELLED')
        AND OLI1.object_cle_id = OLI2.object_cle_id
        AND OLI2.subject_cle_id = p_cle_id;

begin
if (p_cle_id is NULL) then
  open c1;
  fetch c1 into l_status;
  close c1;
else
  open c2;
  fetch c2 into l_status;
  close c2;
end if;

 if l_status = 'Y' then
  return(TRUE);
 else
  return(FALSE);
 end if;

exception
   when no_data_found then
    return(FALSE);
end;


function TARGET_EXISTS(p_id in Number, p_cle_id in Number) return boolean is
  l_chr_id            number := p_id;
  l_target_exists     varchar2(1);
--
-- Following cursor will check if there are any other contracts renewed using
-- the same header/lines as used for the target contract being resurected

--** Additional check added as we are only interested in 'Renewal and Renewal Consolidation'

cursor C1 is
select distinct 'Y'
  from okc_operation_lines OLI1,
       okc_operation_lines OLI2,
       okc_operation_instances OIE1,             --**
       okc_class_operations    COP1,             --**
       okc_operation_instances OIE2,             --**
       okc_class_operations    COP2              --**
 where OLI1.object_chr_id = OLI2.object_chr_id
   and OLI1.oie_id = OIE1.id                     --**
   and OIE1.cop_id = COP1.id                     --**
   and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
   and OLI2.oie_id = OIE2.id                     --**
   and OIE2.cop_id = COP2.id                     --**
   and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
   and OLI1.subject_chr_id <> OLI2.subject_chr_id
   and OLI1.subject_chr_id = l_chr_id
   and OLI2.subject_cle_id > 0
   and OLI1.subject_cle_id > 0;

-- Line Level Check added as part of LLC
Cursor C2 is
select distinct 'Y'
  from okc_operation_lines OLI1,
       okc_operation_lines OLI2,
       okc_operation_instances OIE1,             --**
       okc_class_operations    COP1,             --**
       okc_operation_instances OIE2,             --**
       okc_class_operations    COP2              --**
 where OLI1.object_chr_id = OLI2.object_chr_id
   and OLI1.oie_id = OIE1.id                     --**
   and OIE1.cop_id = COP1.id                     --**
   and COP1.opn_code in ('RENEWAL', 'REN_CON')   --**
   and OLI2.oie_id = OIE2.id                     --**
   and OIE2.cop_id = COP2.id                     --**
   and COP2.opn_code in ('RENEWAL', 'REN_CON')   --**
   and OLI1.subject_chr_id <> OLI2.subject_chr_id
   and OLI1.subject_chr_id = l_chr_id
   and OLI2.subject_cle_id <> OLI1.subject_cle_id
   and OLI1.subject_cle_id = p_cle_id;
--
begin

if (p_cle_id is NULL) then
  open C1;
  fetch C1 into l_target_exists;
  close C1;
else
  open C2;
  fetch c2 into l_target_exists;
  close C2;
end if;

if l_target_exists = 'Y' then
  return(TRUE);
else
  return(FALSE);
end if;
end;

-- This procedure updates the line/sub-line status
-- the only possible options for this would be
-- 'Entered' and 'Cancelled', as all other statuses
-- are applicable to Contract Header.
-- This procedure also takes care of updating the
-- header and line amountsi, adjusting the billing
-- schedules and maintaining the renewal links  when
-- the status of the line is changed.
--
procedure Update_line_status (x_return_status       OUT NOCOPY VARCHAR2,
                              x_msg_data            OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              p_init_msg_list       in  varchar2,
                              p_id                  in number,
                              p_cle_id              in number,
                              p_new_sts_code        in varchar2,
                              p_canc_reason_code    in varchar2,
                              p_old_sts_code        in varchar2,
                              p_old_ste_code        in varchar2,
                              p_new_ste_code        in varchar2,
                              p_term_cancel_source  in varchar2,
                              p_date_cancelled      in Date,
                              p_comments            in varchar2,
                              p_validate_status     in varchar2) is

l_api_name      Varchar2(100) := 'UPDATE_LINE_STATUS';
x_num           number;
l_clev_tbl      clev_tbl_type;
l1_clev_tbl     clev_tbl_type;
l_code_Tbl      VC30_Tbl_Type;
l_id_Tbl        Num_Tbl_Type;
l_obj_ver_tbl   Num_Tbl_Type;
l_lse_tbl       Num_Tbl_Type;
l_type          Varchar2(30);
l_line_update   Varchar2(1) := 'Y';
l_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
x_hstv_rec      OKC_K_HISTORY_PVT.hstv_rec_type;
l_version       VARCHAR2(24);  --Changed datatype from NUMBER TO VARCHAR2(24)

l_scs_code      varchar2(30);
--
 cursor c_type is
   select ste_code
     from okc_statuses_v
    where code=p_new_sts_code;

-- bug#6144856 --

 cursor c_old_type is
   select ste_code
     from okc_statuses_v
    where code=p_old_sts_code;

l_old_type varchar2(30);

-- end of bug#6144856 --

 cursor c_top_line_chk is
   select id
   from okc_k_lines_b
   where id=p_cle_id
   and cle_id is null;

l_top_line number;
--
 l_signed varchar2(30);
--
 cursor c_signed is
   select code
     from okc_statuses_v
    where ste_code='SIGNED'
      and default_yn='Y';
--
 l_expired varchar2(30);
--
 cursor c_expired is
   select code
     from okc_statuses_v
    where ste_code='EXPIRED'
      and default_yn='Y';
--

 CURSOR version_csr(p_chr_id NUMBER) IS
        SELECT to_char (major_version)||'.'||to_char(minor_version)
        FROM okc_k_vers_numbers
        WHERE chr_id=p_chr_id;

--

CURSOR get_scs_code_csr IS
        SELECT  scs_code
        FROM    okc_k_headers_b
        WHERE   id= p_id;

--

Type c_lines_cur is REF CURSOR;
c_lines  c_lines_cur;

PROCEDURE init_table(x_clev_tbl out NOCOPY clev_tbl_type) IS
 g_clev_tbl clev_tbl_type;
BEGIN
        x_clev_tbl := g_clev_tbl;
END;

Begin

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '600: Entered UPDATE_LINE_STATUS');
  END IF;

  if (p_init_msg_list = FND_API.G_TRUE) then
     fnd_msg_pub.initialize();
  end if;

  if (p_count = 0) then
    p_count := 1;
  end if;

  open c_type;
  fetch c_type into l_type;
  close c_type;

  open c_old_type;
  fetch c_old_type into l_old_type;
  close c_old_type;

  OPEN c_top_line_chk;
  FETCH c_top_line_chk INTO l_top_line;
  CLOSE c_top_line_chk;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '610: value of l_type - '|| l_type );
  END IF;

  If (l_type='ACTIVE') then
    open c_signed;
    fetch c_signed into l_signed;
    close c_signed;
    open c_expired;
    fetch c_expired into l_expired;
    close c_expired;
  End If;
--
  x_num := 0;
  init_table(l_clev_tbl);


   if (p_cle_id is null) then

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '620: p_cle_id is null');
     END IF;
-- Added the following IF ELSE condition and modified the cursor for bug # 6144856 --
      IF ( l_type='HOLD' or l_type='CANCELLED') THEN

        open c_lines for select L.id, decode(l_type,'ACTIVE',
                         decode(sign(months_between(sysdate-1,NVL(L.end_date,sysdate))),-1,
                              decode(sign(months_between(L.start_date-1,sysdate)),-1,p_new_sts_code,l_signed)
                  ,l_expired)
                  ,p_new_sts_code) code, L.lse_id,
		  L.object_version_number
            from  okc_k_lines_v L, okc_statuses_v ls
           where L.dnz_chr_id = p_id
             and ls.code = L.sts_code
             and ls.ste_code in (l_old_type,'SIGNED')
             and NVL(L.term_cancel_source,'MANUAL') NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE'); --To ignore lines/sublines due to IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE

      ELSE

        open c_lines for select L.id, decode(l_type,'ACTIVE',
                         decode(sign(months_between(sysdate-1,NVL(L.end_date,sysdate))),-1,
                              decode(sign(months_between(L.start_date-1,sysdate)),-1,p_new_sts_code,l_signed)
                  ,l_expired)
                  ,p_new_sts_code) code, L.lse_id,
		  L.object_version_number
            from  okc_k_lines_v L, okc_statuses_v ls
           where L.dnz_chr_id = p_id
             and ls.code = L.sts_code
             and ls.ste_code in (l_type,l_old_type)
             and NVL(L.term_cancel_source,'MANUAL') NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE'); --To ignore lines/sublines due to IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE

      END IF;
-- end of bug# 6144856 --

   else  --No need of checking the status here as we know this action is possible only for 'Entered' or 'Cancelled' lines

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '630: p_cle_id is NOT null - '||p_cle_id );
     END IF;

-- Added the following IF ELSE condition and modified the cursor for bug # 6144856 --

     IF (l_top_line is not null) THEN
       IF (l_type = 'ENTERED' and l_old_type = 'CANCELLED' )  THEN
--Query modified as part of bugfix for 6525864
            open c_lines for select L.id,p_new_sts_code  code, L.lse_id,L.object_version_number
            from okc_k_lines_b L
            where L.dnz_chr_id = p_id
	    and (L.id =	p_cle_id or
	    L.cle_id = p_cle_id)
	    and EXISTS (select 'x'
	    from okc_statuses_b
	    where code = l.sts_code
	    and ste_code = 'CANCELLED')
            and NVL(L.term_cancel_source,'MANUAL') NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE'); --To ignore lines/sublines due to IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE

       ELSE
--Query modified as part of bugfix for 6525864
            open c_lines for select L.id, p_new_sts_code code, L.lse_id,L.object_version_number
            from okc_k_lines_b L
	    where L.dnz_chr_id = p_id
	    and (L.id =	p_cle_id or
	    L.cle_id = p_cle_id)
	    and EXISTS( select 'x'
	    from OKC_STATUSES_B
	    where code = l.sts_code
            and ste_code = l_old_type)
            and NVL(L.term_cancel_source,'MANUAL') NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE'); --To ignore lines/sublines due to IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE


       END IF;
     ELSE
            open c_lines for select L.id, p_new_sts_code code, L.lse_id,L.object_version_number
            from okc_k_lines_b L
            where L.id = p_cle_id
           and NVL(L.term_cancel_source,'MANUAL') NOT IN ('IBTRANSFER', 'IBRETURN', 'IBTERMINATE', 'IBREPLACE'); --To ignore lines/sublines due to IBTRANSFER, IBRETURN, IBTERMINATE, IBREPLACE
     END IF;

-- end of bug# 6144856 --

   end if;

 LOOP

    FETCH c_lines BULK COLLECT INTO
    l_id_Tbl, l_code_tbl, l_lse_tbl,l_obj_ver_tbl
    LIMIT 1000 ;
    IF (l_id_Tbl.COUNT < 1) THEN
           EXIT;
    END IF;

    IF (l_id_Tbl.COUNT > 0) THEN

          FOR i IN l_id_Tbl.FIRST  .. l_id_Tbl.LAST LOOP

           l_clev_tbl(x_num).id       := l_id_Tbl(i);
           l_clev_tbl(x_num).sts_code := l_code_Tbl(i);
           l_clev_tbl(x_num).lse_id   := l_lse_tbl(i);
	   l_clev_tbl(x_num).object_version_number := l_obj_ver_tbl(i); -- for bug 5710909
            -- To prevent Action Assembler from being called. Changes is line status
            -- will always result from a change in the header status
            --
            l_clev_tbl(x_num).VALIDATE_YN       := 'N';

            l_clev_tbl(x_num).call_action_asmblr := 'N';

            --CGOPINEE BUGFIX FOR BUG9259068
            IF OKS_CHANGE_STATUS_PVT.G_HEADER_STATUS_CHANGED <> 'Y' THEN
	       l_clev_tbl(x_num).call_action_asmblr := 'Y';
            END IF;

            if((p_validate_status = 'Y') and (p_cle_id IS NOT NULL)) then

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '640: Calling validate_status ' || l_clev_tbl(x_num).id);
                END IF;

               VALIDATE_STATUS( x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_id,
                                p_new_ste_code,
                                p_old_ste_code,
                                p_new_sts_code,
                                l_clev_tbl(x_num).sts_code,
                                l_clev_tbl(x_num).id,
                                p_validate_status);

               if (x_return_status = FND_API.G_RET_STS_ERROR) then
                       Raise FND_API.G_EXC_ERROR;
               elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
               elsif (x_return_status = OKC_API.G_RET_STS_WARNING) then
                        Raise OKC_API.G_EXC_WARNING;
               end if;
            end if;  -- l_clev_tbl(x_num).lse_id

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                           '640: Completed validate_status ' || l_clev_tbl(x_num).id);
            END IF;

            l_clev_tbl(x_num).new_ste_code := p_new_ste_code ;
            l_clev_tbl(x_num).new_sts_code := p_new_sts_code;
            l_clev_tbl(x_num).old_ste_code := p_old_ste_code ;
            l_clev_tbl(x_num).old_sts_code := p_old_sts_code;

            If p_new_ste_code = 'CANCELLED' then

                l_clev_tbl(x_num).date_cancelled := p_date_cancelled;
                l_clev_tbl(x_num).trn_code := p_canc_reason_code;
                l_clev_tbl(x_num).term_cancel_source := p_term_cancel_source;

            Elsif p_new_ste_code = 'ENTERED' THEN

                l_clev_tbl(x_num).date_cancelled := NULL;
                l_clev_tbl(x_num).trn_code := NULL;
                l_clev_tbl(x_num).term_cancel_source := NULL;

            End if;

           x_num :=x_num+1;

       END LOOP;
    END IF;
    exit when c_lines%NOTFOUND;

  END LOOP;
  close c_lines;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
              '650: Calling OKC_CONTRACT_PUB.update_contract_line ');
  END IF;

--bug 5710909
-- Added the following code to place a lock on contract lines.
       OKC_CONTRACT_PVT.lock_contract_line(
            p_api_version        => 1.0,
            p_init_msg_list    => 'T',
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_clev_tbl        => l_clev_tbl);

   If (x_return_status = FND_API.G_RET_STS_ERROR) then
      Raise FND_API.G_EXC_ERROR;
   elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;
-- end of bug 5710909

 -- Call the API to update the contract line with
 -- new status.
  OKC_CONTRACT_PUB.update_contract_line(
        p_api_version           => 1,
        P_INIT_MSG_LIST         => 'T',
        p_restricted_update     => 'T',
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data,
        p_clev_tbl              => l_clev_tbl,
        x_clev_tbl              => l1_clev_tbl);

   If (x_return_status = FND_API.G_RET_STS_ERROR) then
      Raise FND_API.G_EXC_ERROR;
   elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '660: Succesfully completed OKC_CONTRACT_PUB.update_contract_line ');
   END IF;

 -- Calling the API to Clean OR Relink the Contract Line if it was
 -- a renewed contract.

  if(p_old_ste_code = 'ENTERED' and p_new_ste_code = 'CANCELLED') then

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '670: calling okc_contract_pvt.Line_renewal_links, ENTERED => CANCELLED ');
   END IF;

    OKC_CONTRACT_PVT.Line_Renewal_links (
      p_api_version => 1,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_target_chr_id => p_id,
      p_target_line_id => p_cle_id,
      clean_relink_flag => 'CLEAN') ;

   If (x_return_status = FND_API.G_RET_STS_ERROR) then
      Raise FND_API.G_EXC_ERROR;
   elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

  elsif (p_old_ste_code = 'CANCELLED' and p_new_ste_code = 'ENTERED') then

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '680: calling okc_contract_pvt.Line_renewal_links, CANCELLED => ENTERED ');
   END IF;

    OKC_CONTRACT_PVT.Line_Renewal_links (
      p_api_version => 1,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_target_chr_id => p_id,
      p_target_line_id => p_cle_id,
      clean_relink_flag => 'RELINK');

   If (x_return_status = FND_API.G_RET_STS_ERROR) then
      Raise FND_API.G_EXC_ERROR;
   elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

  end if; -- p_old_ste_code and p_new_ste_code

 -- Call API to update the contract amount when status is changed from
 -- Entered to Cancel or vice versa

-- Code to find if the contract belongs to SERVICE CONTRACT (of type SERVICE, SUBSCRIPTION, WARRANTY)
-- If contract doesn't belong to service contract (as in case of OKL and OKE)
-- procedure update_contract_amount is not called for lines/sublines of the contract

Open get_scs_code_csr;
Fetch get_scs_code_csr Into l_scs_code;
Close get_scs_code_csr;

IF (l_scs_code IN ('SERVICE', 'SUBSCRIPTION', 'WARRANTY') ) THEN

  if (p_cle_id is NOT NULL) then
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 '690: calling okc_contract_pvt.update_contract_amount, p_cle_id is not null '||p_cle_id);
     END IF;

       OKC_CONTRACT_PVT.Update_contract_amount(
                p_api_version => 1,
                p_init_msg_list   => 'F',
                p_id                =>  p_id,
                p_from_ste_code =>  p_old_ste_code,
                p_to_ste_code   =>      p_new_ste_code,
                p_cle_id            =>  p_cle_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);


        If (x_return_status = FND_API.G_RET_STS_ERROR) then
                Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '695: calling update_contract_tax_amount, p_cle_id is not null '||p_cle_id);
	END IF;

          UPDATE_CONTRACT_TAX_AMOUNT(
                p_api_version => 1,
                p_init_msg_list   => 'F',
                p_id                =>  p_id,
                p_from_ste_code =>  p_old_ste_code,
                p_to_ste_code   =>      p_new_ste_code,
                p_cle_id            =>  p_cle_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);


        If (x_return_status = FND_API.G_RET_STS_ERROR) then
                Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;

  else

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '700: calling okc_contract_pvt.update_contract_amount, p_cle_id is null ');
   END IF;

        OKC_CONTRACT_PVT.Update_contract_amount(
                p_api_version => 1,
                p_init_msg_list   => 'F',
                p_id                =>  p_id,
                p_from_ste_code =>  p_old_ste_code,
                p_to_ste_code   =>      p_new_ste_code,
                p_cle_id            =>  NULL,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        If (x_return_status = FND_API.G_RET_STS_ERROR) then
                Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '705: calling update_contract_tax_amount, p_cle_id is null');
	END IF;

        UPDATE_CONTRACT_TAX_AMOUNT (
                p_api_version => 1,
                p_init_msg_list   => 'F',
                p_id                =>  p_id,
                p_from_ste_code =>  p_old_ste_code,
                p_to_ste_code   =>      p_new_ste_code,
                p_cle_id            =>  NULL,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        If (x_return_status = FND_API.G_RET_STS_ERROR) then
                Raise FND_API.G_EXC_ERROR;
        elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;


  end if;

 -- Call API to update the Billing schedule if it exists, this
 -- will update the schedule only if the status change action
 -- is taken on the subline.

   if (p_cle_id is NOT NULL) then

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                 '710: calling oks_bill_sch.sts_change_subline_lvl_rule');
       END IF;

       OKS_BILL_SCH.Sts_change_subline_lvl_rule(
                 p_cle_id           => p_cle_id,
                 p_from_ste_code    => p_old_ste_code,
                 p_to_ste_code      => p_new_ste_code,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_count);

       If (x_return_status = FND_API.G_RET_STS_ERROR) then
            Raise FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
       End if;







  end if;

  END IF; -- (l_scs_code IN ('SERVICE', 'SUBSCRIPTION', 'WARRANTY') )

  -- Call API to Create History record for the
  -- Lines or Sublines when change status action
  -- is taken.

  if (p_cle_id Is NOT NULL) then
    l_hstv_rec.chr_id := p_id;
    l_hstv_rec.cle_id := p_cle_id;
    l_hstv_rec.sts_code_from := p_old_sts_code;
    l_hstv_rec.sts_code_to := p_new_sts_code;
    l_hstv_rec.reason_code := p_canc_reason_code;
    l_hstv_rec.opn_code := 'STS_CHG';
    l_hstv_rec.comments := p_comments;

    open version_csr(p_id);
    fetch version_csr into l_version;
    close version_csr;

   l_hstv_rec.contract_version := l_version;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
               '720: calling okc_k_history_pvt.create_k_history, l_version - '||l_version);
   END IF;

   OKC_K_HISTORY_PVT.create_k_history(
      p_api_version     => 1,
      p_init_msg_list   => 'F',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_rec        => l_hstv_rec,
      x_hstv_rec        => x_hstv_rec);

    If (x_return_status = FND_API.G_RET_STS_ERROR) then
       Raise FND_API.G_EXC_ERROR;
    elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if;
  end if; -- call history API

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
              '730: succesfully complete update_line_status ');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'740: Leaving OKS_CHANGE_STATUS_PVT : FND_API.G_EXC_ERROR');
      END IF;
      if (c_lines%ISOPEN) then
        close c_lines;
      end if;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'750: Leaving OKS_CHANGE_STATUS_PVT : FND_API.G_EXC_UNEXPECTED_ERROR '||SQLERRM);
      END IF;

      if (c_lines%ISOPEN) then
        close c_lines;
      end if;

 WHEN OKC_API.G_EXC_WARNING then
      x_return_status := OKC_API.G_RET_STS_WARNING;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'760: Leaving OKS_CHANGE_STATUS_PVT : OKC_API.G_EXC_WARNING');
      END IF;

      if(c_lines%ISOPEN) then
        close c_lines;
      end if;

 WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'770: Leaving OKS_CHANGE_STATUS_PVT  because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      if (c_lines%ISOPEN) then
        close c_lines;
      end if;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
end;

procedure check_allowed_status( x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2,
                                p_id                IN NUMBER,
                                p_cle_id            IN NUMBER,
                                p_new_sts_code      IN VARCHAR2,
                                p_old_sts_code      IN OUT NOCOPY VARCHAR2,
                                p_old_ste_code      IN OUT NOCOPY VARCHAR2,
                                p_new_ste_code      IN OUT NOCOPY VARCHAR2)
IS

l_new_ste_code      varchar2(30);
l_old_ste_code      varchar2(30);
l_old_sts_code      varchar2(30);
l_new_sts_code      varchar2(30);
l_start_date        Date;
l_end_date          Date;
l_allowed_status    Varchar2(1) := 'N';
l_api_name          Varchar2(100) := 'Check_Allowed_Status';

cursor get_ste_code(p_code in varchar2) is
    Select ste_code from okc_statuses_b where code = p_code;

cursor get_k_hdr_cur (p_id in number) is
    Select sts_code, start_date, end_date from okc_k_headers_b where id = p_id;

cursor get_k_line_cur(p_cle_id in number) is
    Select sts_code, start_date, end_date from okc_k_lines_b where id = p_id;

begin

  l_new_sts_code := p_new_sts_code;

  if (p_cle_id is NULL) then
      open get_k_hdr_cur(p_id);
      fetch get_k_hdr_cur into l_old_sts_code, l_start_date, l_end_date;
      close get_k_hdr_cur;
  else
      open get_k_line_cur(p_cle_id);
      fetch get_k_line_cur into l_old_sts_code, l_start_date, l_end_date;
      close get_k_line_cur;
  end if;

  if (p_old_sts_code is NOT NULL) then
    l_old_sts_code := p_old_sts_code;
   end if;

  if (p_old_ste_code is NULL) then
      open get_ste_code (l_old_sts_code);
      fetch get_ste_code into l_old_ste_code;
      close get_ste_code;
      p_old_ste_code := l_old_ste_code;
  else
      l_old_ste_code :=p_old_ste_code;
  end if;

  If (p_old_ste_code = 'EXPIRED') then
    fnd_message.set_name('OKS','OKS_CHANGE_STAT_NOT_ALLOWED'); -- Add a message name here and throw a exception
    fnd_msg_pub.add();
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_new_ste_code is NULL) then
      open get_ste_code (l_new_sts_code);
      fetch get_ste_code into l_new_ste_code;
      close get_ste_code;
      p_new_ste_code := l_new_ste_code;
  else
      l_new_ste_code := p_new_ste_code;
  end if;


select 'Y' INTO l_allowed_status from dual where (l_new_sts_code,l_new_ste_code) in
(select
        S.CODE STATUS_CODE
    ,S.STE_CODE STE_CODE
from
         okc_statuses_v S
        ,fnd_lookups ST
where
        S.STE_CODE in
        (
                NVL(l_old_ste_code,'ENTERED')
                ,decode(l_old_ste_code,
                    NULL, 'CANCELLED',
                    'ENTERED','CANCELLED',
                    'ACTIVE','HOLD',
                    'SIGNED','HOLD',
                    'HOLD',decode(
NVL(sign(months_between
(l_start_date,sysdate+1)),1),
                                -1,decode(
NVL(sign(months_between(l_end_date,sysdate-1)),
1),1,'ACTIVE'
,'EXPIRED'),'SIGNED')))
and sysdate between s.start_date and nvl(s.end_date,sysdate)
and st.lookup_type='OKC_STATUS_TYPE'
and st.lookup_code=s.ste_code
and sysdate between st.start_date_active and
        nvl(st.end_date_active,sysdate)
and ST.enabled_flag='Y'
and S.code<>NVL(l_old_sts_code,'ENTERED')
and l_old_sts_code not like 'QA%HOLD'
and S.code not like 'QA%HOLD'
AND l_old_ste_code <> 'CANCELLED'
UNION ALL
SELECT  S.CODE STATUS_CODE
       ,S.STE_CODE STE_CODE1
FROM   OKC_STATUSES_V S
       ,FND_LOOKUPS ST
WHERE  S.STE_CODE in ('ENTERED', 'CANCELLED')
  AND  SYSDATE BETWEEN S.START_DATE AND NVL(S.END_DATE, SYSDATE)
  AND  ST.LOOKUP_TYPE = 'OKC_STATUS_TYPE'
  AND  ST.LOOKUP_CODE=S.STE_CODE
  AND  SYSDATE BETWEEN ST.START_DATE_ACTIVE AND NVL(ST.END_DATE_ACTIVE, SYSDATE)
  AND  ST.ENABLED_FLAG = 'Y'
  AND  S.code <> l_old_sts_code
  AND  l_old_ste_code='CANCELLED');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

exception

WHEN FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving OKS_CHANGE_STATUS_PVT : FND_API.G_EXC_ERROR');
    END IF;

WHEN NO_DATA_FOUND then
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('OKS','OKS_CHANGE_STAT_NOT_ALLOWED');  -- set the message here
    fnd_msg_pub.add;

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'510: Leaving OKS_CHANGE_STATUS_PVT : NO_DATA_FOUND');
    END IF;

WHEN OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'520: Leaving OKS_CHANGE_STATUS_PVT  because of EXCEPTION: '||sqlerrm);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

end check_allowed_status;


--[llc] Update Contract Tax Amount

/*
   The Header and Line Tax Amounts should be updated when Change Status action is taken
   at the header/line/subline level. This is to ensure that the new calcualated Tax Amount
   ignores cancelled top lines/sublines.

   A new procedure Update_Contract_Tax_Amount is created which will be called when Change Status
   action is taken on the header/line/subline level and after Update_Contract_Amount has
   been called for the same.

*/


PROCEDURE UPDATE_CONTRACT_TAX_AMOUNT (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_id                IN NUMBER,
    p_from_ste_code     IN VARCHAR2,
    p_to_ste_code       IN VARCHAR2,
    p_cle_id            IN NUMBER,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2 )

IS

        l_cle_id                Number := NULL;
        l_sub_line_tax_amt       Number := NULL;
        l_lse_id                Number := NULL;
        l_hdr_tax_amt           Number := NULL;

        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_return_status         VARCHAR2(1):='S';

        g_rail_rec              OKS_TAX_UTIL_PVT.ra_rec_type;
        l_Tax_Value             g_rail_rec.TAX_VALUE%TYPE;

        l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_TAX_AMOUNT';
        g_cle_id                Number;              /*Added for bug:8775250*/



--Cursor to get topline id for a particular subline; For a topline this will return NULL

    Cursor get_line_lvl_csr is
        Select  cle_id
        from    okc_k_lines_b
        where   id = p_cle_id
        and     dnz_chr_id = p_id;


--Cursor to fetch tax_amount for a particular subline

    Cursor get_subline_tax_amt_csr (p_cle_id NUMBER) IS
        Select  sle.tax_amount
        from    okc_k_lines_b cle, oks_k_lines_b sle
        where   cle.id = p_cle_id
            and cle.dnz_chr_id = p_id
            and cle.id = sle.cle_id
            and cle.dnz_chr_id = sle.dnz_chr_id;

--Cursor to add tax_amount of all the toplines

    Cursor get_hdr_tax_amt_csr IS
        select  nvl(sum(nvl(tax_amount,0)),0)
        from    okc_k_lines_b cle, oks_k_lines_b sle
        where   cle.dnz_chr_id = p_id
        and     cle.lse_id in (1, 12, 14, 19, 46)
        and     cle.cle_id is null
        and     cle.id = sle.cle_id
        and     cle.dnz_chr_id = sle.dnz_chr_id;


--Cursor to fectch lse_id of topline

    Cursor get_lse_id_csr (p_cle_id NUMBER)  IS
        select  lse_id
        from    okc_k_lines_b
        where   id=p_cle_id;


--/*Added for bug:8775250*/
       Cursor get_sub_tax_amt_csr (p_cle_id NUMBER)  IS
        Select  cle.id,sle.tax_amount
        from    okc_k_lines_b cle, oks_k_lines_b sle
        where   cle.cle_id = p_cle_id
         and cle.dnz_chr_id = p_id
         and cle.lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35)
         and cle.term_cancel_source ='MANUAL'
         and cle.id = sle.cle_id
         and cle.dnz_chr_id = sle.dnz_chr_id;

         Cursor get_subline_csr(p_cle_id NUMBER) IS
          Select  okslb.id,okslb.cancelled_amount
           from  okc_k_lines_b cle,
                 okc_k_lines_b okslb
         where   cle.id = p_cle_id
           and   okslb.lse_id in (7, 8, 9, 10, 11, 13, 18, 25, 35)
           and   okslb.cle_id =cle.id
           and   okslb.date_cancelled is null;

       Cursor get_lines_id(p_id number) IS
       select oklb.id,oklb.price_negotiated
         from okc_k_lines_b oklb,
              okc_k_headers_all_b okhb
        where oklb.chr_id = okhb.id
          and okhb.id = p_id
          and oklb.lse_id in (1,12,14,19,46);


    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '800: Entered UPDATE_CONTRACT_TAX_AMOUNT ');
    END IF;

    IF ((p_from_ste_code is NULL) OR  (p_to_ste_code is NULL) OR  (p_id is null)) THEN
        raise FND_API.G_EXC_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '810: Parameter Values ' ||
                            'p_id - '|| p_id ||
                            'p_from_ste_code - '||p_from_ste_code ||
                            'p_to_ste_code - '||p_to_ste_code ||
                            'p_cle_id- '||p_cle_id );
      END IF;

    IF (p_cle_id is NOT NULL) THEN -- implies line or sub-line level

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '900: p_cle_id is not null; Change Status called from line/subline level ');
        END IF;

        Open    get_line_lvl_csr;
        Fetch   get_line_lvl_csr into l_cle_id;
        Close   get_line_lvl_csr;

        IF (l_cle_id is NOT NULL) THEN  --p_cle_id is a subline

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '910: Updating tax_amount of topline of the subline due to status change of the subline ');
            END IF;

            Open get_subline_tax_amt_csr(p_cle_id);
            Fetch get_subline_tax_amt_csr into l_sub_line_tax_amt;
            Close get_subline_tax_amt_csr;

            IF ((p_from_ste_code = 'ENTERED' ) AND (p_to_ste_code = 'CANCELLED')) THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '920: ENTERED -> CANCELLED; Updating tax_amount of the topline of the subline ');
                END IF;

                -- updating tax_amount for the topline (l_cle_id) of this subline (p_cle_id)

                Update  oks_k_lines_b
                set     tax_amount= nvl(tax_amount, 0) - l_sub_line_tax_amt
                where   dnz_chr_id = p_id
                and     cle_id = l_cle_id;

            --Bug:6765336  Updating the subline when it is cancelled
                Update  oks_k_lines_b
                set   tax_amount= Nvl(tax_amount, 0) - l_sub_line_tax_amt
                Where   cle_id = p_cle_id
                and     dnz_chr_id = p_id;
              --Bug:6765336

            ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '930: CANCELLED -> ENTERED; Updating tax_amount of the topline of the subline ');
                END IF;
/*Added for bug:8775250*/
                g_cle_id :=p_cle_id;

                OKS_TAX_UTIL_PVT.Get_Tax
                    (
                      p_api_version   => 1.0,
                      p_init_msg_list => OKC_API.G_TRUE,
                      p_chr_id        => p_id,
                      p_cle_id        => g_cle_id,
                      px_rail_rec     => g_rail_rec,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      x_return_status => x_return_status
                  );

                   Update oks_k_lines_b
                   set tax_amount= nvl(g_rail_rec.TAX_VALUE,0)
                where dnz_chr_id = p_id
                  and cle_id = g_cle_id;

                -- updating tax_amount for the topline (l_cle_id) of this subline (p_cle_id)

                Update oks_k_lines_b
                set tax_amount= nvl(tax_amount, 0) + nvl(g_rail_rec.TAX_VALUE,0)
                where dnz_chr_id = p_id
                and cle_id = l_cle_id;

            END IF;     -- p_to_ste_code ='CANCELLED'

        ELSE --l_cle_id is NULL  --p_cle_id is a top line


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1000: Updating tax_amount of the topline');
            END IF;

            IF ((p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')) THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                             '1010: ENTERED -> CANCELLED; Updating tax_amount of topline ');
                END IF;

            -- updating tax_amount for the topline (p_cle_id)

                Update  oks_k_lines_b
                set     tax_amount= 0
                where   dnz_chr_id = p_id
                and     cle_id = p_cle_id;

              FOR  get_sub_tax_amt_csr_rec IN  get_sub_tax_amt_csr(p_cle_id)
                 LOOP
               Update  oks_k_lines_b
                  set  tax_amount= Nvl(tax_amount, 0) - get_sub_tax_amt_csr_rec.tax_amount
                Where  cle_id = get_sub_tax_amt_csr_rec.id
                  and  dnz_chr_id = p_id;
               END LOOP;


            ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                -- Opening cursor to get the lse_id of the top line

                Open    get_lse_id_csr (p_cle_id);
                Fetch   get_lse_id_csr into l_lse_id;
                Close   get_lse_id_csr;

                IF (l_lse_id = 46 ) THEN  --Checking if top line is of SUBSCRIPTION type

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '1020: Calling FUNCTION get_tax_for_subs_line: Contract ID ' || p_id || ' Topline ID '|| p_cle_id);
                    END IF;

                   -- Calling function get_tax_for_subs_line to get tax_amount of this subscription line

                   l_Tax_Value := get_tax_for_subs_line (p_id, p_cle_id);

                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '1030: Successfully called FUNCTION get_tax_for_subs_line ');
                   END IF;


                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                             '1040: CANCELLED -> ENTERED; Updating tax_amount for SUBSCRIPTION topline ');
                    END IF;

                    -- updating tax_amount for top line for SUBSCRIPTION line type due to change in the status of top line

                                Update  oks_k_lines_b
                                set     tax_amount= l_Tax_Value
                                where   dnz_chr_id = p_id
                                and     cle_id = p_cle_id;


                ELSE  -- top line is not of SUBSCRIPTION type

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1050: CANCELLED -> ENTERED; Updating tax_amount for NON-SUBSCRIPTION topline ');
                    END IF;

               FOR get_subline_csr_rec IN get_subline_csr(p_cle_id)
                 LOOP
                g_rail_rec.amount:=Null;
                g_cle_id := get_subline_csr_rec.id;

               OKS_TAX_UTIL_PVT.Get_Tax
                    (
                      p_api_version   => 1.0,
                      p_init_msg_list => OKC_API.G_TRUE,
                      p_chr_id        => p_id,
                      p_cle_id        => g_cle_id,
                      px_rail_rec     => g_rail_rec,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      x_return_status => x_return_status
                  );

              Update  oks_k_lines_b
                set   tax_amount= Nvl(tax_amount, 0)+nvl(g_rail_rec.TAX_VALUE,0)
                Where   cle_id = get_subline_csr_rec.id
                and     dnz_chr_id = p_id;
                 END LOOP;
                -- updating tax_amount for top line which is not of SUBSCRIPTION type

                    Update  oks_k_lines_b
                    set     tax_amount=
                                        (Select nvl(sum(nvl(tax_amount,0)),0)
                                        from    okc_k_lines_b cle, oks_k_lines_b sle
                                        where   cle.cle_id = p_cle_id
                                        and     cle.lse_id in (7,8,9,10,11,18,25,35)
                                        and     cle.dnz_chr_id = p_id
                                        and     cle.id = sle.cle_id
                                        and     cle.dnz_chr_id = sle.dnz_chr_id
					and     cle.date_cancelled is NULL -- Bug 5474479
                                        )
                        where   dnz_chr_id = p_id
                        and     cle_id = p_cle_id;


                END IF; -- l_lse_id = 46

           END IF; -- (p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')

        END IF;  -- l_cle_id is NOT NULL

    ELSE -- p_cle_id is NULL   --implies Change Status action is taken at header Level

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1100: Updating Header ');
            END IF;

            IF ((p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')) THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1110: ENTERED -> CANCELLED; Updating tax_amount for all toplines of contract ');
                END IF;

              FOR get_lines_id_rec  IN get_lines_id(p_id)
                LOOP
              FOR get_sub_tax_amt_csr_rec IN get_sub_tax_amt_csr(get_lines_id_rec.ID)
                LOOP
                 Update   oks_k_lines_b
                    set   tax_amount= 0
                  Where   cle_id = get_sub_tax_amt_csr_rec.id
                    and   dnz_chr_id = p_id;
                 END LOOP;
               END LOOP;
             -- updating tax_amount for all the top lines of the contract

                update  oks_k_lines_b
                set     tax_amount = 0
                where   dnz_chr_id = p_id
                and     cle_id IN
                                (select id
                                from    okc_k_lines_b
                                where   cle_id is null
                                and     dnz_chr_id = p_id
                                and     lse_id in (1, 12, 14, 19, 46)
                                );

            ELSIF ((p_from_ste_code = 'CANCELLED' ) AND (p_to_ste_code = 'ENTERED')) THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1120: CANCELLED -> ENTERED; Updating tax_amount for all toplines of contract ');
                END IF;

                   FOR get_lines_id_rec IN get_lines_id(p_id)
                     LOOP
                   FOR get_subline_csr_rec IN get_subline_csr(get_lines_id_rec.ID)
                     LOOP
                     g_rail_rec.amount := Null;
                    g_cle_id := get_subline_csr_rec.id;

                  OKS_TAX_UTIL_PVT.Get_Tax
                      (
                      p_api_version   => 1.0,
                      p_init_msg_list => OKC_API.G_TRUE,
                      p_chr_id        => p_id,
                      p_cle_id        => g_cle_id,
                      px_rail_rec     => g_rail_rec,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      x_return_status => x_return_status
                     );
              Update  oks_k_lines_b
                set   tax_amount= Nvl(tax_amount, 0)+nvl(g_rail_rec.TAX_VALUE,0)
                Where cle_id = get_subline_csr_rec.id
                and   dnz_chr_id = p_id;

                  END LOOP;
               END LOOP;
                   -- updating tax_amount for all the top lines of the contract which are not of SUBSCRIPTION type

                    update oks_k_lines_b oks1
                    set oks1.tax_amount =
                                        (
                                          select nvl(sum(nvl(tax_amount,0)),0)
                                          from oks_k_lines_b oks2, okc_k_lines_b okc2
                                          where oks2.cle_id = okc2.id
                                          and oks2.dnz_chr_id = okc2.dnz_chr_id
                                          and okc2.dnz_chr_id = p_id
                                          and okc2.cle_id =  oks1.cle_id
					  and okc2.date_cancelled IS NULL -- Bug 5474479.
                                        )
                        where oks1.dnz_chr_id = p_id
                        and oks1.cle_id IN
                                        (select id
                                        from okc_k_lines_b okc1
                                        where okc1.cle_id is null
                                        and okc1.lse_id in (1, 12, 14, 19)  --removed 46 (subscription type)
                                        and okc1.dnz_chr_id = p_id
					and okc1.date_cancelled IS NULL -- Bug 5474479.
                                        );

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                              '1130: Calling UPDATE_SUBSCRIPTION_TAX_AMOUNT ' || p_id);
                    END IF;

                    --Calling procudure to update tax_amount for subscription line type of the contract, if any

                    UPDATE_SUBSCRIPTION_TAX_AMOUNT(
                                    p_api_version => 1,
                                    p_init_msg_list   => 'F',
                                    p_id  => p_id,
                                    x_return_status => l_return_status,
                                    x_msg_count  => l_msg_count,
                                    x_msg_data => l_msg_data);

                    If (x_return_status = FND_API.G_RET_STS_ERROR) then
                        Raise FND_API.G_EXC_ERROR;
                    elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    End if;

                     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                         '1140: Succesfully completed UPDATE_SUBSCRIPTION_TAX_AMOUNT ');
                     END IF;

            END IF;     --(p_from_ste_code = 'ENTERED') AND (p_to_ste_code = 'CANCELLED')

    END IF; --p_cle_id is NULL

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                           '1200: Updating header tax_amount ');
            END IF;

    -- updating tax_amount for header level of the contract due to change in the status of line/subline/contract

                  Open  get_hdr_tax_amt_csr;
                  Fetch get_hdr_tax_amt_csr Into l_hdr_tax_amt;
                  Close get_hdr_tax_amt_csr;

                Update OKS_K_headers_b
                set tax_amount = l_hdr_tax_amt
                Where chr_id = p_id;

---

x_return_status := FND_API.G_RET_STS_SUCCESS;

---
Exception

 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1300: Leaving OKS_CHANGE_STATUS_PVT, one or more mandatory parameters missing :FND_API.G_EXC_ERROR');
      END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1310: Leaving OKS_CHANGE_STATUS_PVT: FND_API.G_EXC_UNEXPECTED_ERROR '|| SQLERRM);
      END IF;

 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1320: Leaving OKS_CHANGE_STATUS_PVT because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END UPDATE_CONTRACT_TAX_AMOUNT;


---[llc] UPDATE_SUBSCRIPTION_TAX_AMOUNT updates all the tax_amount of toplines which are of type subscription

PROCEDURE UPDATE_SUBSCRIPTION_TAX_AMOUNT(
			p_api_version	IN NUMBER,
			p_init_msg_list IN varchar2 default FND_API.G_FALSE,
			p_id		IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count	OUT NOCOPY NUMBER,
			x_msg_data	OUT NOCOPY VARCHAR2)

IS

        Cursor get_K_subscription_lines IS
        select  id
        from    okc_k_lines_b
        where   cle_id is null
        and     lse_id = 46
        and     dnz_chr_id = p_id;


l_id_Tbl                Num_Tbl_Type;
l_subs_tax_Tbl          Num_Tbl_Type;
l_sub_tax_amt           Number;

        l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_SUBSCRIPTION_TAX_AMOUNT';
--
BEGIN

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '1150: Entered UPDATE_SUBSCRIPTION_TAX_AMOUNT ');
         END IF;

        Open    get_K_subscription_lines;

        LOOP

                FETCH get_K_subscription_lines BULK COLLECT INTO
                l_id_Tbl LIMIT 1000 ;

                IF (l_id_Tbl.COUNT < 1) THEN
                   EXIT;
                END IF;

            IF (l_id_Tbl.COUNT > 0) THEN

                FOR i IN l_id_Tbl.FIRST  .. l_id_Tbl.LAST

                LOOP

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                           '1155: Callling procedure get_tax_for_subs_line for topline '|| l_id_Tbl(i));
                  END IF;

                  l_subs_tax_Tbl(i)     := get_tax_for_subs_line (p_id, l_id_Tbl(i));


               END LOOP;
        END IF;

    exit when get_K_subscription_lines%NOTFOUND;

END LOOP;

  Close   get_K_subscription_lines;

--
  IF (l_id_Tbl.COUNT > 0) THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                           '1160: Trying to bulk updat tax_amount of toplines of type subscription of contract '|| p_id);
        END IF;

        FORALL I IN l_id_Tbl.FIRST .. l_id_Tbl.LAST

                Update  oks_k_lines_b
                set     tax_amount= l_subs_tax_Tbl(I)
                where   dnz_chr_id = p_id
                and     cle_id = l_id_Tbl(I);

   END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                           '1165: Successfully bulk updated tax_amount of toplines of type subscription of contract '|| p_id);
 END IF;

 ---

x_return_status := FND_API.G_RET_STS_SUCCESS;

---
Exception

 WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1170: Leaving OKS_CHANGE_STATUS_PVT, one or more mandatory parameters missing :FND_API.G_EXC_ERROR');
      END IF;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1180: Leaving OKS_CHANGE_STATUS_PVT: FND_API.G_EXC_UNEXPECTED_ERROR '|| SQLERRM);
      END IF;

 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1190: Leaving OKS_CHANGE_STATUS_PVT because of EXCEPTION: '||sqlerrm);
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name, SQLERRM );
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END UPDATE_SUBSCRIPTION_TAX_AMOUNT;
---

--[llc] get_tax_for_subs_line


FUNCTION get_tax_for_subs_line (p_id in number, p_cle_id in number ) return NUMBER
        IS

        x_msg_count            NUMBER;
        x_msg_data             varchar2(2000);
        l_return_status        VARCHAR2(1);

        g_rail_rec             OKS_TAX_UTIL_PVT.ra_rec_type;
        l_Tax_Value            g_rail_rec.TAX_VALUE%TYPE;

BEGIN


        OKS_TAX_UTIL_PVT.Get_Tax(
                p_api_version   => 1.0,
                p_init_msg_list => 'F',
                p_chr_id        => p_id,
                p_cle_id        => p_cle_id,
                px_rail_rec     => g_rail_rec,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                x_return_status => l_return_status);

                If (l_return_status = FND_API.G_RET_STS_ERROR) then
                        Raise FND_API.G_EXC_ERROR;
                   elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                End if;


        If (l_return_status = 'S') then
              return nvl(g_rail_rec.TAX_VALUE,0);
        else
                return 0;
        End If;

END get_tax_for_subs_line;


---

end oks_change_status_pvt;

/
