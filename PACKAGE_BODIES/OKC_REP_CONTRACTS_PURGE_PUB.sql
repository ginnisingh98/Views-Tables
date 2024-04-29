--------------------------------------------------------
--  DDL for Package Body OKC_REP_CONTRACTS_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_CONTRACTS_PURGE_PUB" AS
/*$Header: OKCREPPURGEB.pls 120.0.12010000.3 2013/12/05 09:53:27 skavutha noship $*/

PROCEDURE delete_contacts(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_contacts';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_contacts for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_PARTY_CONTACTS ');

      DELETE FROM OKC_REP_PARTY_CONTACTS
          WHERE CONTRACT_ID = p_contract_id;


      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_PARTY_CONTACTS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_PARTY_CONTACTS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_contacts for the repository contract :' || p_contract_id || 'is successful');

END delete_contacts;

PROCEDURE delete_parties(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_parties';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_parties for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_PARTIES ');

      DELETE FROM OKC_REP_CONTRACT_PARTIES
          WHERE CONTRACT_ID = p_CONTRACT_ID;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_PARTIES is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_PARTIES is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_parties for the repository contract :' || p_contract_id || 'is successful');

END delete_parties;

PROCEDURE delete_terms(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_terms';
  x_msg_data         VARCHAR2(2500);
  x_msg_count        NUMBER;

  CURSOR cur_all_versions IS
      SELECT CONTRACT_VERSION_NUM version
        FROM okc_rep_contract_vers
       WHERE CONTRACT_ID = p_contract_id
         AND CONTRACT_TYPE = p_contract_type;

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_terms for the repository contract :' || p_contract_id);

    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting terms records');
      FND_FILE.PUT_LINE(FND_FILE.Log, '-*-*-*-*-*-*-*-*-******************************************-*-*-*-*-*-*-');

      FND_FILE.PUT_LINE(FND_FILE.Log, 'Deleting the terms for the active version');
      OKC_TERMS_UTIL_PVT.Delete_Doc(
	            p_doc_type       => p_contract_type,
	            p_doc_id         => p_contract_id,
              x_return_status  => x_return_status
	      );

         -----------------------------------------------------
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        --------------------------------------------------------

      FOR ver_rec IN cur_all_versions
      LOOP
        FND_FILE.PUT_LINE(FND_FILE.Log, '----------------------------------------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.Log, 'Deleting the terms for the version: '|| ver_rec.version);

        OKC_TERMS_VERSION_PVT.Delete_Doc_Version(
	                p_doc_type       => p_contract_type,
	                p_doc_id         => p_contract_id,
	                p_version_number => ver_rec.version,
                  x_return_status  => x_return_status
	          );

        -----------------------------------------------------
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        --------------------------------------------------------

        FND_FILE.PUT_LINE(FND_FILE.Log, '----------------------------------------------------------------------------');
      END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.Log, '-*-*-*-*-*-*-*-*-******************************************-*-*-*-*-*-*-');
  EXCEPTION
      WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting terms is failed.');
      x_err_msg := 'OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables call has errored out.';
      x_return_status := 'E';
  END;


  IF x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting terms records has failed.');
      x_err_msg := 'OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables call is not successful.';
  ELSE
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting the terms for the repository contract :' || p_contract_id || 'is successful');
      x_return_status := 'S';
  END IF;


END delete_terms;

PROCEDURE delete_deliverables(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_deliverables';
  x_msg_data         VARCHAR2(2500);
  x_msg_count        NUMBER;

  CURSOR cur_all_versions IS
      SELECT CONTRACT_VERSION_NUM version
        FROM okc_rep_contract_vers
       WHERE CONTRACT_ID = p_contract_id
         AND CONTRACT_TYPE = p_contract_type;

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_deliverables for the repository contract :' || p_contract_id);

      -- check for deliverables in OPEN or SUBMITTED status and if found halt the purging process.
      -- to do
    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting deliverable records');
      FND_FILE.PUT_LINE(FND_FILE.Log, '-*-*-*-*-*-*-*-*-******************************************-*-*-*-*-*-*-');

      FND_FILE.PUT_LINE(FND_FILE.Log, 'Deleting the deliverables for the version: -99');

        OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables (
                    p_api_version         => 1.0,
                    p_init_msg_list       => FND_API.G_FALSE,
                    p_bus_doc_id          => p_contract_id,
                    p_bus_doc_type        => p_contract_type,
                    p_bus_doc_version     => -99,

                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data);

         -----------------------------------------------------
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        --------------------------------------------------------


        FND_FILE.PUT_LINE(FND_FILE.Log, '----------------------------------------------------------------------------');

      FOR ver_rec IN cur_all_versions
      LOOP
        FND_FILE.PUT_LINE(FND_FILE.Log, '----------------------------------------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.Log, 'Deleting the deliverables for the version: '|| ver_rec.version);

        OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables (
                    p_api_version         => 1.0,
                    p_init_msg_list       => FND_API.G_FALSE,
                    p_bus_doc_id          => p_contract_id,
                    p_bus_doc_type        => p_contract_type,
                    p_bus_doc_version     => ver_rec.version,

                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data);

        -----------------------------------------------------
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        --------------------------------------------------------

        FND_FILE.PUT_LINE(FND_FILE.Log, '----------------------------------------------------------------------------');
      END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.Log, '-*-*-*-*-*-*-*-*-******************************************-*-*-*-*-*-*-');
  EXCEPTION
      WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting deliverables is failed.');
      x_err_msg := 'OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables call has errored out.';
      x_return_status := 'E';
  END;


  IF x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting deliverable records has failed.');
      x_err_msg := 'OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables call is not successful.';
  ELSE
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_deliverables for the repository contract :' || p_contract_id || 'is successful');
      x_return_status := 'S';
  END IF;

END delete_deliverables;

PROCEDURE delete_contract_documents(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name   VARCHAR2(100) := 'delete_contract_documents';
  x_msg_data         VARCHAR2(2500);
  x_msg_count        NUMBER;

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_contract_documents for the repository contract :' || p_contract_id);

    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting contract attachments ');

      OKC_CONTRACT_DOCS_GRP.Delete_Doc_Attachments(
              p_api_version               => 1.0,
              p_business_document_type    => p_contract_type,
              p_business_document_id      => p_contract_id,

              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
            );

        -----------------------------------------------------
          IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
        --------------------------------------------------------

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting contract attachments is failed.');
      x_err_msg := 'OKC_CONTRACT_DOCS_GRP.Delete_Doc_Attachments call has errored out.';
      x_return_status := 'E';
  END;

  IF x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting contract attachments is failed.');
      x_err_msg := 'OKC_CONTRACT_DOCS_GRP.Delete_Doc_Attachments call has errored out.';
  ELSE
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_contract_documents for the repository contract :' || p_contract_id || 'is successful');
      x_return_status := 'S';
  END IF;

END delete_contract_documents;

PROCEDURE delete_risks(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_risks';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_risks for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_CONTRACT_RISKS ');

      DELETE FROM OKC_CONTRACT_RISKS
          WHERE BUSINESS_DOCUMENT_TYPE = p_contract_type
            AND BUSINESS_DOCUMENT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_CONTRACT_RISKS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_CONTRACT_RISKS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_risks for the repository contract :' || p_contract_id || 'is successful');

END delete_risks;

PROCEDURE delete_related_contracts(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_related_contracts';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_related_contracts for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_RELS ');

      DELETE FROM OKC_REP_CONTRACT_RELS
          WHERE CONTRACT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_RELS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_RELS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_related_contracts for the repository contract :' || p_contract_id || 'is successful');

END delete_related_contracts;

PROCEDURE delete_approval_history(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_approval_history';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_approval_history for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_APPROVALS ');

      DELETE FROM OKC_REP_CON_APPROVALS
       WHERE CONTRACT_ID = p_contract_id ;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_APPROVALS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_APPROVALS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_approval_history for the repository contract :' || p_contract_id || 'is successful');

END delete_approval_history;

PROCEDURE delete_signature_details(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_signature_details';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_signature_details for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_SIGNATURE_DETAILS ');

       DELETE FROM OKC_REP_SIGNATURE_DETAILS
        WHERE CONTRACT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_SIGNATURE_DETAILS is successful. Total rows deleted: ' || SQL%ROWCOUNT);

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_SIGNATURE_DETAILS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_signature_details for the repository contract :' || p_contract_id || 'is successful');

END delete_signature_details;

PROCEDURE delete_jtf_notes(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_jtf_notes';
  l_count           NUMBER;
  x_msg_data        VARCHAR2(2500);
  x_msg_count       NUMBER;

  CURSOR c_get_notes(p_source_object_id IN NUMBER) IS
          SELECT jtf_note_id
          FROM JTF_NOTES_VL
          WHERE source_object_id = p_source_object_id
          AND   source_object_code = 'OKC_REP_CONTRACT';

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_jtf_notes for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting jtf notes records ');
      l_count := 0;
      FOR jtf_notes_rec IN c_get_notes(p_contract_id)
      LOOP
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting jtf notes with the id: ' || jtf_notes_rec.jtf_note_id);
          JTF_NOTES_PUB.secure_delete_note(
                        p_api_version           => 1.0,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_commit                => FND_API.G_FALSE,
                        p_validation_level     => 100,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data ,
                        p_jtf_note_id          => jtf_notes_rec.jtf_note_id,
                        p_use_AOL_security     => FND_API.G_FALSE);
           IF x_return_status = 'S' THEN
              l_count := l_count + 1;
           ELSE
              x_err_msg := 'deleting jtf notes with the id: ' || jtf_notes_rec.jtf_note_id || ' has been failed';
              FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ':'||x_err_msg );
              x_return_status := 'E';
              RETURN;
           END IF;
      END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting jtf notes records  is successful. Total rows deleted: ' || l_count);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting jtf notes records is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_jtf_notes for the repository contract :' || p_contract_id || 'is successful');

END delete_jtf_notes;

PROCEDURE delete_status_history(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_status_history';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_status_history for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_STATUS_HIST ');

      DELETE FROM OKC_REP_CON_STATUS_HIST
       WHERE CONTRACT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_STATUS_HIST is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CON_STATUS_HIST is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_status_history for the repository contract :' || p_contract_id || 'is successful');

END delete_status_history;

PROCEDURE delete_bookmarks(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_bookmarks';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_bookmarks for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_BOOKMARKS ');

      DELETE FROM OKC_REP_BOOKMARKS
          WHERE OBJECT_TYPE = p_contract_type
            AND OBJECT_ID = p_contract_id
           AND BOOKMARK_TYPE_CODE = 'CONTRACT';

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_BOOKMARKS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_BOOKMARKS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_bookmarks for the repository contract :' || p_contract_id || 'is successful');

END delete_bookmarks;

PROCEDURE delete_recent_contracts(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_recent_contracts';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_recent_contracts for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_RECENT_CONTRACTS ');

      DELETE FROM OKC_REP_RECENT_CONTRACTS
       WHERE BUSINESS_DOCUMENT_TYPE = p_contract_type
         AND BUSINESS_DOCUMENT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_RECENT_CONTRACTS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_RECENT_CONTRACTS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_recent_contracts for the repository contract :' || p_contract_id || 'is successful');

END delete_recent_contracts;

PROCEDURE delete_ACL(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_ACL';
  x_errcode        NUMBER;
  -- Query for the cursor
  CURSOR acl_csr IS
      SELECT
        fgrant.grantee_type       grantee_type,
        fgrant.grantee_key        grantee_key,
        fgrant.instance_type      instance_type,
        fgrant.instance_set_id    instance_set_id,
        fmenu.menu_name           menu_name,
        fgrant.program_name       program_name,
        fgrant.program_tag        program_tag
      FROM FND_GRANTS fgrant, FND_OBJECTS fobj, FND_MENUS fmenu
    WHERE fgrant.menu_id = fmenu.menu_id
          AND fgrant.object_id = fobj.object_id
          AND fobj.obj_name = 'OKC_REP_CONTRACT'
          AND fgrant.instance_pk1_value = to_char(p_contract_id);
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_ACL for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from ACL ');
      FOR acl_rec IN acl_csr LOOP

          FND_FILE.PUT_LINE(FND_FILE.Log, '-----------------------------------------------------------------------------');
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'grantee_type is: ' || acl_rec.grantee_type);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'grantee_key is: ' || acl_rec.grantee_key);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'instance_type is: ' || acl_rec.instance_type);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'instance_set_id is: ' || acl_rec.instance_set_id);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'menu_name is: ' || acl_rec.menu_name);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'program_name is: ' || acl_rec.program_name);
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name ||'program_tag is: ' || acl_rec.program_tag);
          FND_FILE.PUT_LINE(FND_FILE.Log, '-----------------------------------------------------------------------------');

          -- call FND_GRANT's delete api
          FND_GRANTS_PKG.delete_grant(
                        p_grantee_type        => acl_rec.grantee_type,  -- USER or GROUP
                        p_grantee_key         => acl_rec.grantee_key,   -- user_id or group_id
                        p_object_name         => 'OKC_REP_CONTRACT',
                        p_instance_type       => acl_rec.instance_type, -- INSTANCE or SET
                        p_instance_set_id     => acl_rec.instance_set_id, -- Instance set id.
                        p_instance_pk1_value  => to_char(p_contract_id), -- Object PK Value
                        p_menu_name           => acl_rec.menu_name,      -- Menu to be deleted.
                        p_program_name        => acl_rec.program_name,   -- name of the program that handles grant.
                        p_program_tag         => acl_rec.program_tag,    -- tag used by the program that handles grant.
                        x_success             => x_return_status,              -- return param. 'T' or 'F'
                        x_errcode             => x_errcode );
        -----------------------------------------------------
        IF (x_return_status = 'F' AND x_errcode < 0 ) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = 'F' AND x_errcode > 0) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      --------------------------------------------------------
      END LOOP;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from ACL is successful.');

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from ACL is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_ACL for the repository contract :' || p_contract_id || 'is successful');

