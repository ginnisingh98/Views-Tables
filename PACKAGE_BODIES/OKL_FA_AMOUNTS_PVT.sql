--------------------------------------------------------
--  DDL for Package Body OKL_FA_AMOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FA_AMOUNTS_PVT" AS
/* $Header: OKLRAAMB.pls 120.2 2006/07/12 08:49:56 dpsingh noship $ */
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the asset id and book type code as inputs and
--               returns the Oracle fixed asset amounts in contract currency
-- IN Parameters : p_asset_id - asset id
--                 p_book_type_code - book_type code
-- OUT Parameters :
--                 x_cost                 FA current cost
--                 x_adj_cost             FA adjusted cost
--                 x_original_cost        FA original cost
--                 x_salvage_value        FA salvage value
--                 x_recoverable_cost     FA recoverable cost
--                 x_adj_recoverable_cost FA adjusted recoverable cost
--End of comments
--------------------------------------------------------------------------------
Procedure convert_fa_amounts
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_asset_id             IN  NUMBER,
                   p_book_type_code       IN  VARCHAR2,
                   x_cost                 OUT NOCOPY NUMBER,
                   x_adj_cost             OUT NOCOPY NUMBER,
                   x_original_cost        OUT NOCOPY NUMBER,
                   x_salvage_value        OUT NOCOPY NUMBER,
                   x_recoverable_cost     OUT NOCOPY NUMBER,
                   x_adj_recoverable_cost OUT NOCOPY NUMBER) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CONVERT_FA_AMOUNTS';
l_api_version          CONSTANT NUMBER := 1.0;


Cursor conv_params_csr(assetid NUMBER) is
Select khr.CURRENCY_CODE CONTRACT_CURRENCY_CODE,
       khr.CURRENCY_CONVERSION_TYPE,
       khr.CURRENCY_CONVERSION_RATE,
       khr.CURRENCY_CONVERSION_DATE,
       khr.AUTHORING_ORG_ID,
       aopt.SET_OF_BOOKS_ID,
       sob.CURRENCY_CODE FUNCTIONAL_CURRENCY_CODE
FROM   GL_LEDGERS_PUBLIC_V      sob,
       OKL_SYS_ACCT_OPTS    aopt,
       OKL_K_HEADERS_FULL_V khr,
       OKC_K_LINES_B        cle,
       OKC_LINE_STYLES_B    lse,
       OKC_K_ITEMS          cim
WHERE  sob.ledger_id   = aopt.set_of_books_id
and    aopt.org_id           = khr.authoring_org_id
and    khr.id                = cle.dnz_chr_id
and    cle.id                = cim.cle_id
and    cle.dnz_chr_id        = cim.dnz_chr_id
and    cle.lse_id            = lse.id
and    lse.lty_code          = 'FIXED_ASSET'
and    cim.object1_id1       = to_char(assetid)
and    cim.object1_id2       = '#'
and    cim.jtot_object1_code = 'OKX_ASSET';

l_conv_params_rec  conv_params_csr%RowType;


Cursor fa_amounts_csr (assetid NUMBER,
                       bookcode VARCHAR2) is
Select cost,
       adjusted_cost,
       original_cost,
       salvage_value,
       recoverable_cost,
       adjusted_recoverable_cost
from   FA_BOOKS
where  asset_id       = assetid
and    book_type_code = bookcode
and    transaction_header_id_out is null
and    date_ineffective is null;

l_fa_amounts_rec fa_amounts_csr%rowtype;

l_cost                 NUMBER;
l_adj_cost             NUMBER;
l_original_cost        NUMBER;
l_salvage_value        NUMBER;
l_recoverable_cost     NUMBER;
l_adj_recoverable_cost NUMBER;

