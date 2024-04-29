--------------------------------------------------------
--  DDL for Package Body POS_PUB_HISTORY_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PUB_HISTORY_BO_PKG" AS
  /* $Header: POSPUBHIB.pls 120.0.12010000.3 2010/05/24 18:56:37 huiwan noship $ */

  g_pkg_name         CONSTANT VARCHAR2(30) := 'pos_pub_history_bo_pkg';

      PROCEDURE add_message(
          p_pkg_name VARCHAR2,
          p_api_name VARCHAR2,
          p_err_code NUMBER) IS
      BEGIN
      --
      -- Private utility procedure to add an FND message to
      -- indicate an error has occurred.
      --
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
              fnd_msg_pub.add_exc_msg(
                  p_pkg_name => p_pkg_name,
                  p_procedure_name => p_api_name,
                  p_error_text => sqlerrm(p_err_code));
          END IF;
      END add_message;


      PROCEDURE add_unique_constraint_message(
          p_pkg_name VARCHAR2,
          p_api_name VARCHAR2) IS
      BEGIN
          add_message(p_pkg_name, p_api_name, -1);
      END add_unique_constraint_message;


      PROCEDURE add_no_data_found_message(
          p_pkg_name VARCHAR2,
          p_api_name VARCHAR2) IS
      BEGIN
          add_message(p_pkg_name, p_api_name, 100);
      END add_no_data_found_message;



  /*
  * Use this routine to get publication history bo
  */
  PROCEDURE get_pos_pub_history_bo_tbl
  (
    p_api_version            IN NUMBER DEFAULT NULL,
    p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
    p_event_id               IN NUMBER,
    p_party_id               IN NUMBER,
    p_orig_system            IN VARCHAR2,
    p_orig_system_reference  IN VARCHAR2,
    x_pos_pub_history_bo_tbl OUT NOCOPY pos_pub_history_bo_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

    l_pos_pub_history_bo_tbl pos_pub_history_bo_tbl := pos_pub_history_bo_tbl();
    l_party_id               NUMBER;
    l_event_id               NUMBER;

    l_api_name          CONSTANT VARCHAR2(30)   := 'get_published_suppliers';
    l_api_version       CONSTANT NUMBER         := 1.0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data      := '';

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
        l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) THEN
        fnd_msg_pub.initialize;
    END IF;

    IF (p_party_id IS NULL OR p_party_id = 0) THEN
      IF (p_orig_system IS NOT NULL AND p_orig_system_reference IS NOT NULL) THEN
        l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);
      END IF;
    ELSE
      l_party_id := p_party_id;
    END IF;

    IF (p_event_id = 0) THEN
      l_event_id := NULL;
    ELSE
      l_event_id := p_event_id;
    END IF;

    IF (l_party_id = 0) THEN
      l_party_id := NULL;
    END IF;

    IF (l_event_id IS NULL AND l_party_id IS NULL) THEN
      RETURN;
    END IF;

    SELECT pos_pub_history_bo(ph.publication_event_id,
                              ph.party_id,
                              ph.publication_date,
                              ph.published_by,
                              ph.publish_detail,
                              ph.xmlcontent,
                              ph.created_by,
                              ph.creation_date,
                              ph.last_updated_by,
                              ph.last_update_date,
                              ph.last_update_login,
                              ph.request_id)
    BULK COLLECT
    INTO   l_pos_pub_history_bo_tbl
    FROM   pos_supp_pub_history ph
    WHERE  ph.publication_event_id = nvl(l_event_id, publication_event_id)
    AND    ph.party_id = nvl(l_party_id, party_id);

    --
    -- BULK COLLECT does not raise no data found error automatically.
    -- So we add a rowcount check.
    --
    IF sql%rowcount = 0 THEN
        add_no_data_found_message(g_pkg_name, l_api_name);
        RAISE fnd_api.g_exc_error;
    END IF;

    x_pos_pub_history_bo_tbl := l_pos_pub_history_bo_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
          p_count => x_msg_count,
          p_data  => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
          p_count => x_msg_count,
          p_data  => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(
              p_pkg_name => g_pkg_name,
              p_procedure_name => l_api_name,
              p_error_text => sqlerrm);
      END IF;
      fnd_msg_pub.count_and_get(
          p_count => x_msg_count,
          p_data  => x_msg_data);

  END get_pos_pub_history_bo_tbl;


  /*
      Public wrapper of get_pos_pub_history_bo_tbl
      This procedure name is easier to understand for public callers.
   */
  PROCEDURE get_published_suppliers
  (
    p_api_version            IN NUMBER DEFAULT NULL,
    p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
    p_event_id               IN NUMBER,
    p_party_id               IN NUMBER,
    p_orig_system            IN VARCHAR2,
    p_orig_system_reference  IN VARCHAR2,
    x_suppliers              OUT NOCOPY pos_pub_history_bo_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
      get_pos_pub_history_bo_tbl(
        p_api_version            => p_api_version,
        p_init_msg_list          => p_init_msg_list,
        p_event_id               => p_event_id,
        p_party_id               => p_party_id,
        p_orig_system            => p_orig_system,
        p_orig_system_reference  => p_orig_system_reference,
        x_pos_pub_history_bo_tbl => x_suppliers,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );
  END get_published_suppliers;


       FUNCTION exists_event_party(p_event_id NUMBER, p_party_id NUMBER)
       RETURN BOOLEAN IS
       --
       -- Private utility function to find if event and party already
       -- exists in the publication history
       --
           CURSOR c IS
               SELECT 1
               FROM   pos_supp_pub_history
               WHERE  publication_event_id = p_event_id AND
                      party_id = p_party_id;

           dummy NUMBER;
           result BOOLEAN;

       BEGIN
           OPEN c;
           FETCH c INTO dummy;
           result := c%FOUND;
           CLOSE c;

           RETURN result;
       END exists_event_party;


       FUNCTION exists_target_response(p_target VARCHAR2, p_response_id NUMBER)
       RETURN BOOLEAN IS
       --
       -- Private utility function to find if event and party already
       -- exists in the publication history
       --
           CURSOR c IS
               SELECT 1
               FROM   pos_supp_pub_responses
               WHERE  target_system = p_target AND
                      response_process_id = p_response_id;

           dummy NUMBER;
           result BOOLEAN;

       BEGIN
           OPEN c;
           FETCH c INTO dummy;
           result := c%FOUND;
           CLOSE c;

           RETURN result;
       END exists_target_response;


      PROCEDURE create_response_private(
          p_target_system           IN VARCHAR2,
          p_response_process_id     IN NUMBER,
          p_response_process_status IN VARCHAR2,
          p_request_process_id      IN NUMBER,
          p_request_process_status  IN VARCHAR2,
          p_event_id                IN NUMBER,
          p_party_id                IN NUMBER,
          p_message                 IN VARCHAR2) IS
      BEGIN
          INSERT INTO pos_supp_pub_responses(
              publication_event_id,
              party_id,
              target_system,
              request_process_id,
              request_process_status,
              response_process_id,
              response_process_status,
              target_system_response_date,
              error_message,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login)
          VALUES (
              p_event_id,
              p_party_id,
              p_target_system,
              p_request_process_id,
              p_request_process_status,
              p_response_process_id,
              p_response_process_status,
              sysdate,
              p_message,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.login_id
          );

      END create_response_private;

  /*
      Public create publication response.  See spec for param descriptions.
   */
  PROCEDURE create_publication_response(
      p_api_version             IN NUMBER DEFAULT NULL,
      p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
      p_commit                  IN VARCHAR2 DEFAULT NULL,
      p_target_system           IN VARCHAR2,
      p_response_process_id     IN NUMBER,
      p_response_process_status IN VARCHAR2,
      p_request_process_id      IN NUMBER,
      p_request_process_status  IN VARCHAR2,
      p_event_id                IN NUMBER,
      p_party_id                IN NUMBER,
      p_message                 IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
  ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'create_publication_response';
      l_api_version   CONSTANT NUMBER       := 1.0;

  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_data      := '';

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
          l_api_name, g_pkg_name) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) THEN
          fnd_msg_pub.initialize;
      END IF;

      -- Verify required fields
      IF p_target_system is NULL OR
          p_response_process_id IS NULL OR
          p_event_id IS NULL OR
          p_party_id IS NULL THEN
          add_no_data_found_message(g_pkg_name, l_api_name);
          RAISE fnd_api.g_exc_error;
      END IF;

      -- Event and Party IDs must exist in parent table
      IF NOT exists_event_party(p_event_id, p_party_id) THEN
          add_no_data_found_message(g_pkg_name, l_api_name);
          RAISE fnd_api.g_exc_error;
      END IF;

      -- Target System + Response ID must be unique
      IF exists_target_response(p_target_system, p_response_process_id) THEN
          add_unique_constraint_message(g_pkg_name, l_api_name);
          RAISE fnd_api.g_exc_error;
      END IF;

      create_response_private(
          p_target_system,
          p_response_process_id,
          p_response_process_status,
          p_request_process_id,
          p_request_process_status,
          p_event_id,
          p_party_id,
          p_message
      );

      IF fnd_api.to_boolean(nvl(p_commit, fnd_api.g_false)) THEN
          COMMIT;
      END IF;

  EXCEPTION
      WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(
              p_count => x_msg_count,
              p_data  => x_msg_data);

      WHEN fnd_api.g_exc_unexpected_error THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          fnd_msg_pub.count_and_get(
              p_count => x_msg_count,
              p_data  => x_msg_data);

      WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(
                  p_pkg_name => g_pkg_name,
                  p_procedure_name => l_api_name,
                  p_error_text => sqlerrm);
          END IF;
          fnd_msg_pub.count_and_get(
              p_count => x_msg_count,
              p_data  => x_msg_data);

  END create_publication_response;


END pos_pub_history_bo_pkg;

/