END delete_ACL;


PROCEDURE delete_version_entries(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'delete_version_entries';
  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting delete_version_entries for the repository contract :' || p_contract_id);

  BEGIN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_VERS ');

      DELETE FROM OKC_REP_CONTRACT_VERS
       WHERE CONTRACT_TYPE = p_contract_type
         AND CONTRACT_ID = p_contract_id;

      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_VERS is successful. Total rows deleted: ' || SQL%ROWCOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': deleting records from OKC_REP_CONTRACT_VERS is failed. Error Code: '|| SQLCODE ||' Error: ' || SQLERRM);
      x_err_msg := SQLERRM;
      x_return_status := 'E';
      RETURN;
  END;

  x_return_status := 'S';
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': delete_version_entries for the repository contract :' || p_contract_id || ' is successful');

END delete_version_entries;

PROCEDURE purge_single_contract(
  p_contract_id        IN NUMBER,
  p_contract_type      IN VARCHAR2,
  x_err_msg           OUT NOCOPY  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100);

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' is started.');
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');

  -- deleting the contacts for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_contacts (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the parties for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_parties (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the terms for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_terms (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the deliverables for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_deliverables (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

   -- deleting the contract documents for the repository contract
   FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_contract_documents (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

   -- deleting the risks for the repository contract
   FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_risks (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the related contracts for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_related_contracts (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the approval history for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_approval_history (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the signature details for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_signature_details (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the jtf notes for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_jtf_notes (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the status history for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_status_history (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the bookmarks for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_bookmarks (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  -- deleting the recent_contracts for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_recent_contracts (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;


  -- deleting the ACL for the repository contract
  FND_FILE.PUT_LINE(FND_FILE.Log, '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  delete_ACL (
        p_contract_id       => p_contract_id,
        p_contract_type     => p_contract_type,
        x_err_msg           => x_err_msg,
        x_return_status     => x_return_status
        );
  IF  x_return_status <> 'S' THEN
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' errored out. Reason: '|| x_err_msg );
      FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
      RETURN;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Purging of the repository contract :' || p_contract_id || ' is completed successfully.');
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || '--------------------********************************************--------------------');

END purge_single_contract;

PROCEDURE purge_contracts(
  errbuf               OUT NOCOPY VARCHAR2,
  retcode              OUT NOCOPY VARCHAR2,
  p_org_id             IN NUMBER,
  p_start_date         IN VARCHAR2,
  p_end_date           IN VARCHAR2,
  p_terminated_yn      IN VARCHAR2,
  p_expired_yn         IN VARCHAR2,
  p_cancelled_yn       IN VARCHAR2,
  p_rejected_yn        IN VARCHAR2
  ) IS

  l_procedure_name VARCHAR2(100) := 'purge_contracts';
  l_err_msg           VARCHAR2(1000);
  l_return_status     VARCHAR2(10);
  l_row_notfound      BOOLEAN := FALSE;
  l_contract_name     VARCHAR2(450);
  l_contract_type_nm  VARCHAR2(150);

  l_temp_count        NUMBER;
  l_return            VARCHAR2(1);
  l_contract_id       NUMBER;
  l_contract_type     VARCHAR2(100);
  l_purge_success     VARCHAR2(1);
  l_retCode           VARCHAR2(10);

  CURSOR cur_purge_contracts IS
  SELECT contract_id, contract_type
    FROM OKC_REP_CONTRACTS_ALL
   WHERE org_id = p_org_id
     AND CONTRACT_EFFECTIVE_DATE BETWEEN To_Date(SubStr(p_start_date,1,10),'YYYY/MM/DD') AND To_Date(SubStr(p_end_date,1,10),'YYYY/MM/DD')
     AND ((p_terminated_yn = 'Yes' AND
           CONTRACT_STATUS_CODE = 'TERMINATED' )
     OR (p_expired_yn = 'Yes' AND
          CONTRACT_EXPIRATION_DATE BETWEEN To_Date(SubStr(p_start_date,1,10),'YYYY/MM/DD') AND To_Date(SubStr(p_end_date,1,10),'YYYY/MM/DD')  )
     OR (p_cancelled_yn = 'Yes' AND
           CONTRACT_STATUS_CODE = 'CANCELLED' )
     OR (p_rejected_yn = 'Yes' AND
           CONTRACT_STATUS_CODE = 'REJECTED' ))
     AND contract_type NOT IN ('REP_ACQ','REP_SBCR','REP_CCT','REP_CCC');


  CURSOR cur_chk_for_lock(cp_contract_id NUMBER, cp_contract_type varchar2) IS
  SELECT contract_name
   FROM OKC_REP_CONTRACTS_ALL
  WHERE contract_id    = cp_contract_id
    AND contract_type  = cp_contract_type
    FOR UPDATE OF contract_name NOWAIT;

  BEGIN

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': Starting purge_contracts');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is starting.');

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': **************INPUT*****************');
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_org_id: '||p_org_id);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_start_date: '||p_start_date);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_end_date: '||p_end_date);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_terminated_yn: '||p_terminated_yn);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_expired_yn: '||p_expired_yn);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_cancelled_yn: '||p_cancelled_yn);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': p_rejected_yn: '||p_rejected_yn);
  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ************************************');
  FND_FILE.PUT_LINE(FND_FILE.Log,' ');
  FND_FILE.PUT_LINE(FND_FILE.Log,'');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************INPUT*****************');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_org_id: '||p_org_id);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_start_date: '||p_start_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_end_date: '||p_end_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_terminated_yn: '||p_terminated_yn);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_expired_yn: '||p_expired_yn);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_cancelled_yn: '||p_cancelled_yn);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'p_rejected_yn: '||p_rejected_yn);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '************************************');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

  l_return :='N';
  IF p_org_id IS NULL THEN
    FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: No org_id is provided');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is failed. Please provide a valid org_id');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ');

    l_return :='Y';
  END IF;

  IF p_start_date IS NULL THEN
    FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: No Start Date is provided');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is failed. Please provide a valid Start Date');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ');

    l_return :='Y';
  END IF;

  IF p_end_date IS NULL THEN
    FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: No End Date is provided');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is failed. Please provide a valid End Date');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ');

    l_return :='Y';
  END IF;

  IF p_terminated_yn = 'No' AND p_expired_yn ='No' AND  p_cancelled_yn = 'No' AND p_rejected_yn = 'No' THEN

    FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: No status is marked Yes');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is failed. Please select atleast one status');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ');

    l_return :='Y';
  END IF;

  IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL AND
     To_Date(SubStr(p_start_date,1,10),'YYYY/MM/DD') > To_Date(SubStr(p_end_date,1,10),'YYYY/MM/DD') THEN

    FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: End date is earlier than Start Date');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is failed. End date is earlier than Start Date. Please input the dates Properly');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  ');

    l_return :='Y';
  END IF;

  IF l_return = 'Y' THEN
    retCode := '0'; --Successfully
    RETURN;
  END IF;

  FOR cntrct_rec IN cur_purge_contracts
  LOOP
    l_contract_id   := cntrct_rec.contract_id;
    l_contract_type := cntrct_rec.contract_type;

    FND_FILE.PUT_LINE(FND_FILE.Log, ' ');
    FND_FILE.PUT_LINE(FND_FILE.Log, ' ');
    FND_FILE.PUT_LINE(FND_FILE.Log, '========================================start of contract=================================================');

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '========================================start of contract=================================================');

    BEGIN
        SELECT NAME
          INTO l_contract_type_nm
          FROM OKC_BUS_DOC_TYPES_tl
        WHERE DOCUMENT_TYPE = l_contract_type
          AND LANGUAGE = UserEnv('LANG');

    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.Log, 'Contract Type name not found. Error: '|| SQLERRM );
      END;



    FND_FILE.PUT_LINE(FND_FILE.Log, 'Contract ID: '|| l_contract_id);
    FND_FILE.PUT_LINE(FND_FILE.Log, 'Contract Type: '|| l_contract_type );
    FND_FILE.PUT_LINE(FND_FILE.Log, 'Contract Type Name: '|| l_contract_type_nm );


    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Contract ID: '|| l_contract_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Contract Type: '|| l_contract_type_nm );

    l_temp_count := 0;

    SELECT Count(1)
      INTO l_temp_count
      FROM OKC_DELIVERABLES
      WHERE BUSINESS_DOCUMENT_ID = l_contract_id
        AND BUSINESS_DOCUMENT_TYPE = l_contract_type
        AND DELIVERABLE_STATUS IN ('SUBMITTED','OPEN');

        IF l_temp_count > 0 THEN
          FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: There are open deliverables. Contract Cannot be purged.');

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'There are open deliverables. Contract Cannot be purged.');
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');

          l_retCode := '1';  --warning
        ELSE
          BEGIN
              l_return_status := 'S';

              -- create a savepoint before proceeding
              SAVEPOINT okc_rep_contracts_purge_pub;

              -- lock the header
              BEGIN
                  OPEN cur_chk_for_lock(l_contract_id,l_contract_type);
                  FETCH cur_chk_for_lock INTO l_contract_name;
                  l_row_notfound := cur_chk_for_lock%NOTFOUND;
                  CLOSE cur_chk_for_lock;

                  IF l_row_notfound = FALSE THEN
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Contract Name: '|| l_contract_name );
                      FND_FILE.PUT_LINE(FND_FILE.Log, 'Contract Name: '|| l_contract_name );
                  END IF;

                  l_return_status := 'S';
              EXCEPTION
                WHEN OTHERS THEN

                  IF (cur_chk_for_lock%ISOPEN) THEN
                    CLOSE cur_chk_for_lock;
                  END IF;

                  l_purge_success := 'N';
                  l_err_msg  := 'Unable to lock the header.';
                  l_return_status := 'E';
                  l_retCode := '1';

              END;

              IF l_return_status <> 'E' THEN
                  purge_single_contract(
                      p_contract_id     =>  l_contract_id,
                      p_contract_type   =>  l_contract_type,
                      x_err_msg         =>  l_err_msg,
                      x_return_status   =>  l_return_status
                      );
              END IF;

              IF l_return_status = 'S' THEN

                  --delete the version entries
                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract is purged successfully.');
                  delete_version_entries (
                      p_contract_id       => l_contract_id,
                      p_contract_type     => l_contract_type,
                      x_err_msg           => l_err_msg,
                      x_return_status     => l_return_status
                      );

                  IF l_return_status = 'S' THEN
                      BEGIN
                        DELETE FROM OKC_REP_CONTRACTS_ALL
                          WHERE contract_id = l_contract_id;

                        FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract header is deleted.');
                        l_purge_success := 'Y';

                      EXCEPTION
                        WHEN OTHERS THEN
                            FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract header cannot be deleted.');
                            l_retCode := '1';
                            l_purge_success := 'N';
                      END;
                  ELSE
                      l_retCode := '1';
                      l_purge_success := 'N';
                  END IF;
              ELSE
                  l_retCode := '1';
                  l_purge_success := 'N';
              END IF;

              IF l_purge_success = 'Y' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The contract is purged successfully.');
                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract is purged successfully.');
                  COMMIT;

              ELSIF l_purge_success = 'N' THEN
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg );
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');

                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: '|| l_err_msg);

                  l_retCode := '1';
                  ROLLBACK TO okc_rep_contracts_purge_pub;

              ELSE
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Unknown error. Purge status is returned as null');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');

                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: Unknown error. Purge status is returned as null');

                  l_retCode := '1';
                  ROLLBACK TO okc_rep_contracts_purge_pub;
              END IF;
          EXCEPTION
              WHEN OTHERS THEN
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Unknown error. Purge process has returned exception.');
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**************ERROR*****************');

                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': The contract purging is failed.');
                  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': ERROR: Purge process has returned exception.' || SQLERRM);


                  ROLLBACK TO okc_rep_contracts_purge_pub;
          END;
        END IF;


    FND_FILE.PUT_LINE(FND_FILE.Log, '========================================end of contract============================================');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '========================================end of contract============================================');


  END LOOP;

  FND_FILE.PUT_LINE(FND_FILE.Log, l_procedure_name || ': purge_contracts is completed');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Purging the contracts is completed.');

  IF l_retCode = '1' THEN
    retCode := '1';
  ELSE
    retCode := '0';
  END IF;

  END purge_contracts;

END okc_rep_contracts_purge_pub;

/