l_inv_conv_rate        NUMBER;
begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
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

     open conv_params_csr(p_asset_id);
     Fetch conv_params_csr into l_conv_params_rec;
     if conv_params_csr%notfound then
         null;
         --raise error currency parameters not found
     else
         open fa_amounts_csr(p_asset_id, p_book_type_code);
         fetch  fa_amounts_csr into l_fa_amounts_rec;
         if  fa_amounts_csr%notfound then
             null;
             --raise error fa data not found
         elsif l_conv_params_rec.contract_currency_code = l_conv_params_rec.functional_currency_code then
             l_cost                 := l_fa_amounts_rec.cost;
             l_adj_cost             := l_fa_amounts_rec.adjusted_cost;
             l_original_cost        := l_fa_amounts_rec.original_cost;
             l_salvage_value        := l_fa_amounts_rec.salvage_value;
             l_recoverable_cost     := l_fa_amounts_rec.recoverable_cost;
             l_adj_recoverable_cost := l_fa_amounts_rec.adjusted_recoverable_cost;
         elsif l_conv_params_rec.contract_currency_code <> l_conv_params_rec.functional_currency_code then
             If upper(l_conv_params_rec.currency_conversion_type) <> 'USER' Then
                 If l_conv_params_rec.currency_conversion_type is null OR
                 --conv_params_csr.currency_conversion_rate is null OR
                    l_conv_params_rec.currency_conversion_date is null then
                        null;
                        --raise error : currency conversion parameters not available;
                 else
                     l_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.cost);
                      l_adj_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.adjusted_cost);
                      l_original_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.original_cost);
                      l_salvage_value := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.salvage_value);
                      l_recoverable_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.recoverable_cost);
                      l_adj_recoverable_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.functional_currency_code,
		                           x_to_currency	  => l_conv_params_rec.CONTRACT_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_fa_amounts_rec.adjusted_recoverable_cost);
                    end if;
                Elsif upper(l_conv_params_rec.currency_conversion_type) = 'USER' then
                    If l_conv_params_rec.currency_conversion_rate is null then
                        null;
                        --raise error : need a rate
                    Else
                        l_inv_conv_rate        := (1/l_conv_params_rec.currency_conversion_rate);
                        l_cost                 := l_inv_conv_rate * l_fa_amounts_rec.cost;
                        l_adj_cost             := l_inv_conv_rate * l_fa_amounts_rec.adjusted_cost;
                        l_original_cost        := l_inv_conv_rate * l_fa_amounts_rec.original_cost;
                        l_salvage_value        := l_inv_conv_rate * l_fa_amounts_rec.salvage_value;
                        l_recoverable_cost     := l_inv_conv_rate * l_fa_amounts_rec.recoverable_cost;
                        l_adj_recoverable_cost := l_inv_conv_rate * l_fa_amounts_rec.adjusted_recoverable_cost;
                    End If;
                End If;
            end If;
            close fa_amounts_csr;
     end if;
     close conv_params_csr;


     l_cost                 := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_cost, l_conv_params_rec.CONTRACT_CURRENCY_CODE);
     l_adj_cost             := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_adj_cost, l_conv_params_rec.CONTRACT_CURRENCY_CODE);
     l_original_cost        := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_original_cost, l_conv_params_rec.CONTRACT_CURRENCY_CODE);
     l_salvage_value        := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_salvage_value, l_conv_params_rec.CONTRACT_CURRENCY_CODE);
     l_recoverable_cost     := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_recoverable_cost, l_conv_params_rec.CONTRACT_CURRENCY_CODE);
     l_adj_recoverable_cost := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_adj_recoverable_cost, l_conv_params_rec.CONTRACT_CURRENCY_CODE);


     x_cost                 := l_cost;
     x_adj_cost             := l_adj_cost;
     x_original_cost        := l_original_cost;
     x_salvage_value        := l_salvage_value;
     x_recoverable_cost     := l_recoverable_cost;
     x_adj_recoverable_cost := l_adj_recoverable_cost;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
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
end convert_fa_amounts;
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the OKL finacial asset line id as input and
--               returns the Oracle fixed asset CORP Bok amounts in contract currency
-- IN Parameters : p_fin_asset_id - Financial asset line id. (OKL fin asset top
--                                  line id
-- OUT Parameters :
--                 x_cost                 FA current cost
--                 x_adj_cost             FA adjusted cost
--                 x_original_cost        FA original cost
--                 x_salvage_value        FA salvage value
--                 x_recoverable_cost     FA recoverable cost
--                 x_adj_recoverable_cost FA adjusted recoverable cost
--End of comments
--------------------------------------------------------------------------------
Procedure convert_fa_amounts
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_fin_ast_id           IN  NUMBER,
                   x_cost                 OUT NOCOPY NUMBER,
                   x_adj_cost             OUT NOCOPY NUMBER,
                   x_original_cost        OUT NOCOPY NUMBER,
                   x_salvage_value        OUT NOCOPY NUMBER,
                   x_recoverable_cost     OUT NOCOPY NUMBER,
                   x_adj_recoverable_cost OUT NOCOPY NUMBER) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CONVERT_FA_AMOUNTS';
l_api_version          CONSTANT NUMBER := 1.0;


CURSOR fixed_Ast_csr(finastid NUMBER) is
SELECT to_number(cim.object1_id1)
FROM   okc_k_items  cim,
       fa_additions fa,
       okc_k_lines_b  cle
