--------------------------------------------------------
--  DDL for Package Body OKC_QA_GENERAL_CHECKLISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_GENERAL_CHECKLISTS" AS
/* $Header: OKCRQAGB.pls 120.0 2005/05/27 05:17:52 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  --
  G_PACKAGE  Varchar2(33) := '  OKC_QA_GENERAL_CHECKLISTS.';
  --
  --
PROCEDURE check_euro_currency(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS
/*
  This will check if the currency for an entered contract is not created in NCU and must
  be EURO
*/

  cursor csr_contracts is
  select currency_code, sts_code
  from okc_k_headers_b
  where id = p_chr_id;

l_currency_code    VARCHAR2(10);
l_sts_code    VARCHAR2(20);
l_euro_currency_code    VARCHAR2(10);
l_return_status varchar2(1):='S';
   --
   l_proc varchar2(72) := g_package||'check_euro_currency';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('100: Entering ',2);
  END IF;

  x_return_status := 'S';

  OPEN csr_contracts;
  FETCH csr_contracts INTO l_currency_code, l_sts_code;
  l_euro_currency_code := OKC_CURRENCY_API.GET_EURO_CURRENCY_CODE(l_currency_code);
  CLOSE csr_contracts;
  if (l_euro_currency_code <> l_currency_code)  and
      l_sts_code = 'ENTERED' then
    OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => 'OKC_EURO_CHECK_FAIL');
         x_return_status := OKC_API.G_RET_STS_ERROR;
  ELSE
   OKC_API.set_message(
         p_app_name      => G_APP_NAME,
         p_msg_name      => G_QA_SUCCESS);
  END IF;
  IF (l_debug = 'Y') THEN
     okc_debug.Log('200: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('300: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    if csr_contracts%ISOPEN then
      close csr_contracts;
    end if;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end check_euro_currency;

-- Bug 2041448, skekkar

FUNCTION GET_EMAIL_FROM_JTFV(
		p_object_code IN VARCHAR2,
		p_id1 IN VARCHAR2,
		p_id2 IN VARCHAR2)
RETURN VARCHAR2 IS
	l_email  VARCHAR2(2000);
	l_from_table VARCHAR2(200);
	l_where_clause VARCHAR2(2000);
	l_sql_stmt VARCHAR2(2000);
	l_not_found BOOLEAN;

	Cursor jtfv_csr IS
		SELECT FROM_TABLE, WHERE_CLAUSE
		FROM JTF_OBJECTS_B
		WHERE OBJECT_CODE = p_object_code;

	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into l_from_table, l_where_clause;
	l_not_found := jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If (l_not_found) Then
		return NULL;
	End if;

       	      l_sql_stmt := 'SELECT email_address FROM ' || l_from_table ||
			    ' WHERE ID1 = :id_1 AND ID2 = :id2';
	      If (l_where_clause is not null) Then
	          l_sql_stmt := l_sql_stmt || ' AND (' || l_where_clause || ')';
	    End If;
           open c for l_sql_stmt using p_id1, p_id2;
        fetch c into l_email;
        l_not_found := c%NOTFOUND;
        close c;

	If (l_not_found) Then
	   return NULL;
	End if;

	return l_email;
EXCEPTION
  when NO_DATA_FOUND then
	  If (jtfv_csr%ISOPEN) Then
		Close jtfv_csr;
	  End If;
	  If (c%ISOPEN) Then
		Close c;
	  End If;
	  return NULL;
END;

-- skekkar

--  Bug 2041448 , skekkar

  -- Start of comments
  --
  -- Procedure Name  : check_email_address
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_email_address(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS
/*
  This will check that for a contract there is alteast 1 party contact defined with an
  email address. If not it will issue a warning message
*/

  cursor csr_contacts is
  select c.jtot_object1_code, c.object1_id1, c.object1_id2
    from okc_contacts c, okc_k_party_roles_b p
   where c.cpl_id = p.id
     and p.dnz_chr_id = p_chr_id
     and p.cle_id is null;

l_jtot_object1_code  VARCHAR2(200);
l_object1_id1        VARCHAR2(200);
l_object1_id2        VARCHAR2(200);

l_email_address    VARCHAR2(2000);
l_return_status varchar2(1):='S';
l_email_found   varchar2(1):= 'N';
   --
   l_proc varchar2(72) := g_package||'check_email_address';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('400: Entering ',2);
  END IF;

  x_return_status := 'S';

  OPEN csr_contacts;
    LOOP
      FETCH csr_contacts INTO l_jtot_object1_code, l_object1_id1, l_object1_id2 ;
      EXIT WHEN csr_contacts%NOTFOUND;
         IF (l_debug = 'Y') THEN
            okc_debug.Log('410: l_jtot_object1_code : '||l_jtot_object1_code,2);
            okc_debug.Log('420: l_object1_id1 : '||l_object1_id1,2);
            okc_debug.Log('430: l_object1_id2 : '||l_object1_id2,2);
         END IF;
        -- get the email address
        l_email_address := GET_EMAIL_FROM_JTFV( l_jtot_object1_code, l_object1_id1, l_object1_id2);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('440: Email Address : '||l_email_address,2);
        END IF;
        IF l_email_address IS NOT NULL THEN
           -- we got atleast 1 record with email address, so exit loop
          l_email_found := 'Y';
          EXIT;
        END IF;
    END LOOP;
  CLOSE csr_contacts;

   --
   --  issue a warning if no records with email address
   --
       IF l_email_found = 'N' THEN
          OKC_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKC_EMAIL_ADD_WARN');
               -- notify caller of an error
               -- x_return_status := OKC_API.G_RET_STS_WARNING;
               x_return_status := OKC_API.G_RET_STS_ERROR;
       ELSE
          OKC_API.set_message(
                p_app_name      => G_APP_NAME,
                p_msg_name      => G_QA_SUCCESS);
       END IF;  -- l_email_found = 'N'

  IF (l_debug = 'Y') THEN
     okc_debug.Log('500: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('600: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    if csr_contacts%ISOPEN then
      close csr_contacts;
    end if;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end check_email_address;
--
--
--  Bug 2077501 , skekkar

  -- Start of comments
  --
  -- Procedure Name  : check_email_address_role
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_email_address_role(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER,
    p_rle_code                 IN  VARCHAR2
  ) IS
/*
  This will check that for a contract there is alteast 1 party contact defined with an
  email address. If not it will issue a warning message
*/


  cursor csr_contacts(p_cpl_id Number) is
  select c.jtot_object1_code, c.object1_id1, c.object1_id2
    from okc_contacts c
   where c.cpl_id = p_cpl_id
     and c.dnz_chr_id = p_chr_id;

  cursor csr_rle is
  select id
    from okc_k_party_roles_b
   where rle_code = p_rle_code
     and dnz_chr_id = p_chr_id
     and cle_id is null;

/*  cursor csr_con_exist is
  select 'X'
  from okc_contacts c, okc_k_party_roles_b p
  where p.id = c.cpl_id
    and p.dnz_chr_id = p_chr_id
    and p.rle_code   = p_rle_code; */

l_cpl_id okc_k_party_roles_b.id%TYPE;
l_jtot_object1_code  VARCHAR2(200);
l_object1_id1        VARCHAR2(200);
l_object1_id2        VARCHAR2(200);

l_rle_not_found Boolean := True;
l_ctc_not_found Boolean := True;
l_email_address    VARCHAR2(2000);
l_return_status varchar2(1):='S';
l_email_found   varchar2(1):= 'N';

   --
   l_proc varchar2(72) := g_package||'check_email_address_role';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('700: Entering ',2);
  END IF;

  x_return_status := 'S';

  -- check if the contract has that role
  OPEN csr_rle;
  Loop
    FETCH csr_rle INTO l_cpl_id;
    Exit When csr_rle%NotFound;
    l_rle_not_found := False;
    OPEN csr_contacts(l_cpl_id);
    LOOP
      FETCH csr_contacts INTO l_jtot_object1_code, l_object1_id1, l_object1_id2 ;
      EXIT WHEN csr_contacts%NOTFOUND;
      l_ctc_not_found := False;
      IF (l_debug = 'Y') THEN
         okc_debug.Log('710: l_jtot_object1_code : '||l_jtot_object1_code,2);
         okc_debug.Log('720: l_object1_id1 : '||l_object1_id1,2);
         okc_debug.Log('730: l_object1_id2 : '||l_object1_id2,2);
      END IF;
      -- get the email address
      l_email_address := GET_EMAIL_FROM_JTFV(l_jtot_object1_code,
                                             l_object1_id1,
                                             l_object1_id2);
      IF (l_debug = 'Y') THEN
         okc_debug.Log('740: Email Address : '||l_email_address,2);
      END IF;
      IF l_email_address IS NOT NULL THEN
        -- we got atleast 1 record with email address, so exit loop
        l_email_found := 'Y';
        EXIT;
      END IF;
    END LOOP;
    CLOSE csr_contacts;
    If l_email_found = 'Y' Then
      Exit;
    End If;
  END LOOP;
  CLOSE csr_rle;
  --
  -- Set the error message if no role for the contract
  --
  If l_rle_not_found Then
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_EMAIL_NO_ROLE',
                        p_token1       => 'ROLE',
                        p_token1_value => okc_util.decode_lookup('OKC_ROLE',p_rle_code));
    -- notify caller of an warning
    x_return_status := OKC_API.G_RET_STS_WARNING;
    Raise G_EXCEPTION_HALT_VALIDATION;
  END IF; -- role exists
  --
  -- Set the error messages if no contact for the role
  --
  If l_ctc_not_found Then
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_EMAIL_NO_CONTACT',
                        p_token1       => 'ROLE',
                        p_token1_value => okc_util.decode_lookup('OKC_ROLE',p_rle_code));
    -- notify caller of an warning
    x_return_status := OKC_API.G_RET_STS_WARNING;
    Raise G_EXCEPTION_HALT_VALIDATION;
  END IF; -- contact exists
  --
  --  issue a warning if no records with email address
  --
  IF l_email_found = 'N' THEN
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_EMAIL_ADD_WARN_RLE',
                        p_token1       => 'ROLE',
                        p_token1_value => okc_util.decode_lookup('OKC_ROLE',p_rle_code));
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    Raise G_EXCEPTION_HALT_VALIDATION;
  END IF;  -- l_email_found = 'N'
  -- QA passed
  OKC_API.set_message(p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKC_EMAIL_ADD_SUCC_RLE',
                      p_token1       => 'ROLE',
                      p_token1_value => okc_util.decode_lookup('OKC_ROLE',p_rle_code));

  IF (l_debug = 'Y') THEN
     okc_debug.Log('800: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION Then
    IF (l_debug = 'Y') THEN
       okc_debug.Log('850: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('900: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    if csr_rle%ISOPEN then
      close csr_rle;
    end if;
    if csr_contacts%ISOPEN then
      close csr_contacts;
    end if;
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end check_email_address_role;

--  skekkar
--

END OKC_QA_GENERAL_CHECKLISTS;

/
