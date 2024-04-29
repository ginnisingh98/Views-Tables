--------------------------------------------------------
--  DDL for Package Body OKS_BILLING_PROFILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILLING_PROFILES_PUB" AS
/* $Header: OKSPBPEB.pls 120.4.12010000.2 2008/12/22 04:49:59 cgopinee ship $ */

/*
  FUNCTION migrate_bpev(p_bpev_rec1 IN bpev_rec_type,
                        p_bpev_rec2 IN bpev_rec_type)
    RETURN bpev_rec_type IS
    l_bpev_rec bpev_rec_type;
  BEGIN
    l_bpev_rec.id						:= p_bpev_rec1.id;
    l_bpev_rec.object_version_number		:= p_bpev_rec1.object_version_number;
    l_bpev_rec.created_by				:= p_bpev_rec1.created_by;
    l_bpev_rec.creation_date				:= p_bpev_rec1.creation_date;
    l_bpev_rec.last_updated_by			:= p_bpev_rec1.last_updated_by;
    l_bpev_rec.last_update_date			:= p_bpev_rec1.last_update_date;
    l_bpev_rec.last_update_login			:= p_bpev_rec1.last_update_login;
    l_bpev_rec.sfwt_flag				:= p_bpev_rec2.sfwt_flag;
    l_bpev_rec.mda_code					:= p_bpev_rec2.mda_code;
    l_bpev_rec.irc_owned_customer_id		:= p_bpev_rec2.irc_owned_customer_id;
    l_bpev_rec.irc_dependent_customer_id		:= p_bpev_rec2.irc_dependent_customer_id;
    l_bpev_rec.ira_address_id				:= p_bpev_rec2.ira_address_id;
    l_bpev_rec.unit_of_measure			:= p_bpev_rec2.unit_of_measure;
    l_bpev_rec.profile_number				:= p_bpev_rec2.profile_number;
    l_bpev_rec.message					:= p_bpev_rec2.message;
    l_bpev_rec.summarised_yn				:= p_bpev_rec2.summarised_yn;
    l_bpev_rec.release_day				:= p_bpev_rec2.release_day;
    l_bpev_rec.description				:= p_bpev_rec2.description;
    l_bpev_rec.attribute_category			:= p_bpev_rec2.attribute_category;
    l_bpev_rec.attribute1				:= p_bpev_rec2.attribute1;
    l_bpev_rec.attribute2				:= p_bpev_rec2.attribute2;
    l_bpev_rec.attribute3				:= p_bpev_rec2.attribute3;
    l_bpev_rec.attribute4				:= p_bpev_rec2.attribute4;
    l_bpev_rec.attribute5				:= p_bpev_rec2.attribute5;
    l_bpev_rec.attribute6				:= p_bpev_rec2.attribute6;
    l_bpev_rec.attribute7				:= p_bpev_rec2.attribute7;
    l_bpev_rec.attribute8				:= p_bpev_rec2.attribute8;
    l_bpev_rec.attribute9				:= p_bpev_rec2.attribute9;
    l_bpev_rec.attribute10				:= p_bpev_rec2.attribute10;
    l_bpev_rec.attribute11				:= p_bpev_rec2.attribute11;
    l_bpev_rec.attribute12				:= p_bpev_rec2.attribute12;
    l_bpev_rec.attribute13				:= p_bpev_rec2.attribute13;
    l_bpev_rec.attribute14				:= p_bpev_rec2.attribute14;
    l_bpev_rec.attribute15				:= p_bpev_rec2.attribute15;
    RETURN (l_bpev_rec);
  END migrate_bpev;
*/

  Type sll_prorated_rec_type IS RECORD
  ( sll_seq_num           Number,
  sll_start_date        DATE,
  sll_end_date          DATE,
  sll_tuom              VARCHAR2(40),
  sll_period            Number,
  sll_uom_per_period    Number,
  sll_amount            Number
  );

  Type sll_prorated_tab_type is Table of sll_prorated_rec_type index by binary_integer;

  FUNCTION Find_Currency_Code
  (        p_cle_id  NUMBER,
           p_chr_id  NUMBER
  )
  RETURN VARCHAR2
  IS

  CURSOR l_line_cur IS
         SELECT contract.currency_code
         FROM okc_k_headers_b contract, okc_k_lines_b line
         WHERE contract.id = line.dnz_chr_id and line.id = p_cle_id;

  CURSOR l_hdr_cur IS
         SELECT contract.currency_code
         FROM okc_k_headers_b contract
         WHERE contract.id = p_chr_id;


  l_Currency  VARCHAR2(15);

  BEGIN

  IF p_chr_id IS NULL THEN       ---called for line
     OPEN l_line_cur;
     FETCH l_line_cur INTO l_currency;

     IF l_line_cur%NOTFOUND THEN
       l_Currency := NULL;
     END IF;

     Close l_line_cur;

  ELSE                   ---FOR HEADER

     OPEN l_hdr_cur;
     FETCH l_hdr_cur INTO l_currency;

     IF l_hdr_cur%NOTFOUND THEN
       l_Currency := NULL;
     END IF;

     Close l_hdr_cur;

  END IF;

  RETURN l_Currency;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
      WHEN OTHERS THEN
        RETURN NULL;

  END Find_Currency_Code;

  PROCEDURE Calculate_sll_amount( p_api_version       IN      NUMBER,
                                  p_total_amount      IN      NUMBER,
                                  p_currency_code     IN      VARCHAR2,
                                  p_period_start      IN      VARCHAR2,
                                  p_period_type       IN      VARCHAR2,
                                  p_sll_prorated_tab  IN  OUT NOCOPY sll_prorated_tab_type,
                                  x_return_status     OUT     NOCOPY VARCHAR2

  )
  IS
  l_sll_num               NUMBER;
  i                       NUMBER;
  j                       NUMBER;
  l_sll_remain_amount  NUMBER(20,2);
  l_currency_code   VARCHAR2(15);
  l_period_sll_amt        NUMBER(20,2);

  l_uom_code     VARCHAR2(40);
  l_tce_code      VARCHAR2(10);
  l_uom_quantity         NUMBER;
  l_curr_sll_start_date  DATE;
  l_curr_sll_end_date    DATE;

  l_next_sll_start_date  DATE;
  l_next_sll_end_date    DATE;
  l_tot_sll_amount       NUMBER(20,2);

  l_curr_frequency        NUMBER;
  l_next_frequency        NUMBER;
  l_tot_frequency         NUMBER;
  l_sll_period        NUMBER;
  l_return_status         VARCHAR2(1);
  l_uom_per_period         NUMBER;
  l_temp                   NUMBER;

  BEGIN
  x_return_status := 'S';
  l_sll_num := p_sll_prorated_tab.count;
  l_sll_remain_amount := p_total_amount;
   -------------------------------------------------------------------------
   -- Begin partial period computation logic
   -- Developer Mani Choudhary
   -- Date 31-MAY-2005
   -- Proration to consider period start and period type
   -------------------------------------------------------------------------
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
    'input parameters period start  '||p_period_start
    ||' p_period_type = ' || p_period_type);
  END IF;

  IF p_period_start is NOT NULL AND
     p_period_type  is NOT NULL
  THEN
    FOR i in 1 .. l_sll_num LOOP
      l_uom_code := p_sll_prorated_tab(i).sll_tuom ;
      l_uom_per_period := p_sll_prorated_tab(i).sll_uom_per_period ;
       --errorout_ad('l_uom_code '||l_uom_code);
      l_next_sll_end_date := NULL;
      l_curr_sll_start_date := p_sll_prorated_tab(i).sll_start_date;
      l_curr_sll_end_date   := p_sll_prorated_tab(i).sll_end_date;

      For j in i+1 .. l_sll_num Loop
            l_next_sll_start_date := p_sll_prorated_tab(j).sll_start_date;
            l_next_sll_end_date   := p_sll_prorated_tab(j).sll_end_date;
  /*          l_temp:=NULL;
            l_temp:= OKS_TIME_MEASURES_PUB.get_quantity (
                                                          p_start_date   => l_next_sll_start_date,
                                                          p_end_date     => l_next_sll_end_date,
                                                          p_source_uom   => l_uom_code,
                                                          p_period_type  => p_period_type,
                                                          p_period_start => p_period_start
                                                          );
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
              'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
              ||' result l_temp '||l_temp);
            END IF;

            IF nvl(l_temp,0) = 0 THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            l_next_frequency :=l_next_frequency + l_temp;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
              'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
              ||' result l_next_frequency '||l_next_frequency);
            END IF;

  */

       END LOOP;

      l_curr_frequency := OKS_TIME_MEASURES_PUB.get_quantity (
                                                          p_start_date   => l_curr_sll_start_date,
                                                          p_end_date     => l_curr_sll_end_date,
                                                          p_source_uom   => l_uom_code,
                                                          p_period_type  => p_period_type,
                                                          p_period_start => p_period_start
                                                          );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
         'afer calling OKS_TIME_MEASURES_PUB.get_quantity input parameters period start  '||p_period_start||' p_period_type = ' || p_period_type
         ||' result l_curr_frequency '||l_curr_frequency);
      END IF;

      IF nvl(l_curr_frequency,0) = 0 THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      l_tot_frequency := 0;

      l_tot_frequency := OKS_TIME_MEASURES_PUB.get_quantity (
                                                          p_start_date   => l_curr_sll_start_date,
                                                          p_end_date     => nvl(l_next_sll_end_date,l_curr_sll_end_date),
                                                          p_source_uom   => l_uom_code,
                                                          p_period_type  => p_period_type,
                                                          p_period_start => p_period_start
                                                          );

      IF nvl(l_tot_frequency,0) = 0 THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
          --errorout_ad('l_curr_frequency '||l_curr_frequency);

    --        l_next_frequency := 0;


    --      l_tot_frequency := l_tot_frequency + l_curr_frequency + l_next_frequency;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
             ' result l_tot_frequency '||l_tot_frequency);
          END IF;

          --errorout_ad('l_tot_frequency '||l_tot_frequency);
         -- l_sll_period := p_sll_prorated_tab(i).sll_period;
          l_sll_period := l_curr_frequency/l_uom_per_period;

          l_period_sll_amt := ( l_sll_remain_amount /( nvl(l_tot_frequency,1) * nvl(l_sll_period,1))) * nvl(l_curr_frequency,0) ;

          l_period_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_period_sll_amt, l_currency_code);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
             ' result l_period_sll_amt '||l_period_sll_amt);
          END IF;


          l_sll_remain_amount := l_sll_remain_amount - (l_period_sll_amt * nvl(l_sll_period,1)) ;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,G_MODULE_CURRENT||'.Calculate_sll_amount.ppc',
             ' result l_sll_remain_amount '||l_sll_remain_amount);
          END IF;

          --errorout_ad('l_period_sll_amt '||l_period_sll_amt);
          --errorout_ad('l_sll_remain_amount '||l_sll_remain_amount);
          p_sll_prorated_tab(i).sll_amount := l_period_sll_amt;
          l_curr_frequency := 0;
    END LOOP;
   -------------------------------------------------------------------------
   -- End partial period computation logic
   -------------------------------------------------------------------------
  ELSE
    For i in 1 .. l_sll_num Loop
      l_uom_code := p_sll_prorated_tab(i).sll_tuom ;
      oks_bill_util_pub.get_seeded_timeunit(
                               p_timeunit     => l_uom_code ,
                               x_return_status => l_return_status,
                               x_quantity      => l_uom_quantity,
                               x_timeunit      => l_tce_code);

      l_curr_sll_start_date := p_sll_prorated_tab(i).sll_start_date;
      l_curr_sll_end_date   := p_sll_prorated_tab(i).sll_end_date;

      IF l_tce_code = 'DAY' Then
          l_curr_frequency :=  l_curr_sll_end_date - l_curr_sll_start_date + 1;
      ELSIF l_tce_code = 'MONTH' Then
          l_curr_frequency :=  months_between(l_curr_sll_end_date + 1, l_curr_sll_start_date) ;
      ELSIF l_tce_code = 'YEAR' Then
          l_curr_frequency :=  months_between(l_curr_sll_end_date + 1, l_curr_sll_start_date) / 12 ;
      END IF;

      If NVL(l_uom_quantity,0) > 0 Then
          l_curr_frequency := l_curr_frequency / NVL(l_uom_quantity,1);
      END IF;
          --errorout_ad('l_curr_frequency '||l_curr_frequency);
          l_tot_frequency := 0;
          l_next_frequency := 0;

          For j in i+1 .. l_sll_num Loop
            l_next_sll_start_date := p_sll_prorated_tab(j).sll_start_date;
            l_next_sll_end_date   := p_sll_prorated_tab(j).sll_end_date;
            IF l_tce_code = 'DAY' Then
              l_next_frequency :=  l_next_frequency + (l_next_sll_end_date - l_next_sll_start_date + 1);
            ELSIF l_tce_code = 'MONTH' Then
              l_next_frequency :=  l_next_frequency + (months_between(l_next_sll_end_date + 1, l_next_sll_start_date)) ;
            ELSIF l_tce_code = 'YEAR' Then
              l_next_frequency :=  l_next_frequency + (months_between(l_next_sll_end_date + 1, l_next_sll_start_date) / 12) ;
           END IF;


          END LOOP;

          If NVL(l_uom_quantity,0) > 0 Then
             l_next_frequency := l_next_frequency / NVL(l_uom_quantity,1);
           END IF;

          l_tot_frequency := l_tot_frequency + l_curr_frequency + l_next_frequency;
          --errorout_ad('l_tot_frequency '||l_tot_frequency);
          l_sll_period := p_sll_prorated_tab(i).sll_period;


          l_period_sll_amt := ( l_sll_remain_amount /( nvl(l_tot_frequency,1) * nvl(l_sll_period,1))) * nvl(l_curr_frequency,0) ;

          l_period_sll_amt := OKS_EXTWAR_UTIL_PVT.round_currency_amt(l_period_sll_amt, l_currency_code);

          l_sll_remain_amount := l_sll_remain_amount - (l_period_sll_amt * nvl(l_sll_period,1)) ;
              --errorout_ad('l_period_sll_amt '||l_period_sll_amt);
                  --errorout_ad('l_sll_remain_amount '||l_sll_remain_amount);
          p_sll_prorated_tab(i).sll_amount := l_period_sll_amt;
          l_curr_frequency := 0;
    END LOOP;
  END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
 END Calculate_sll_amount;

  /*cgopinee bugfix for 7596241 end*/

  PROCEDURE add_language IS
  BEGIN
    oks_billing_profiles_pvt.add_language;
  END;

  -- Procedure for insert_row
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_bpev_tbl.COUNT > 0 THEN
          i := p_bpev_tbl.FIRST;
          LOOP
            insert_row(
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_bpev_tbl(i)
                       ,x_bpev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_bpev_tbl.LAST);
           i := p_bpev_tbl.NEXT(i);
          END LOOP;
       END IF;
    EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN  bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec            bpev_rec_type := p_bpev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_bpev_rec := l_bpev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     --l_bpev_rec := migrate_bpev(l_bpev_rec, g_bpev_rec);
     l_bpev_rec := g_bpev_rec;

       -- call to complex API procedure
       oks_billing_profiles_pvt.insert_row(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_bpev_rec
                                        ,x_bpev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_bpev_rec := x_bpev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
    END insert_row;


  -- Procedure for lock_row
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_bpev_tbl.COUNT > 0 THEN
          i := p_bpev_tbl.FIRST;
          LOOP
            lock_row(
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_bpev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_bpev_tbl.LAST);
           i := p_bpev_tbl.NEXT(i);
          END LOOP;
       END IF;
    EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END lock_row;

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN  bpev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec            bpev_rec_type := p_bpev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       -- call to complex API procedure
       oks_billing_profiles_pvt.lock_row(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,p_bpev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
    END lock_row;

  -- Procedure for update_row
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_bpev_tbl.COUNT > 0 THEN
          i := p_bpev_tbl.FIRST;
          LOOP
            update_row(
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_bpev_tbl(i)
                       ,x_bpev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_bpev_tbl.LAST);
           i := p_bpev_tbl.NEXT(i);
          END LOOP;
       END IF;
    EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END update_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN  bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec            bpev_rec_type := p_bpev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_bpev_rec := l_bpev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     --l_bpev_rec := migrate_bpev(l_bpev_rec, g_bpev_rec);
     l_bpev_rec := g_bpev_rec;

       -- call to complex API procedure
       oks_billing_profiles_pvt.update_row(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_bpev_rec
                                        ,x_bpev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_bpev_rec := x_bpev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
    END update_row;

  -- Procedure for delete_row
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
       IF p_bpev_tbl.COUNT > 0 THEN
          i := p_bpev_tbl.FIRST;
          LOOP
            delete_row(
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_bpev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_bpev_tbl.LAST);
           i := p_bpev_tbl.NEXT(i);
          END LOOP;
       END IF;
    EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN  bpev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec            bpev_rec_type := p_bpev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_bpev_rec := l_bpev_rec;

     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     --l_bpev_rec := migrate_bpev(l_bpev_rec, g_bpev_rec);
	 l_bpev_rec := g_bpev_rec;
       -- call to complex API procedure
       oks_billing_profiles_pvt.delete_row(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_bpev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_bpev_rec := l_bpev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
    END delete_row;

  -- Procedure for validate_row
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                     NUMBER      := 0;

    BEGIN
       -- initialize the return status
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF p_bpev_tbl.COUNT > 0 THEN
          i := p_bpev_tbl.FIRST;
          LOOP
            validate_row(
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_bpev_tbl(i));

       IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
       END IF;

           EXIT WHEN (i = p_bpev_tbl.LAST);
           i := p_bpev_tbl.NEXT(i);
          END LOOP;
       END IF;
    EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN  bpev_rec_type) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec            bpev_rec_type := p_bpev_rec;

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- Call user hook for BEFORE
     g_bpev_rec := l_bpev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- get values back from hook call
     --l_bpev_rec := migrate_bpev(l_bpev_rec, g_bpev_rec);
     l_bpev_rec := g_bpev_rec;

       -- call to complex API procedure
       oks_billing_profiles_pvt.validate_row(p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,l_bpev_rec);

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

     -- USER HOOK CALL FOR AFTER, STARTS
  	g_bpev_rec := l_bpev_rec;

      	okc_util.call_user_hook(x_return_status  => x_return_status,
       				p_package_name   => g_pkg_name,
       				p_procedure_name => l_api_name,
       				p_before_after   => 'A');

      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        		RAISE OKC_API.G_EXCEPTION_ERROR;
      	END IF;
     -- USER HOOK CALL FOR AFTER, ENDS

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
    END validate_row;


    FUNCTION round_quantity(
             f_target_qty  IN  NUMBER
             )             RETURN NUMBER
    IS

    l_round_quantity    NUMBER;

    BEGIN
-- commented and changed select statement for bug 3497141
 --     SELECT (f_target_qty - ROUND(f_target_qty)) INTO l_round_quantity FROM DUAL ;

         SELECT (f_target_qty - f_target_qty) INTO l_round_quantity FROM DUAL ;
-- end comment and change for bug 3497141
      RETURN l_round_quantity;

    END round_quantity;

--to get time value....

    FUNCTION Create_Timevalue
          (
          l_start_date      IN DATE,
          l_chr_id          IN  NUMBER
          ) RETURN NUMBER Is

      l_p_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
      l_x_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
      l_api_version    NUMBER := 1.0;
      l_init_msg_list  VARCHAR2(1) := 'T';
      l_return_status  VARCHAR2(200);
      l_msg_count      NUMBER;
      l_msg_data       VARCHAR2(2000);
    BEGIN
      l_p_tavv_tbl(1).id                    := NULL;
      l_p_tavv_tbl(1).object_version_number := NULL;
      l_p_tavv_tbl(1).sfwt_flag             := 'N';
      l_p_tavv_tbl(1).spn_id                := NULL;
      l_p_tavv_tbl(1).tve_id_generated_by   := NULL;
      l_p_tavv_tbl(1).dnz_chr_id            := NULL;
      l_p_tavv_tbl(1).tze_id                := NULL;
      l_p_tavv_tbl(1).tve_id_limited        := NULL;
      l_p_tavv_tbl(1).description           := '';
      l_p_tavv_tbl(1).short_description     := '';
      l_p_tavv_tbl(1).comments              := '';
      l_p_tavv_tbl(1).datetime              := to_date(NULL);
      l_p_tavv_tbl(1).attribute_category    := '';
      l_p_tavv_tbl(1).attribute1  := '';
      l_p_tavv_tbl(1).attribute2  := '';
      l_p_tavv_tbl(1).attribute3  := '';
      l_p_tavv_tbl(1).attribute4  := '';
      l_p_tavv_tbl(1).attribute5  := '';
      l_p_tavv_tbl(1).attribute6  := '';
      l_p_tavv_tbl(1).attribute7  := '';
      l_p_tavv_tbl(1).attribute8  := '';
      l_p_tavv_tbl(1).attribute9  := '';
      l_p_tavv_tbl(1).attribute10 := '';
      l_p_tavv_tbl(1).attribute11 := '';
      l_p_tavv_tbl(1).attribute12 := '';
      l_p_tavv_tbl(1).attribute13 := '';
      l_p_tavv_tbl(1).attribute14 := '';
      l_p_tavv_tbl(1).attribute15 := '';
      l_p_tavv_tbl(1).created_by        := NULL;
      l_p_tavv_tbl(1).creation_date     := TO_DATE(NULL);
      l_p_tavv_tbl(1).last_updated_by   := NULL;
      l_p_tavv_tbl(1).last_update_date  := TO_DATE(NULL);
      l_p_tavv_tbl(1).last_update_login := NULL;
      l_p_tavv_tbl(1).datetime          := l_start_date;
      l_p_tavv_tbl(1).dnz_chr_id        := l_chr_id;

      okc_time_pub.create_tpa_value
         (p_api_version   => l_api_version,
          p_init_msg_list => l_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data,
          p_tavv_tbl      => l_p_tavv_tbl,
          x_tavv_tbl      => l_x_tavv_tbl) ;
       If l_return_status <> 'S' then
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Create TPA Value ');
          Raise G_EXCEPTION_HALT_VALIDATION;
       End If;

       RETURN(l_x_tavv_tbl(1).id);

    End Create_Timevalue;
-------------

    PROCEDURE Get_Billing_Schedule(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
       p_billing_profile_rec          IN  Billing_profile_rec,
       x_sll_tbl_out                  OUT NOCOPY Stream_Level_tbl,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2 )

    IS
       CURSOR l_billing_profile_csr(l_billing_profile_id NUMBER) IS
       SELECT BILLING_LEVEL,
            BILLING_TYPE,
            INTERVAL,
            INTERFACE_OFFSET,
            INVOICE_OFFSET,
            INVOICE_OBJECT1_ID1,
--sum, jul,01
            ACCOUNT_OBJECT1_ID1
--sum, jul,01


       FROM   OKS_BILLING_PROFILES_V
       WHERE  ID = l_billing_profile_Id;

       Cursor get_day_uom_code IS
       select uom_code
       from okc_time_code_units_v
       where tce_code='DAY'
       and quantity=1;

       /* cgopinee bugfix for 7596241*/
       CURSOR l_line_amt_csr(p_cle_id NUMBER) IS
       SELECT (nvl(line.price_negotiated,0) +  nvl(dtl.ubt_amount,0) +
                     nvl(dtl.credit_amount,0) +  nvl(dtl.suppressed_credit,0)) line_amt
       FROM okc_k_lines_b line, oks_k_lines_b dtl
       WHERE  line.id = dtl.cle_id AND line.Id = p_cle_id ;

       l_api_version                CONSTANT NUMBER := 1.0;
       l_return_status              VARCHAR2(200);
       l_billing_profile_Csr_Rec    l_billing_profile_csr%Rowtype;
       l_start_date                 p_billing_profile_rec.Start_Date%TYPE;
       l_end_date                   p_billing_profile_rec.End_Date%TYPE;
       l_billing_profile_id         NUMBER;
       l_duration                   NUMBER := 0;
       l_timeunit                   VARCHAR2(10);
       l_source_uom                 VARCHAR2(100) := NULL;
       l_target_qty                 NUMBER;
       f_target_qty                 NUMBER; --used in function
       r_target_qty                 NUMBER; --used for rounded target quantity
       l_sll_index                  NUMBER := 1;
       l_chr_id                     NUMBER;
       l_timevalue_id               NUMBER;
       l_billing_type               VARCHAR2 (450);
       --22-NOV-2005 mchoudha
       --variable declaration for partial periods
       l_price_uom           OKS_K_HEADERS_B.PRICE_UOM%TYPE;
       l_period_start        OKS_K_HEADERS_B.PERIOD_START%TYPE;
       l_period_type         OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
       l_quantity            NUMBER;
       l_uom_code            VARCHAR2(10);


       --new variables for bugfix7596241
       l_amount                     NUMBER;
       l_currency_code              VARCHAR2(15);
       l_sll_prorate_tbl            sll_prorated_tab_type;

-- Bug 5202220

        Cursor csr_get_lse_id (p_cle_id number, p_chr_id number) IS
        select lse_id
        from okc_k_lines_b
        where id = p_cle_id
        and dnz_chr_id = p_chr_id;

        l_lse_id    number;

--End Bug 5202220

    BEGIN
       l_billing_profile_id  := p_billing_profile_rec.Billing_Profile_Id;
       l_start_date          := p_billing_profile_rec.Start_Date;
       l_end_date            := p_billing_profile_rec.End_Date;
       l_chr_id              := p_billing_profile_rec.chr_id;
       --22-NOV-2005 commented by mchoudha. This call is not required due to Rules/Timevalues
       --rearchitecture
       --l_timevalue_id        := create_timevalue(l_start_date,l_chr_id);
       --Partial period changes
       --get the partial period defaults for this contract

       OKS_RENEW_UTIL_PUB.get_period_defaults(p_hdr_id        => l_chr_id,
                                       p_org_id        => NULL,
                                       x_period_type   => l_period_type,
                                       x_period_start  => l_period_start,
                                       x_price_uom     => l_price_uom,
                                       x_return_status => l_return_status);
       IF l_return_status <> 'S' THEN
         Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
      -- to get Periods
      --l_source_uom  is the Interval of oks_billing_profiles_v
       OPEN  l_billing_profile_csr(l_billing_profile_id );
       FETCH l_billing_profile_csr INTO l_billing_profile_Csr_Rec;
       CLOSE l_billing_profile_csr;

       --sll
       x_sll_tbl_out(1).seq_no                    := '1';
       x_sll_tbl_out(1).Start_Date                := l_start_date;
       x_sll_tbl_out(1).amount                    := NULL;
       x_sll_tbl_out(1).sll_Rule_Information_Category := 'SLL';
       x_sll_tbl_out(1).sll_Object1_Id1               := NULL;
       x_sll_tbl_out(1).sll_Object1_Id2               := '#';
       x_sll_tbl_out(1).sll_Jtot_Object1_Code         := 'OKS_TUOM';


       --slh
       x_sll_tbl_out(1).chr_id                    := p_billing_profile_rec.chr_id;
       x_sll_tbl_out(1).cle_id                    := p_billing_profile_rec.cle_id;
       x_sll_tbl_out(1).Billing_type              := l_billing_profile_Csr_Rec.BILLING_LEVEL;
       x_sll_tbl_out(1).stream_type_id1           := '1';
       x_sll_tbl_out(1).stream_type_id2           := '#';
       x_sll_tbl_out(1).stream_tp_code            := 'OKS_STRM_TYPE';
       x_sll_tbl_out(1).slh_timeval_id1           := l_timevalue_id;
       x_sll_tbl_out(1).slh_timeval_id2           := '#';
       x_sll_tbl_out(1).slh_timeval_code          := 'OKS_TIMEVAL';
       x_sll_tbl_out(1).Rule_Information_Category := 'SLH';

       l_source_uom := l_billing_profile_Csr_Rec.INTERVAL;

       x_sll_tbl_out(1).interface_offset    := l_billing_profile_Csr_Rec.INTERFACE_OFFSET;
       x_sll_tbl_out(1).invoice_offset      := l_billing_profile_Csr_Rec.INVOICE_OFFSET;
       x_sll_tbl_out(1).Invoice_Rule_Id     := l_billing_profile_Csr_Rec.INVOICE_OBJECT1_ID1;
--sum, jul,01
       x_sll_tbl_out(1).Account_Rule_Id     := l_billing_profile_Csr_Rec.ACCOUNT_OBJECT1_ID1;
--sum, jul,01


    --Bug 5202220

        Open csr_get_lse_id ( p_billing_profile_rec.cle_id, p_billing_profile_rec.chr_id);
        Fetch csr_get_lse_id into l_lse_id;
        Close csr_get_lse_id;

       IF l_period_start IS NOT NULL AND
	l_period_type IS NOT NULL  AND
	l_lse_id = 12
      THEN
        l_period_start := 'SERVICE';
      END IF;

     --End Bug 5202220

      IF l_billing_profile_Csr_Rec.BILLING_TYPE = 'ONETIME' THEN
        --partial periods changes
         IF l_period_start ='CALENDAR' AND l_period_type is not null THEN
	   Open get_day_uom_code;
	   Fetch get_day_uom_code into l_uom_code;
	   Close get_day_uom_code;
           x_sll_tbl_out(1).target_quantity := 1;
           x_sll_tbl_out(1).duration          := l_end_date-l_start_date+1; --UOM/PERIOD
           x_sll_tbl_out(1).timeunit          := l_uom_code; -- UOM

         ELSE
           x_sll_tbl_out(1).target_quantity := 1;
           OKC_TIME_UTIL_PUB.get_duration(
                             p_start_date    => l_start_date
                           , p_end_date      => l_end_date
                           , x_duration      => l_duration
                           , x_timeunit      => l_timeunit
                           , x_return_status => x_return_status);

           x_sll_tbl_out(1).duration          := l_duration; --UOM/PERIOD
           x_sll_tbl_out(1).timeunit          := l_timeunit; -- UOM
	 END IF;
      ELSE
      IF l_billing_profile_Csr_Rec.BILLING_TYPE = 'RECURRING' THEN
        --partial periods changes
        IF l_period_start ='CALENDAR' AND l_period_type is not null THEN
           IF  l_source_uom is not null THEN
  	     l_quantity:=OKS_BILL_UTIL_PUB.Get_Periods
                          (
                           p_start_date   => l_start_date,
                           p_end_date     => l_end_date,
                           p_uom_code     => l_source_uom,
                           p_period_start => l_period_start
			   );
             x_sll_tbl_out(1).target_quantity := l_quantity;
             x_sll_tbl_out(1).duration          := 1; --UOM/PERIOD
             x_sll_tbl_out(1).timeunit          := l_source_uom; -- UOM

          END IF;
        ELSE
          l_target_qty := OKS_TIME_MEASURES_PUB.get_quantity(
                            l_start_date
                          , l_end_date
                          , l_source_uom);

          r_target_qty := round_quantity( f_target_qty => l_target_qty);
          IF r_target_qty = 0 THEN  -- i.e get_quantity returns a whole number
            -- added function ceil to the variable l_target_qty for bug 3497141
            x_sll_tbl_out(1).target_quantity    := ceil(l_target_qty);
            x_sll_tbl_out(1).duration           := 1; --UOM/PERIOD
            x_sll_tbl_out(1).timeunit           := l_source_uom; -- UOM

          ELSE
           x_sll_tbl_out(1).target_quantity := 1;
           OKC_TIME_UTIL_PUB.get_duration(
                             p_start_date    => l_start_date
                           , p_end_date      => l_end_date
                           , x_duration      => l_duration
                           , x_timeunit      => l_timeunit
                           , x_return_status => x_return_status);


           x_sll_tbl_out(1).duration          := l_duration; --UOM/PERIOD
           x_sll_tbl_out(1).timeunit          := l_timeunit; -- UOM
          END IF;
        END IF;   -- l_period_start check
      END IF;
      END IF;

--slh record
     /*CGOPINEE Bugfix for 7596241 start*/

     l_sll_prorate_tbl.DELETE;

     l_sll_prorate_tbl(1).sll_seq_num := 1;
     l_sll_prorate_tbl(1).sll_start_date := l_start_date;
     l_sll_prorate_tbl(1).sll_end_date   := l_end_date;
     l_sll_prorate_tbl(1).sll_tuom       := x_sll_tbl_out(1).timeunit;
     l_sll_prorate_tbl(1).sll_period     := x_sll_tbl_out(1).target_quantity;
     l_sll_prorate_tbl(1).sll_uom_per_period := x_sll_tbl_out(1).duration;

     l_currency_code := Find_Currency_Code(
                          p_cle_id  => p_billing_profile_rec.cle_id,
                          p_chr_id  => p_billing_profile_rec.chr_id);

     IF (p_billing_profile_rec.cle_id IS NOT  NULL) THEN
         OPEN l_line_amt_csr(p_billing_profile_rec.cle_id);
         FETCH l_line_amt_csr INTO l_amount;
         CLOSE l_line_amt_csr;
    ELSE
         RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

     CALCULATE_SLL_AMOUNT(
                      P_API_VERSION      => l_api_version,
	 	      P_TOTAL_AMOUNT     => l_amount,
                      P_CURRENCY_CODE    => l_currency_code,
		      p_period_start     => l_period_start,
                      p_period_type      => l_period_type,
                      P_SLL_PRORATED_TAB => l_sll_prorate_tbl,
		      X_RETURN_STATUS    => X_RETURN_STATUS);

     IF X_RETURN_STATUS='S' THEN
        x_sll_tbl_out(1).amount              := l_sll_prorate_tbl(1).sll_amount;
     END IF;
     /*CGOPINEE Bugfix for 7596241 end*/

   EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
   WHEN OTHERS THEN
     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME_OKC,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => sqlcode,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => sqlerrm);

     x_return_status := G_RET_STS_UNEXP_ERROR;
   END;

END OKS_BILLING_PROFILES_PUB;

/