where  fa.asset_id           = to_number(cim.object1_id1)
and    cim.object1_id2       = '#'
and    cim.jtot_object1_code = 'OKX_ASSET'
and    cim.cle_id            = cle.id
and    cim.dnz_chr_id        = cle.dnz_chr_id
and    cle.cle_id            = finastid;

l_asset_id    NUMBER;

CURSOR Corp_Book_csr (asstid NUMBER) is
SELECT fab.book_type_code
FROM   FA_BOOKS FAB,
       FA_BOOK_CONTROLS FBC
WHERE  fab.book_type_code = fbc.book_type_code
AND    fbc.book_class     = 'CORPORATE'
AND    fab.asset_id       = asstid
AND    fab.transaction_header_id_out is null
AND    fab.date_ineffective is null;

l_book_type_code  varchar2(15);

l_cost                 NUMBER;
l_adj_cost             NUMBER;
l_original_cost        NUMBER;
l_salvage_value        NUMBER;
l_recoverable_cost     NUMBER;
l_adj_recoverable_cost NUMBER;

Begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
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

    --get fixed asset
    Open fixed_Ast_csr(p_fin_ast_id);
    Fetch fixed_Ast_csr into  l_asset_id;
    If  fixed_Ast_csr%NOTFOUND then
        Null;
    End If;
    Close fixed_Ast_csr;

    --get book_type_code
    Open Corp_Book_csr(l_asset_id);
    Fetch Corp_Book_csr into  l_book_type_code;
    If  Corp_Book_csr%NOTFOUND then
        Null;
    End If;
    Close Corp_Book_csr;

    --dbms_output.put_line('calling api with '||to_char(l_asset_id)||' '||l_book_type_code);
    okl_fa_amounts_pvt.convert_fa_amounts
                  (p_api_version          => p_api_version,
                   p_init_msg_list        => p_init_msg_list,
                   x_return_status        => x_return_status,
                   x_msg_count            => x_msg_count,
                   x_msg_data             => x_msg_data,
                   p_asset_id             => l_asset_id,
                   p_book_type_code       => l_book_type_code,
                   x_cost                 => l_cost,
                   x_adj_cost             => l_adj_cost,
                   x_original_cost        => l_original_cost,
                   x_salvage_value        => l_salvage_value,
                   x_recoverable_cost     => l_recoverable_cost,
                   x_adj_recoverable_cost => l_adj_recoverable_cost);
      -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_cost                 := l_cost;
    x_adj_cost             := l_adj_cost;
    x_original_cost        := l_original_cost;
    x_salvage_value        := l_salvage_value;
    x_recoverable_cost     := l_recoverable_cost;
    x_adj_recoverable_cost := l_adj_recoverable_cost;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
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

end  convert_fa_amounts;
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the OKL finacial asset line id, asset cost and salvage value in
--               contract currency as input and
--               returns cost and salvage value amounts in functional currency
-- IN Parameters : p_fin_asset_id    - Financial asset line id. (OKL fin asset top
--                                     line id
--                 p_k_cost          - contract cost in contract currency
--                 p_k_salvage_value - contract salvage value in contract currency
-- OUT Parameters :
--                 x_fa_cost                 FA current cost in functional currency
--                 x_fa_salvage_value        FA salvage value in functional currency
--End of comments
--------------------------------------------------------------------------------
Procedure convert_okl_amounts
                   (p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2,
                    p_fin_ast_id           IN  NUMBER,
                    p_okl_cost             IN  NUMBER,
                    p_okl_salvage_value    IN  NUMBER,
                    x_fa_cost              OUT NOCOPY NUMBER,
                    x_fa_salvage_value     OUT NOCOPY NUMBER) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CONVERT_OKL_AMOUNTS';
l_api_version          CONSTANT NUMBER := 1.0;

Cursor conv_params_csr(finassetid NUMBER) is
Select khr.CURRENCY_CODE CONTRACT_CURRENCY_CODE,
       khr.CURRENCY_CONVERSION_TYPE,
       khr.CURRENCY_CONVERSION_RATE,
       khr.CURRENCY_CONVERSION_DATE,
       khr.AUTHORING_ORG_ID,
       khr.DEAL_TYPE,
       aopt.SET_OF_BOOKS_ID,
       sob.CURRENCY_CODE FUNCTIONAL_CURRENCY_CODE
FROM   GL_LEDGERS_PUBLIC_V      sob,
       OKL_SYS_ACCT_OPTS    aopt,
       OKL_K_HEADERS_FULL_V khr,
       OKC_K_LINES_B        cle,
       OKC_LINE_STYLES_B    lse
WHERE  sob.ledger_id   = aopt.set_of_books_id
and    aopt.org_id           = khr.authoring_org_id
and    khr.id                = cle.dnz_chr_id
and    khr.id                = cle.chr_id
and    cle.lse_id            = lse.id
and    lse.lty_code          = 'FREE_FORM1'
and    cle.id                = finassetid;

l_conv_params_rec    conv_params_csr%ROWTYPE;

Cursor okl_amt_csr(finassetid NUMBER) is
Select kle.OEC,
       kle.RESIDUAL_VALUE
from   OKL_K_LINES KLE
where  kle.id = finassetid;

l_oec                  OKL_K_LINES.OEC%TYPE;
l_residual_value       OKL_K_LINES.RESIDUAL_VALUE%TYPE;

l_okl_cost             NUMBER;
l_okl_salvage_value    NUMBER;

l_fa_cost              NUMBER;
l_fa_salvage_value     NUMBER;
begin
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
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

    open conv_params_csr(p_fin_ast_id);
        Fetch conv_params_csr into l_conv_params_rec;
        if conv_params_csr%notfound then
            null;
            --raise error currency parameters not found
        End if;
    close conv_params_csr;

    If (p_okl_cost is null) OR (p_okl_salvage_value is null) then
        --get OEC from top line
        Open okl_amt_csr(p_fin_ast_id);
        fetch okl_amt_csr into l_oec, l_residual_value;
        If okl_amt_csr%NOTFOUND then
            null;
            --error!!
        End If;
        Close okl_amt_csr;
    End If;

    If p_okl_cost is null then
        l_okl_cost := l_oec;
    else
        l_okl_cost := p_okl_cost;
    end if;

    If l_conv_params_rec.deal_type = 'LEASEOP' then
        If nvl(p_okl_salvage_value,0) = 0 Then
            l_okl_salvage_value := l_residual_value;
        Else
            l_okl_salvage_value := nvl(p_okl_salvage_value,0);
        End If;
    Else
        l_okl_salvage_value := nvl(p_okl_salvage_value,0);
    End If;
    --dbms_output.put_line('cost :' ||to_char(l_okl_cost));
    --dbms_output.put_line('salvage value :' ||to_char(l_okl_salvage_value));
    if l_conv_params_rec.contract_currency_code = l_conv_params_rec.functional_currency_code then
        l_fa_cost := l_okl_cost;
        l_fa_salvage_value := l_okl_salvage_value;
    elsif l_conv_params_rec.contract_currency_code <> l_conv_params_rec.functional_currency_code then
        If upper(l_conv_params_rec.currency_conversion_type) <> 'USER' Then
            If  l_conv_params_rec.currency_conversion_type is null OR
                l_conv_params_rec.currency_conversion_date is null then
                null;
                --raise error : currency conversion parameters not available;
            else
                l_fa_cost := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.contract_currency_code,
		                           x_to_currency	  => l_conv_params_rec.FUNCTIONAL_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_okl_cost);
                l_fa_salvage_value := GL_CURRENCY_API.convert_amount (
		                           x_from_currency    => l_conv_params_rec.contract_currency_code,
		                           x_to_currency	  => l_conv_params_rec.FUNCTIONAL_CURRENCY_CODE,
		                           x_conversion_date  => l_conv_params_rec.currency_conversion_date,
		                           x_conversion_type  => l_conv_params_rec.currency_conversion_type,
		                           x_amount		      => l_okl_salvage_value);
            end if;
        Elsif upper(l_conv_params_rec.currency_conversion_type) = 'USER' Then
            If l_conv_params_rec.currency_conversion_rate is null then
                null;
                --raise error : need a rate
            Else
                l_fa_cost       := l_conv_params_rec.currency_conversion_rate * l_okl_cost;
                l_fa_salvage_value := l_conv_params_rec.currency_conversion_rate * l_okl_salvage_value;
            End If;
        End If;
    End If;


    l_fa_cost := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_fa_cost,l_conv_params_rec.FUNCTIONAL_CURRENCY_CODE);
    l_fa_salvage_value := okl_accounting_util.CROSS_CURRENCY_ROUND_AMOUNT(l_fa_salvage_value,l_conv_params_rec.FUNCTIONAL_CURRENCY_CODE);


    x_fa_cost := l_fa_cost;
    x_fa_salvage_value := l_fa_salvage_value;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
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

end convert_okl_amounts;

end okl_fa_amounts_pvt;

/
