--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_SERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_SERVICES_PUB" AS
/*$Header: ARHLCSVB.pls 120.35 2007/12/06 06:30:43 rarajend ship $*/

-- fix bug 4271311 - max length of VARCHAR2 is 32767
-- for UTF-8 character set, max length should be 32767/3 = 10922
MAX_LENGTH CONSTANT NUMBER := 10922;

TYPE outstreams_type IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;

PROCEDURE save_adapter_log(
  p_create_or_update      IN VARCHAR2,
  px_rowid                IN OUT NOCOPY ROWID,
  px_adapter_log_id       IN OUT NOCOPY NUMBER,
  p_created_by_module     IN VARCHAR2,
  p_created_by_module_id  IN NUMBER,
  p_http_status_code      IN VARCHAR2,
  p_request_id            IN NUMBER,
  p_object_version_number IN NUMBER,
  p_inout_doc             IN CLOB );

PROCEDURE validate_mandatory_column(
  p_location_rec  IN            HZ_LOCATION_V2PUB.location_rec_type,
  x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE add_wf_parameters(
  p_adapter_id  IN      NUMBER,
  p_overwrite_threshold IN VARCHAR2,
  p_country     IN      VARCHAR2,
  p_nvl_vsc     IN      VARCHAR2,
  p_from_vsc    IN      VARCHAR2,
  p_to_vsc      IN      VARCHAR2,
  p_from_lud    IN      VARCHAR2,
  p_to_lud      IN      VARCHAR2,
  p_nvl_dv      IN      VARCHAR2,
  p_from_dv     IN      VARCHAR2,
  p_to_dv       IN      VARCHAR2,
  p_num_batch   IN      NUMBER,
  p_batch_seq   IN      NUMBER,
  p_parameter_list  OUT NOCOPY wf_parameter_list_t );

PROCEDURE get_fromnto_value(
  p_max         IN  VARCHAR2,
  p_min         IN  VARCHAR2,
  p_op          IN  VARCHAR2,
  p_in          IN  VARCHAR2,
  p_nvl_out     OUT NOCOPY VARCHAR2,
  p_from_out    OUT NOCOPY VARCHAR2,
  p_to_out      OUT NOCOPY VARCHAR2 );

PROCEDURE set_loc_assign_id(
  p_location_rec    IN         hz_location_v2pub.location_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION get_adapter_link(p_adapter_id  NUMBER) RETURN VARCHAR2;

-- This procedure set proxy
PROCEDURE set_proxy (
  p_proxy_host    VARCHAR2 DEFAULT NULL,
  p_proxy_port    VARCHAR2 DEFAULT NULL,
  p_proxy_bypass  VARCHAR2 DEFAULT NULL)
IS
  l_proxy_host    VARCHAR2(240);
  l_proxy_port    VARCHAR2(240);
  l_proxy_bypass  VARCHAR2(240);
BEGIN

  log('Set Proxy Begin');
  -- can set proxy base on the following profiles if pass in value is null
  -- all profiles are site level only
  --
  -- 1) WEB_PROXY_HOST
  -- 2) WEB_PROXY_PORT
  -- 3) WEB_PROXY_BYPASS_DOMAINS

  IF(p_proxy_host IS NULL) THEN
    l_proxy_host := FND_PROFILE.VALUE('WEB_PROXY_HOST');
    l_proxy_port := FND_PROFILE.VALUE('WEB_PROXY_PORT');
    l_proxy_bypass := FND_PROFILE.VALUE('WEB_PROXY_BYPASS_DOMAINS');
  ELSE
    l_proxy_host := p_proxy_host;
    l_proxy_port := p_proxy_port;
    l_proxy_bypass := p_proxy_bypass;
  END IF;

  IF(l_proxy_host is not null) THEN
    UTL_HTTP.SET_PROXY(ltrim(rtrim(l_proxy_host))||':'||ltrim(rtrim(l_proxy_port)),l_proxy_bypass);
    log('Proxy base on profile setting');
    log('Proxy Host: '||l_proxy_host);
    log('Proxy Port: '||l_proxy_port);
    log('Proxy Bypass Domains: '||l_proxy_bypass);
  END IF;

  log('Set Proxy End');

END set_proxy;

-- This procedure set proxy
PROCEDURE set_authentication (
  p_req           IN OUT NOCOPY UTL_HTTP.REQ,
  p_adapter_id  IN NUMBER )
IS
  l_username    VARCHAR2(100);
  l_password    VARCHAR2(100);

  CURSOR get_username_password(l_adapter_id NUMBER) IS
  SELECT username, encrypted_password
  FROM HZ_ADAPTERS
  WHERE adapter_id = l_adapter_id;
BEGIN

  -- as password is encrypted, we may need to decrypt it
  log('Set Authentication Begin');

  OPEN get_username_password(p_adapter_id);
  FETCH get_username_password INTO l_username, l_password;
  CLOSE get_username_password;

  IF((l_username IS NOT NULL) AND (l_password IS NOT NULL)) THEN
    UTL_HTTP.SET_AUTHENTICATION(p_req, l_username, l_password, 'Basic', FALSE);
  END IF;

  log('Set Authentication End');

END set_authentication;

-----------------------------------------------------------------------
-- Called from address validation conc program (ARHADDRV)
-----------------------------------------------------------------------
-- It will do the following
-- 1) Accept parameters from conc program and retrieve rows from
--    HZ_LOCATIONS which meet the parameters passed in
-- 2) Raise wf event to enerate xml document base on the rows retrieved.
--    It may split up all rows into different batch due to the maximum batch
--    size defined for each adapter.
------------------------------------------------------------------------
PROCEDURE address_validation (
  Errbuf                        OUT NOCOPY VARCHAR2,
  Retcode                       OUT NOCOPY VARCHAR2,
  p_validation_status_op         IN VARCHAR2,
  p_validation_status_code       IN VARCHAR2,
  p_date_validated_op            IN VARCHAR2,
  p_date_validated               IN VARCHAR2,
  p_last_update_date_op          IN VARCHAR2,
  p_last_update_date             IN VARCHAR2,
  p_country                      IN VARCHAR2,
  p_adapter_content_source       IN VARCHAR2,
  p_overwrite_threshold          IN VARCHAR2 )
IS
  l_return_status   VARCHAR2(30);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_where_clause    VARCHAR2(2000);
  l_def_batch_size  NUMBER;
  l_total_loc       NUMBER;
  l_adapter_id      NUMBER;
  l_num_batch       NUMBER;
  l_batch_seq       NUMBER;
  l_max_vsc         NUMBER;
  l_min_vsc         NUMBER;
  l_nvl_vsc         VARCHAR2(30);
  l_from_vsc        VARCHAR2(30);
  l_to_vsc          VARCHAR2(30);
  l_nvl_lud         VARCHAR2(11);
  l_from_lud        VARCHAR2(11);
  l_to_lud          VARCHAR2(11);
  l_nvl_dv          VARCHAR2(11);
  l_from_dv         VARCHAR2(11);
  l_to_dv           VARCHAR2(11);
  --l_event_key       VARCHAR2(100);
  l_eot             VARCHAR2(11);
  l_sot             VARCHAR2(11);

  l_request_id      NUMBER;
  l_tmp_dv          VARCHAR2(11);
  l_tmp_lud         VARCHAR2(11);
  l_in_dv           VARCHAR2(11);
  l_in_lud          VARCHAR2(11);
  l_vsc             VARCHAR2(30);

  i                 NUMBER;
  req_data          VARCHAR2(10);
  r                 NUMBER;
  l_err_msg         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  l_err_count       NUMBER;
  l_req_id          NUMBER;

  --l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();

  -- get highest validation status code
  -- the higher the code, the poor the data.
  -- e.g: 0 means validated successfully
  CURSOR get_maxmin_scode IS
  SELECT max(to_number(lookup_code)), min(to_number(lookup_code))
  FROM ar_lookups
  WHERE lookup_type = 'HZ_ADDR_VAL_STATUS'
  AND enabled_flag = 'Y';

  -- get adapter_id base on adapter_content_source
  CURSOR get_adapter_id_from_cont(l_adapter_content_source VARCHAR2) IS
  SELECT adapter_id
  FROM hz_adapters
  WHERE ltrim(rtrim(adapter_content_source)) = ltrim(rtrim(l_adapter_content_source));

  -- get default batch size base on adapter_id
  CURSOR get_def_batch(l_adapter_id NUMBER) IS
  SELECT maximum_batch_size
  FROM hz_adapters
  WHERE adapter_id = l_adapter_id;

  -- get the min creation_date from HZ_LOCATIONS
  CURSOR get_min_cr_date IS
  SELECT to_char(min(creation_date), 'DD-MON-YYYY')
  FROM hz_locations;

  -- get worker status
  CURSOR get_worker_status(l_request_id NUMBER) IS
  SELECT COUNT(1)
  FROM FND_CONCURRENT_REQUESTS
  WHERE priority_request_id = l_request_id
  AND request_id <> l_request_id
  AND phase_code = 'C'
  AND status_code = 'E';

BEGIN

  savepoint address_validation_pub;

  FND_MSG_PUB.initialize;

  req_data := fnd_conc_global.request_data;

  --
  -- If this is the first run, we well set i = 1.
  -- Otherwise, we will set i = request_data + 1, and we will
  -- exit if we are done.
  --

  IF(req_data is not null) THEN
    l_req_id := FND_GLOBAL.CONC_REQUEST_ID;
    OPEN get_worker_status(l_req_id);
    FETCH get_worker_status INTO l_err_count;
    CLOSE get_worker_status;
    IF(l_err_count > 0) THEN
      errbuf := 'Error on worker';
      retcode := 2;
    ELSE
      errbuf := 'All worker done';
      retcode := 0;
    END IF;
    RETURN;
  ELSE
    i := 1;
  END IF;

  log('Starting Location Service');
  log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  log('NEWLINE');

  log('p_validation_status_op :'||p_validation_status_op);
  log('p_validation_status_code :'||p_validation_status_code);
  log('p_date_validated_op :'||p_date_validated_op);
  log('p_date_validated :'||p_date_validated);
  log('p_last_update_date_op :'||p_last_update_date_op);
  log('p_last_update_date :'||p_last_update_date);
  log('p_country :'||p_country);
  log('p_adapter_content_source :'||p_adapter_content_source);
  log('p_overwrite_threshold :'||p_overwrite_threshold);

  IF(p_date_validated IS NOT NULL) THEN
    l_in_dv := to_char(fnd_date.canonical_to_date(p_date_validated),'DD-MON-YYYY');
    IF(p_date_validated_op = '>') THEN
      l_tmp_dv := to_char(fnd_date.canonical_to_date(p_date_validated)+1,'DD-MON-YYYY');
    ELSIF(p_date_validated_op = '<') THEN
      l_tmp_dv := to_char(fnd_date.canonical_to_date(p_date_validated)-1,'DD-MON-YYYY');
    ELSE
      l_tmp_dv := to_char(fnd_date.canonical_to_date(p_date_validated),'DD-MON-YYYY');
    END IF;
    log('temp date_validated: '||l_tmp_dv);
  END IF;

  IF(p_last_update_date IS NOT NULL) THEN
    l_in_lud := to_char(fnd_date.canonical_to_date(p_last_update_date),'DD-MON-YYYY');
    IF(p_last_update_date_op = '>') THEN
      l_tmp_lud := to_char(fnd_date.canonical_to_date(p_last_update_date)+1,'DD-MON-YYYY');
    ELSIF(p_last_update_date_op = '<') THEN
      l_tmp_lud := to_char(fnd_date.canonical_to_date(p_last_update_date)-1,'DD-MON-YYYY');
    ELSE
      l_tmp_lud := to_char(fnd_date.canonical_to_date(p_last_update_date),'DD-MON-YYYY');
    END IF;
    log('temp last_update_date: '||l_tmp_lud);
  END IF;

  -- get adapter id
  IF(p_adapter_content_source IS NOT NULL) THEN
    OPEN get_adapter_id_from_cont(p_adapter_content_source);
    FETCH get_adapter_id_from_cont INTO l_adapter_id;
    CLOSE get_adapter_id_from_cont;
  ELSE
    l_adapter_id := get_adapter_id(null, p_country);
    IF(l_adapter_id IS NULL) THEN
      log('Invalid adapter id: '||l_adapter_id);
      log('p_adapter_content_source: '||p_adapter_content_source);
      log('p_country_code: '||p_country);
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_ADAPTER');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- get default batch size
  OPEN get_def_batch(l_adapter_id);
  FETCH get_def_batch INTO l_def_batch_size;
  CLOSE get_def_batch;

  -- get the max and min validation_status_code
  OPEN get_maxmin_scode;
  FETCH get_maxmin_scode INTO l_max_vsc, l_min_vsc;
  CLOSE get_maxmin_scode;

  -- construct where clause to find out the total number of locations
  l_where_clause := 'select count(1) from HZ_LOCATIONS '||
                    'where actual_content_source = ''USER_ENTERED'' and nvl(do_not_validate_flag,''N'') = ''N''';
  IF((p_validation_status_op IS NOT NULL) AND (p_validation_status_code IS NOT NULL)) THEN
    l_where_clause := l_where_clause||' and validation_status_code '
                      ||p_validation_status_op||' :p_val_status_code';
  ELSE
    l_where_clause := l_where_clause||' and :p_val_status_code is null';
  END IF;

  -- base on pass in op and value to find out max and min of the parameter
  -- e.g.: if op is '>' and status code is '0'.  Then the return l_from_vsc
  -- will be '1' and l_to_vsc will be '6' (which is max vsc in seed data)
  -- l_nvl_vsc will be set to min, i.e. '1'
  l_vsc := p_validation_status_code;
  IF((p_validation_status_op IS NOT NULL) AND (p_validation_status_code IS NOT NULL)) THEN
    IF(p_validation_status_op = '>') THEN
      l_max_vsc := l_max_vsc + 1;
      l_min_vsc := l_min_vsc + 1;
      l_vsc     := to_number(p_validation_status_code)+1;
    ELSIF(p_validation_status_op = '<') THEN
      l_max_vsc := l_max_vsc - 1;
      l_min_vsc := l_min_vsc - 1;
      l_vsc     := to_number(p_validation_status_code)-1;
    END IF;
  END IF;

  log('Max VSC: '||l_max_vsc);
  log('Min VSC: '||l_min_vsc);
  log('VSC: '||l_vsc);

  get_fromnto_value(
    p_max         => to_char(l_max_vsc),
    p_min         => to_char(l_min_vsc),
    p_op          => p_validation_status_op,
    p_in          => l_vsc,
    p_nvl_out     => l_nvl_vsc,
    p_from_out    => l_from_vsc,
    p_to_out      => l_to_vsc );

  -- unset the nvl parameter if the input for validation_status_code and operator
  -- are not null
  IF((p_validation_status_op IS NOT NULL) AND (p_validation_status_code IS NOT NULL)) THEN
    l_nvl_vsc := '-99';
  END IF;

  IF((p_date_validated_op IS NOT NULL) AND (p_date_validated IS NOT NULL)) THEN
    l_where_clause := l_where_clause||' and trunc(date_validated) '
                      ||p_date_validated_op
                      ||' to_date(:p_date_val,''DD-MON-YYYY'')';
  ELSE
    l_where_clause := l_where_clause||' and :p_date_val is null';
  END IF;

  l_eot := to_char(add_months(sysdate,12),'DD-MON-YYYY');
  OPEN get_min_cr_date;
  FETCH get_min_cr_date INTO l_sot;
  CLOSE get_min_cr_date;

  get_fromnto_value(
    p_max         => l_eot,
    p_min         => l_sot,
    p_op          => p_date_validated_op,
    p_in          => l_tmp_dv,
    p_nvl_out     => l_nvl_dv,
    p_from_out    => l_from_dv,
    p_to_out      => l_to_dv );

  -- unset the nvl parameter if the input for date_validated and operator are not null
  IF((p_date_validated_op IS NOT NULL) AND (p_date_validated IS NOT NULL)) THEN
    l_nvl_dv := to_char(add_months(sysdate,24),'DD-MON-YYYY');
  END IF;

  IF((p_last_update_date_op IS NOT NULL) AND (p_last_update_date IS NOT NULL)) THEN
    l_where_clause := l_where_clause||' and trunc(last_update_date) '
                      ||p_last_update_date_op
                      ||' to_date(:p_last_upd_date,''DD-MON-YYYY'')';
  ELSE
    l_where_clause := l_where_clause||' and :p_last_upd_date is null';
  END IF;

  get_fromnto_value(
    p_max         => l_eot,
    p_min         => l_sot,
    p_op          => p_last_update_date_op,
    --p_in          => p_last_update_date,
    p_in          => l_tmp_lud,
    p_nvl_out     => l_nvl_lud,
    p_from_out    => l_from_lud,
    p_to_out      => l_to_lud );

  IF(p_country IS NOT NULL) THEN
    l_where_clause := l_where_clause||' and country = :p_cntry';
  ELSE
    l_where_clause := l_where_clause||' and :p_cntry is null';
  END IF;
  log('where clause :'||l_where_clause);

  execute immediate l_where_clause into l_total_loc
    using p_validation_status_code, l_in_dv, l_in_lud, p_country;

  log('Total number of locations: '||l_total_loc);
  log('Maximum batch size: '||l_def_batch_size);

  -- find out how many batches required
  l_num_batch := ceil(l_total_loc/l_def_batch_size);
  log('The number of batch required: '||l_num_batch);

  log('Pass these parameters to worker');
  log('Adapter ID: '||l_adapter_id);
  log('Overwrite Threshold: '||p_overwrite_threshold);
  log('Country: '||p_country);
  log('NVL VSC: '||l_nvl_vsc);
  log('FROM VSC: '||l_from_vsc);
  log('TO VSC: '||l_to_vsc);
  log('FROM LUD: '||l_from_lud);
  log('TO LUD: '||l_to_lud);
  log('NVL DV: '||l_nvl_dv);
  log('FROM DV: '||l_from_dv);
  log('TO DV: '||l_to_dv);
  log('NUM BATCH: '||l_num_batch);

  -- submit each batch will one address validation request
  -- pass number of batch to ecx call
  -- use loop to make ecx call and add parameters for each ecx call
  FOR j in 0..l_num_batch-1 LOOP

    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
          'AR', 'ARHADDRW', 'Address Validation Worker '||j,
          SYSDATE, TRUE, l_adapter_id, p_overwrite_threshold,
          p_country, l_nvl_vsc, l_from_vsc, l_to_vsc,
          l_from_lud, l_to_lud, l_nvl_dv, l_from_dv, l_to_dv,
          l_num_batch, j);

    log('NEWLINE');
    log('Submit Address Validation Worker '||j);

    IF(l_request_id IS NULL or l_request_id = 0) THEN
      l_err_msg := FND_MESSAGE.get;
      errbuf := l_err_msg;
      retcode := 2;
      RETURN;
    END IF;
  END LOOP;

  log('NEWLINE');
  log('Concurrent Program Execution completed ');
  log('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));

  IF(l_total_loc > 0) THEN
    fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                    request_data => TO_CHAR(i));
    errbuf := 'Concurrent Program Execution completed ';
    retcode := 0;
    RETURN;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Error: Aborting Location Service');
    ROLLBACK TO address_validation_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Error: Aborting Location Service');
    ROLLBACK TO address_validation_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN OTHERS THEN
    log('Error: Aborting Location Service');
    ROLLBACK TO address_validation_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
END address_validation;

-----------------------------------------------------------------------
-- Called from address validation conc program (ARHADDRV)
-----------------------------------------------------------------------
-- It will do the following
-- 1) Accept parameters from conc program and retrieve rows from
--    HZ_LOCATIONS which meet the parameters passed in
-- 2) Raise wf event to enerate xml document base on the rows retrieved.
--    It may split up all rows into different batch due to the maximum batch
--    size defined for each adapter.
------------------------------------------------------------------------
PROCEDURE address_validation_worker (
  Errbuf                        OUT NOCOPY VARCHAR2,
  Retcode                       OUT NOCOPY VARCHAR2,
  p_adapter_id                   IN NUMBER,
  p_overwrite_threshold          IN VARCHAR2,
  p_country                      IN VARCHAR2,
  p_nvl_vsc                      IN VARCHAR2,
  p_from_vsc                     IN VARCHAR2,
  p_to_vsc                       IN VARCHAR2,
  p_from_lud                     IN VARCHAR2,
  p_to_lud                       IN VARCHAR2,
  p_nvl_dv                       IN VARCHAR2,
  p_from_dv                      IN VARCHAR2,
  p_to_dv                        IN VARCHAR2,
  p_num_batch                    IN NUMBER,
  p_batch_sequence               IN NUMBER )
IS

  l_event_key       VARCHAR2(100);
  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();

BEGIN

  savepoint address_validation_w_pub;

  FND_MSG_PUB.initialize;

  log('Starting Location Service Worker');
  log('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  log('NEWLINE');

  log('p_adapter_id :'||p_adapter_id);
  log('p_overwrite_threshold :'||p_overwrite_threshold);
  log('p_country :'||p_country);
  log('p_nvl_vsc :'||p_nvl_vsc);
  log('p_from_vsc :'||p_from_vsc);
  log('p_to_vsc :'||p_to_vsc);
  log('p_from_lud :'||p_from_lud);
  log('p_to_lud :'||p_to_lud);
  log('p_nvl_dv :'||p_nvl_dv);
  log('p_from_dv :'||p_from_dv);
  log('p_to_dv :'||p_to_dv);
  log('p_num_batch :'||p_num_batch);
  log('p_batch_seq :'||p_batch_sequence);
  log('Batch #: '||p_batch_sequence);

  l_parameter_list := wf_parameter_list_t();

  log('Adding workflow parameters');

  add_wf_parameters(
      p_adapter_id  => p_adapter_id,
      p_overwrite_threshold => p_overwrite_threshold,
      p_country     => p_country,
      p_nvl_vsc     => p_nvl_vsc,
      p_from_vsc    => p_from_vsc,
      p_to_vsc      => p_to_vsc,
      p_from_lud    => p_from_lud,
      p_to_lud      => p_to_lud,
      p_nvl_dv      => p_nvl_dv,
      p_from_dv     => p_from_dv,
      p_to_dv       => p_to_dv,
      p_num_batch   => p_num_batch,
      p_batch_seq   => p_batch_sequence,
      p_parameter_list => l_parameter_list );

  l_event_key := 'HZ_LOCSERVICE_OUTBOUND-'||hz_utility_v2pub.request_id||'-'||p_adapter_id||'-'||p_batch_sequence;

  -- raise wf event, this will call procedure outdoc_rule
  log('Raise Workflow Event, event key is: '||l_event_key);

  wf_event.raise(
      p_event_name => 'oracle.apps.ar.hz.locservice.generatexml',
      p_event_key => l_event_key,
      p_event_data => NULL,
      p_parameters => l_parameter_list,
      p_send_date  => NULL);

  l_parameter_list.DELETE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Error: Aborting Location Service at worker level');
    ROLLBACK TO address_validation_w_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Error: Aborting Location Service at worker level');
    ROLLBACK TO address_validation_w_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN OTHERS THEN
    log('Error: Aborting Location Service at worker level');
    ROLLBACK TO address_validation_w_pub;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
END address_validation_worker;

-----------------------------------------------------------------------
-- Called from function rule outdoc_rule
-----------------------------------------------------------------------
-- As outdoc_rule raise wf event to parse xml, this function
-- rule which is defined for a wf event will be called.  The wf event
-- is called oracle.apps.ar.hz.locservice.parsexml
-- This function rule will do the following
-- 1) Get the parsed xml doc
-- 2) Check for tax validation
-- 3) Base on tax validation result, to determine whether to create/update
--    the validated addresses
------------------------------------------------------------------------
PROCEDURE get_validated_xml (
  p_adapter_id              IN NUMBER,
  p_overwrite_threshold     IN VARCHAR2,
  p_location_id             IN NUMBER,
  p_country                 IN VARCHAR2,
  p_address1                IN VARCHAR2,
  p_address2                IN VARCHAR2,
  p_address3                IN VARCHAR2,
  p_address4                IN VARCHAR2,
  p_county                  IN VARCHAR2,
  p_city                    IN VARCHAR2,
  p_prov_state_admin_code   IN VARCHAR2,
  p_postal_code             IN VARCHAR2,
  p_validation_status_code  IN VARCHAR2 )
IS
  l_location_rec            hz_location_v2pub.location_rec_type;
  l_location_profile_rec    hz_location_profile_pvt.location_profile_rec_type;
  l_location_profile_id     NUMBER;
  l_state                   VARCHAR2(60);
  l_province                VARCHAR2(60);
  l_country                 VARCHAR2(60);
  l_county                  VARCHAR2(60);
  l_postal_code             VARCHAR2(60);
  l_city                    VARCHAR2(60);
  l_obj_version_number      NUMBER;
  l_adapter_content_source  VARCHAR2(30);
  l_rowid                   ROWID := NULL;
  l_allow_update_std        VARCHAR2(1);
  l_maintain_history        VARCHAR2(1);
  l_dummy                   VARCHAR2(1);
  l_return_status           VARCHAR2(30);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_loc_id                  NUMBER;
  l_validation_status_code  NUMBER;
  l_overwrite_threshold     NUMBER;
  l_highest_score           NUMBER;
  l_validation_sst_flag     VARCHAR2(1);
  l_key                     VARCHAR2(500);
  l_party_id                NUMBER;

  CURSOR get_highest_score IS
  select max(to_number(lookup_code))
  from AR_LOOKUPS
  where lookup_type = 'HZ_ADDR_VAL_STATUS';

  CURSOR get_loc_obj_version_number(l_location_id NUMBER) IS
  select object_version_number, state, province, country,
         county, postal_code, city, rowid
  from HZ_LOCATIONS
  where location_id = l_location_id;

  CURSOR get_content_source(l_adapter_id NUMBER) IS
  select adapter_content_source
  from HZ_ADAPTERS
  where adapter_id = l_adapter_id;

  CURSOR is_active_profile(l_location_id NUMBER, l_adapter_content_source VARCHAR2) IS
  select 'X'
  from HZ_LOCATION_PROFILES
  where sysdate between effective_start_date and nvl(effective_end_date, sysdate)
  and actual_content_source = l_adapter_content_source
  and location_id = l_location_id;

  -- check if the current location record has been validated
  CURSOR is_standardized(l_location_id NUMBER) IS
  SELECT 'X'
  FROM hz_locations
  WHERE location_id = l_location_id
  AND date_validated IS NOT NULL
  AND validation_status_code IS NOT NULL;

  -- check if location has been used as identifying address
  CURSOR ident_address(l_location_id NUMBER) IS
  SELECT hps.party_id
  FROM   hz_party_sites hps
  WHERE  hps.location_id = l_location_id
  AND    hps.identifying_address_flag = 'Y';

BEGIN

  l_return_status := fnd_api.g_ret_sts_success;

  log('p_adapter_id: '||p_adapter_id);
  log('p_overwrite_threshold: '||p_overwrite_threshold);
  log('p_location_id: '||p_location_id);
  log('p_address1: '||p_address1);
  log('p_address2: '||p_address2);
  log('p_address3: '||p_address3);
  log('p_address4: '||p_address4);
  log('p_country: '||upper(p_country));
  log('p_county: '||p_county);
  log('p_city: '||p_city);
  log('p_prov_state_admin_code: '||p_prov_state_admin_code);
  log('p_postal_code: '||p_postal_code);
  log('p_validation_status_code: '||p_validation_status_code);

  OPEN get_highest_score;
  FETCH get_highest_score INTO l_highest_score;
  CLOSE get_highest_score;

  IF(p_validation_status_code IS NOT NULL) THEN
    l_validation_status_code := to_number(p_validation_status_code);
  ELSE
    log('validation_status_code is null');
    --l_validation_status_code := l_highest_score + 1;
  END IF;

  l_overwrite_threshold := to_number(p_overwrite_threshold);
  l_maintain_history := nvl(fnd_profile.value('HZ_MAINTAIN_LOC_HISTORY'), 'Y');

  -- if validation_status_code is less than or equal to overwrite threshold
  -- continue, otherwise do nothing.

    OPEN get_loc_obj_version_number(p_location_id);
    FETCH get_loc_obj_version_number INTO l_obj_version_number, l_state, l_province,
          l_country, l_county, l_postal_code, l_city, l_rowid;
    CLOSE get_loc_obj_version_number;

    log('country code in TCA: '||l_country);

    IF (NOT((upper(ltrim(rtrim(l_country)))) = (upper(ltrim(rtrim(p_country)))))) THEN
      log('Returning country does not match.  Ignore this address.');
      RETURN;
    END IF;

    OPEN get_content_source(p_adapter_id);
    FETCH get_content_source INTO l_adapter_content_source;
    CLOSE get_content_source;

    l_location_rec.location_id := p_location_id;
    l_location_rec.address1 := p_address1;
    l_location_rec.address2 := p_address2;
    l_location_rec.address3 := p_address3;
    l_location_rec.address4 := p_address4;
    /* Bug 3527919: get country code from database, don't get it from Trillium */
    --l_location_rec.country := upper(p_country);
    l_location_rec.country := l_country;
    l_location_rec.county := p_county;
    l_location_rec.city := p_city;
    l_location_rec.postal_code := p_postal_code;

    -- base on the existing location to find out
    -- whether prov_state_admin_code is state or province
    IF(l_state IS NOT NULL) THEN
      l_location_rec.state := p_prov_state_admin_code;
      l_location_rec.province := NULL;
    ELSIF(l_province IS NOT NULL) THEN
      l_location_rec.state := NULL;
      l_location_rec.province := p_prov_state_admin_code;
    ELSE
      l_location_rec.state := p_prov_state_admin_code;
      l_location_rec.province := NULL;
    END IF;

    validate_mandatory_column(l_location_rec, l_return_status);

    IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
      log('Expected error at update_location_profile.  Mandatory column checking failed.');
      RETURN;
    ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      log('Unexpected error at update_location_profile.  Mandatory column checking failed.');
      RETURN;
    END IF;

    -- Fix bug 3395521, if returned value is NULL, then pass it as g_miss to
    -- hz_location_profile_pvt
    l_location_profile_rec.location_id := p_location_id;
    l_location_profile_rec.address1 := nvl(p_address1,fnd_api.g_miss_char);
    l_location_profile_rec.address2 := nvl(p_address2,fnd_api.g_miss_char);
    l_location_profile_rec.address3 := nvl(p_address3,fnd_api.g_miss_char);
    l_location_profile_rec.address4 := nvl(p_address4,fnd_api.g_miss_char);
    /* Bug 3527919: get country code from database, don't get it from Trillium */
    --l_location_profile_rec.country := nvl(upper(p_country),fnd_api.g_miss_char);
    l_location_profile_rec.country := nvl(upper(l_country),fnd_api.g_miss_char);
    l_location_profile_rec.county := nvl(p_county,fnd_api.g_miss_char);
    l_location_profile_rec.city := nvl(p_city,fnd_api.g_miss_char);
    l_location_profile_rec.postal_code := nvl(p_postal_code,fnd_api.g_miss_char);
    l_location_profile_rec.prov_state_admin_code := nvl(p_prov_state_admin_code,fnd_api.g_miss_char);
    l_location_profile_rec.actual_content_source := nvl(l_adapter_content_source,fnd_api.g_miss_char);
    l_location_profile_rec.validation_status_code := nvl(p_validation_status_code,fnd_api.g_miss_char);
    l_location_profile_rec.date_validated := nvl(sysdate,fnd_api.g_miss_date);

  IF(l_validation_status_code <= l_overwrite_threshold) THEN

    log('Record has status code less than or equal to overwrite threshold.  Accept returned location.');
    hz_registry_validate_v2pub.tax_location_validation (
      p_location_rec          => l_location_rec,
      p_create_update_flag    => 'U',
      x_return_status         => l_return_status );

    -- not doing any update on HZ_LOCATIONS, but only
    -- put location profile to keep history if needed
    IF l_return_status = fnd_api.g_ret_sts_error THEN

      log('Tax validation not passed.');
      -- check if the adapter content source has active record
      -- with SST flag='Y' in location profile already
      -- 1) if not maintain history, don't do anything
      -- 2) if maintain history, create a new profile with end date = sysdate
      --    and sst flag = 'N'

      OPEN is_active_profile(p_location_id, l_adapter_content_source);
      FETCH is_active_profile INTO l_dummy;
      CLOSE is_active_profile;

      -- if maintain history is "No" and find existing actual_content_source
      -- then don't do anything, otherwise insert a new location profile
      -- but the location profile will have sst flag as "No" since it
      -- does not pass tax validation
      IF(NOT((l_maintain_history = 'N') AND (l_dummy IS NOT NULL))) THEN
/*
        l_location_profile_rec.validation_sst_flag := 'N';
        l_location_profile_rec.effective_start_date := sysdate;
        l_location_profile_rec.effective_end_date := sysdate;

        -- as this location does not pass tax validation, we only need to create
        -- an entry in location profiles.  Therefore, call create_location_profile
        hz_location_profile_pvt.create_location_profile (
          p_location_profile_rec      => l_location_profile_rec,
          x_location_profile_id       => l_location_profile_id,
          x_return_status             => l_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data
        );
*/
-- use update_location_profile instead.  location profile pvt can find out
-- whether to do create or update on location profile table base on
-- maintain history profile option and if adapter content source already exist

        l_location_profile_rec.validation_sst_flag := 'N';

        hz_location_profile_pvt.update_location_profile (
          p_location_profile_rec      => l_location_profile_rec,
          x_return_status             => l_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data
        );

        IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
          -- write to log file about the error
          -- not raising error, continue the next record
          log('Expected error at update_location_profile');
        ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          -- write to log file about the error
          -- not raising error, continue the next record
          log('Unexpected error at update_location_profile');
        END IF;
        log('Location profile updated.');
      END IF; -- maintain history
    ELSIF l_return_status = fnd_api.g_ret_sts_success THEN

      log('Tax validation passed.');
      BEGIN

        savepoint get_validated_xml_pub;

        l_allow_update_std := nvl(fnd_profile.value('HZ_UPDATE_STD_ADDRESS'), 'Y');
        l_dummy := NULL;

        OPEN is_standardized(l_location_rec.location_id);
        FETCH is_standardized INTO l_dummy;
        CLOSE is_standardized;

        -- location has been validated before and profile is set to 'N'
        -- only if validation_sst_flag is not passed
        IF((l_allow_update_std = 'N') AND (l_dummy IS NOT NULL)) THEN
          l_validation_sst_flag := 'N';
        ELSE
          l_validation_sst_flag := 'Y';
        END IF;

        -- set validation_sst_flag to null, let update_location_profile
        -- to determine the sst flag by checking profile option
        -- HZ_UPDATE_STD_ADDRESS and existing actual_content_source
        l_location_profile_rec.validation_sst_flag := l_validation_sst_flag;

        hz_location_profile_pvt.update_location_profile (
          p_location_profile_rec      => l_location_profile_rec,
          x_return_status             => l_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data
        );

        IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
          -- write to log file about the error
          -- not raising error, continue the next record
          log('Expected error at update_location_profile.  Rollback changes.');
          rollback to get_validated_xml_pub;
        ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          -- write to log file about the error
          -- not raising error, continue the next record
          log('Unexpected error at update_location_profile.  Rollback changes.');
          rollback to get_validated_xml_pub;
        ELSIF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- update HZ_LOCATIONS directly only if the allow update profile is yes
          -- AND validation_status_code is below threshold
          IF(l_validation_sst_flag = 'Y') THEN
            BEGIN

              log('Generate new address key.');

              -- call address key generation program
              l_key := hz_fuzzy_pub.generate_key (
                       'ADDRESS', NULL,
                       l_location_rec.address1,
                       l_location_rec.address2,
                       l_location_rec.address3,
                       l_location_rec.address4,
                       l_location_rec.postal_code,
                       NULL, NULL);
              log('Update location.');

              UPDATE hz_locations
              SET address1 = l_location_rec.address1,
                address2 = l_location_rec.address2,
                address3 = l_location_rec.address3,
                address4 = l_location_rec.address4,
                city = l_location_rec.city,
                country = l_location_rec.country,
                county = l_location_rec.county,
                state = l_location_rec.state,
                province = l_location_rec.province,
                postal_code = l_location_rec.postal_code,
                address_key = l_key,
                last_update_date = hz_utility_v2pub.last_update_date,
                last_updated_by = hz_utility_v2pub.last_updated_by,
                last_update_login = hz_utility_v2pub.last_update_login,
                validation_status_code = l_location_profile_rec.validation_status_code,
                date_validated = l_location_profile_rec.date_validated,
                object_version_number = nvl(object_version_number,1)+1
              WHERE location_id = l_location_rec.location_id;

              -- Fix bug 4169728.  Set address_text to null.
              UPDATE hz_cust_acct_sites_all cas
              SET cas.address_text = null
              WHERE cas.address_text IS NOT NULL
              AND EXISTS
              ( SELECT 1
                FROM HZ_PARTY_SITES ps
                WHERE ps.location_id = l_location_rec.location_id
                AND cas.party_site_id = ps.party_site_id );

              -- denormalize location if it has been used as identifying address
              BEGIN
                OPEN ident_address(l_location_rec.location_id);
                LOOP
                  FETCH ident_address INTO l_party_id;
                  EXIT WHEN ident_address%NOTFOUND;

                  IF(l_party_id <> -1) THEN

                    SELECT party_id
                    INTO   l_party_id
                    FROM   hz_parties
                    WHERE  party_id = l_party_id
                    FOR UPDATE NOWAIT;

                    log('Denormalize location record to party: '||l_party_id);

                    UPDATE HZ_PARTIES
                    SET country = l_location_rec.country,
                        address1 = l_location_rec.address1,
                        address2 = l_location_rec.address2,
                        address3 = l_location_rec.address3,
                        address4 = l_location_rec.address4,
                        city = l_location_rec.city,
                        county = l_location_rec.county,
                        postal_code = l_location_rec.postal_code,
                        state = l_location_rec.state,
                        province = l_location_rec.province,
                        last_update_date = hz_utility_v2pub.last_update_date,
                        last_updated_by = hz_utility_v2pub.last_updated_by,
                        last_update_login = hz_utility_v2pub.last_update_login,
                        request_id = hz_utility_v2pub.request_id,
                        program_id = hz_utility_v2pub.program_id,
                        program_application_id = hz_utility_v2pub.program_application_id,
                        program_update_date = hz_utility_v2pub.program_update_date
                    WHERE party_id = l_party_id;
                  END IF;
                END LOOP;
                CLOSE ident_address;

              EXCEPTION
                WHEN OTHERS THEN
                  log('Cannot update party due to record change.');
                  fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
                  fnd_message.set_token('TABLE', 'HZ_PARTIES');
                  fnd_msg_pub.add;
                  CLOSE ident_address;
                  RAISE fnd_api.g_exc_error;
              END;

              IF((l_location_rec.country IS NOT NULL AND
                NVL(l_country, fnd_api.g_miss_char) <> l_location_rec.country)
              OR (l_location_rec.city IS NOT NULL AND
                NVL(l_city, fnd_api.g_miss_char) <> l_location_rec.city)
              OR (l_location_rec.postal_code IS NOT NULL AND
                NVL(l_postal_code, fnd_api.g_miss_char) <> l_location_rec.postal_code)
              OR (l_location_rec.state IS NOT NULL AND
                NVL(l_state, fnd_api.g_miss_char) <> l_location_rec.state)
              OR (l_location_rec.province IS NOT NULL AND
                NVL(l_province,fnd_api.g_miss_char) <> l_location_rec.province)
              OR (l_location_rec.county IS NOT NULL AND
                NVL(l_county, fnd_api.g_miss_char) <> l_location_rec.county)) THEN
/*
                log('Start ARP_ADDS.Set_Location_CCID call.');
                -- call ARP_ADDS.Set_Location_CCID, according to bug 2983977
                -- this should be replaced by new api call that we don't need
                -- set org context before calling this api.
                -- related bug is 3105634.  This is replaced by 3124266.
                -- According to bug 3105634, the original api will change
                -- org context and pass org_id to the new api
                ARP_ADDS.Set_Location_CCID(l_location_rec.country,
                                           l_location_rec.city,
                                           l_location_rec.state,
                                           l_location_rec.county,
                                           l_location_rec.province,
                                           l_location_rec.postal_code,
                                           l_location_rec.attribute1,
                                           l_location_rec.attribute2,
                                           l_location_rec.attribute3,
                                           l_location_rec.attribute4,
                                           l_location_rec.attribute5,
                                           l_location_rec.attribute6,
                                           l_location_rec.attribute7,
                                           l_location_rec.attribute8,
                                           l_location_rec.attribute9,
                                           l_location_rec.attribute10,
                                           l_loc_id,
                                           l_location_rec.location_id );

                log('End ARP_ADDS.Set_Location_CCID call.');
*/
                set_loc_assign_id(p_location_rec    => l_location_rec,
                                  x_return_status   => l_return_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data );

                IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
                  -- write to log file about the error
                  -- not raising error, continue the next record
                  log('Expected error at set_loc_assign_id.  Location Id: '||l_location_rec.location_id||'. Rollback changes.');
                  rollback to get_validated_xml_pub;
                ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  -- write to log file about the error
                  -- not raising error, continue the next record
                  log('UnExpected error at set_loc_assign_id.  Location Id: '||l_location_rec.location_id||'. Rollback changes.');
                  rollback to get_validated_xml_pub;
                END IF; -- check if fields are not null
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                log('Error happens at update location.  Rollback changes.');
                log('SQLERRM: '||SQLERRM);
                rollback to get_validated_xml_pub;
            END;

          END IF; -- check allow update standardized address
        END IF; -- update location profiles
      END; -- begin tax if validation pass
    END IF; -- check return status of tax validation

  ELSIF(l_validation_status_code > l_overwrite_threshold) THEN

    log('Record has status code greater than threshold.  Reject returned location.');
    -- A) if maintain history is 'Y', check if existing location profile exist or not
    -- 1) location profile exist, then check sst flag of the existing location profile
    --   a) Y: then create location profile with sst flag = 'N'
    --   b) N: then create location profile with sst flag = 'N' and end date
    --         existing record
    -- 2) location profile not exist, create location profile with sst flag = 'N'
    -- B) if maintain history is 'N', check if existing location profile exist or not
    -- 1) location profile exist, then check sst flag of the existing location profile
    --   a) Y: do nothing
    --   b) N: update existing location
    -- 2) location profile not exist, create location profile with sst flag = 'N'

    l_location_profile_rec.validation_sst_flag := 'N';
    --l_location_profile_rec.effective_start_date := sysdate;
    --l_location_profile_rec.effective_end_date := sysdate;

    hz_location_profile_pvt.update_location_profile (
      p_location_profile_rec      => l_location_profile_rec,
      x_return_status             => l_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data
    );

  ELSE
    log('Abnormal termination at this record.');
  END IF;  -- compare validation_status_code and overwrite_threshold

END get_validated_xml;

PROCEDURE set_loc_assign_id (
  p_location_rec    IN         hz_location_v2pub.location_rec_type,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
)
IS
/*
  CURSOR c_org(l_loc_id NUMBER) IS
  select distinct org_id
  from hz_loc_assignments
  where location_id = l_loc_id;
*/
  CURSOR chk_gnr(l_loc_id NUMBER) IS
  select 1
  from hz_geo_name_reference_log
  where location_table_name = 'HZ_LOCATIONS'
  and location_id = l_loc_id
  and rownum = 1;

  l_location_rec    hz_location_v2pub.location_rec_type;
  l_loc_id           NUMBER;
  l_default_country  VARCHAR2(2);
  l_org_id           NUMBER;
  l_is_remit_to_location   VARCHAR2(1) := 'N';
  l_loc_assignment_exist   VARCHAR2(1) := 'N';
  l_dummy                  NUMBER;
BEGIN
  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_location_rec := p_location_rec;

  -- Fix bug 4539117
  OPEN chk_gnr(l_location_rec.location_id);
  FETCH chk_gnr INTO l_dummy;
  CLOSE chk_gnr;

  IF(l_dummy IS NOT NULL) THEN
    log('Start HZ_GNR_PUB.PROCESS_GNR call.');
    HZ_GNR_PUB.PROCESS_GNR(p_location_table_name => 'HZ_LOCATIONS',
                           p_location_id         => l_location_rec.location_id,
                           p_call_type           => 'U',
                           x_return_status       => x_return_status,
                           x_msg_count           => x_msg_count,
                           x_msg_data            => x_msg_data);
    log('End HZ_GNR_PUB.PROCESS_GNR call.');
  ELSE
    log('No need to call HZ_GNR_PUB.PROCESS_GNR.');
  END IF;
/*
  BEGIN
    SELECT  'Y'
    INTO    l_loc_assignment_exist
    FROM    DUAL
    WHERE   EXISTS ( SELECT 1
                     FROM HZ_LOC_ASSIGNMENTS la
                     WHERE la.location_id = l_location_rec.location_id );
    SELECT  'Y'
    INTO    l_is_remit_to_location
    FROM    DUAL
    WHERE   EXISTS ( SELECT  1
                     FROM    HZ_PARTY_SITES PS
                     WHERE   PS.LOCATION_ID = l_location_rec.location_id
                     AND     PS.PARTY_ID = -1);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
  END;

  log('Loc Assignment Exist: '||l_loc_assignment_exist);
  log('Is Remit to Location: '||l_is_remit_to_location);

  OPEN c_org(l_location_rec.location_id);
  LOOP
    FETCH c_org INTO l_org_id;
    IF c_org%NOTFOUND THEN
      EXIT;
    END IF;

    log('Org id: '||l_org_id);

    BEGIN
      SELECT default_country
      INTO   l_default_country
      FROM   ar_system_parameters_all
      WHERE  org_id = l_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME( 'AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
           FND_MSG_PUB.ADD;
           --x_return_status := FND_API.G_RET_STS_ERROR;
    END;

    log('Country: '||l_location_rec.country);
    log('Default country for the org: '||l_default_country);

    IF l_location_rec.country = l_default_country
    AND l_is_remit_to_location = 'N'
    AND l_loc_assignment_exist = 'Y' THEN
      BEGIN
        log('Start ARP_ADDS.Set_Location_CCID call.');
        -- call ARP_ADDS.Set_Location_CCID, according to bug 2983977
        -- this should be replaced by new api call that we don't need
        -- set org context before calling this api.
        -- related bug is 3105634.  This is replaced by 3124266.
        -- According to bug 3105634, the original api will change
        -- org context and pass org_id to the new api
        ARP_ADDS.Set_Location_CCID(l_location_rec.country,
                                   l_location_rec.city,
                                   l_location_rec.state,
                                   l_location_rec.county,
                                   l_location_rec.province,
                                   l_location_rec.postal_code,
                                   l_location_rec.attribute1,
                                   l_location_rec.attribute2,
                                   l_location_rec.attribute3,
                                   l_location_rec.attribute4,
                                   l_location_rec.attribute5,
                                   l_location_rec.attribute6,
                                   l_location_rec.attribute7,
                                   l_location_rec.attribute8,
                                   l_location_rec.attribute9,
                                   l_location_rec.attribute10,
                                   l_loc_id,
                                   l_location_rec.location_id,
                                   l_org_id );

        log('End ARP_ADDS.Set_Location_CCID call.');
      END;
    ELSE
      log('No need to do Set_Location_CCID');
    END IF;
  END LOOP;
  CLOSE c_org;
*/
END set_loc_assign_id;

PROCEDURE submit_addrval_request (
  p_adapter_log_id  IN  NUMBER,
  p_adapter_id      IN  NUMBER DEFAULT NULL,
  p_country_code    IN  VARCHAR2 DEFAULT NULL,
  p_module          IN  VARCHAR2 DEFAULT NULL,
  p_module_id       IN  NUMBER DEFAULT NULL,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2 )
IS

  out_doc           NCLOB;

  CURSOR get_xml(l_adapter_log_id  NUMBER) IS
  select to_nclob(out_doc)
  from HZ_ADAPTER_LOGS
  where adapter_log_id = l_adapter_log_id;

BEGIN
  null;
/*
  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_xml(p_adapter_log_id);
  FETCH get_xml INTO out_doc;
  CLOSE get_xml;

  submit_addrval_doc (
    p_addrval_doc            => out_doc,
    p_adapter_id             => p_adapter_id,
    p_country_code           => p_country_code,
    p_module                 => p_module,
    p_module_id              => p_module_id,
    x_return_status          => x_return_status,
    x_msg_count              => x_msg_count,
    x_msg_data               => x_msg_data );

  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Error: Aborting Location Service at submit request: '||p_adapter_log_id);
    FND_FILE.close;
  --  Retcode := 2;
  --  Errbuf := logerror(SQLERRM);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Error: Aborting Location Service at submit request: '||p_adapter_log_id);
    FND_FILE.close;
  --  Retcode := 2;
  --  Errbuf := logerror(SQLERRM);

  WHEN OTHERS THEN
    log('Error: Aborting Location Service at submit request: '||p_adapter_log_id);
    log('SQL Error: '||SQLERRM);
    FND_FILE.close;
  --  Retcode := 2;
  --  Errbuf := logerror(SQLERRM);
*/
END submit_addrval_request;

-----------------------------------------------------------------------
-- Called from function rule outdoc_rule
-----------------------------------------------------------------------
-- This procedure is used to submit address validation request to vendor
-- if adapter code is not passed, country code must exist.  Then api
-- will find the default adapter from profile.
-- if adapter code is passed, api will call address validation service
-- by using the pass in adapter.
-- if both adapter code and country code are not passed, raise error
-- It does the following
-- 1) Set timeout
-- 2) Begin request
-- 3) Send XML doc to vendor
-- 4) Receive response from vendor
-- 5) Return XML doc
------------------------------------------------------------------------
PROCEDURE submit_addrval_doc (
  p_addrval_doc     IN OUT NOCOPY NCLOB,
  p_adapter_id      IN NUMBER DEFAULT NULL,
  p_country_code    IN VARCHAR2 DEFAULT NULL,
  p_module          IN VARCHAR2 DEFAULT NULL,
  p_module_id       IN NUMBER DEFAULT NULL,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2 )
IS
  l_return_status   VARCHAR2(30);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  out_xml           CLOB;
  in_xml            CLOB;
  http_req          UTL_HTTP.REQ;
  http_resp         UTL_HTTP.RESP;
  instream          VARCHAR2(32767);
  outstream         VARCHAR2(32767);
  outlength         NUMBER;
  fl                NUMBER;
  l_adapter_id      NUMBER;
  l_adapter_log_id  NUMBER := NULL;
  l_dummy           VARCHAR2(1);
  l_resp_status     NUMBER;
  l_rowid           ROWID;
  l_write_log       VARCHAR2(1);
  l_timeout         VARCHAR2(30);
  l_timeout_num     NUMBER;
  offset_var        INTEGER;
  amount_var        INTEGER;

  outstreams        outstreams_type;
  outlengthb        NUMBER;

BEGIN

  savepoint submit_addrval_doc_pub;
  --FND_MSG_PUB.initialize;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  log('Adapter ID: '||p_adapter_id);
  log('Country Code: '||p_country_code);
  l_adapter_id := get_adapter_id(p_adapter_id, p_country_code);
  IF(l_adapter_id IS NULL) THEN
    log('Invalid adapter id: '||l_adapter_id);
    log('p_adapter_id: '||p_adapter_id);
    log('p_country_code: '||p_country_code);
    FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_ADAPTER');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_write_log := nvl(fnd_profile.value('HZ_WRITE_ADAPTER_LOG'), 'N');

  -- base on profile option value to determine if write log is required
  IF(l_write_log = 'Y') THEN
    save_adapter_log(
      p_create_or_update        => 'C',
      px_rowid                  => l_rowid,
      px_adapter_log_id         => l_adapter_log_id,
      p_created_by_module       => p_module,
      p_created_by_module_id    => p_module_id,
      p_http_status_code        => NULL,
      p_request_id              => hz_utility_v2pub.request_id,
      p_object_version_number   => 1,
      p_inout_doc               => to_clob(p_addrval_doc) );

    log('Adapter Log ID: '||l_adapter_log_id);
  END IF;

  IF(l_adapter_log_id IS NOT NULL) THEN
    BEGIN
      SELECT rowid INTO l_rowid
      FROM HZ_ADAPTER_LOGS
      WHERE adapter_log_id = l_adapter_log_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        log('Cannot find adapter log: '||l_adapter_log_id);
        log('x_created_by_module: '||p_module);
        log('x_created_by_module_id: '||p_module_id);
        RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;

  BEGIN

    -- set proxy
    --as currently, all vendor are install base, we don't need to specify proxy
    --log('Set Proxy');
    set_proxy();--bug 6412174

    -- set to activate detail exception support
    log('Set Detailed Exception Support');
    UTL_HTTP.SET_DETAILED_EXCP_SUPPORT(enable=>true);

    -- get timeout profile option value
    -- default value is 300 seconds
    l_timeout := FND_PROFILE.VALUE('HZ_LOC_TIMEOUT');
    log('Profile option value of Location Timeout: '||l_timeout);
    IF(l_timeout IS NULL) THEN
      l_timeout_num := 300;
    ELSE
      BEGIN
        l_timeout_num := to_number(l_timeout);
      EXCEPTION
        WHEN OTHERS THEN
          log('Timeout Limit is not numeric.  Set timeout limit to 2000 seconds.');
          l_timeout_num := 300;
      END;
    END IF;
    log('Set Transfer Timeout to '||l_timeout_num||' second(s).');
    UTL_HTTP.SET_TRANSFER_TIMEOUT(l_timeout_num);

    -- set response error check
    log('Set Response Error Check');
    UTL_HTTP.SET_RESPONSE_ERROR_CHECK(TRUE);

    -- begin request
    log('Begin Location Service Request');
    -- get port and url from adapter setup
    http_req := UTL_HTTP.BEGIN_REQUEST(get_adapter_link(l_adapter_id), 'POST', UTL_HTTP.HTTP_VERSION_1_1);

    -- user authentication
    -- will get error after get response, error code should be 401 (HTTP_UNAUTHORIZED)
    -- ?? should have begin_request get action and get_response for authentication first and
    -- ?? then do another begin request post action for sending out xml doc
    -- according to HLD, authentication is necessary for some vendor with pay per use solution outside the
    -- users' firewall.  For those who install locally will not require this
    -- check if not install locally, then do authentication
    -- ********************************* --
    -- log('Begin User Authentication');
    -- set_authentication (http_req, l_adapter_id);
    -- ********************************* --

    -- set header
    -- since we know the length of the document, we don't need to do chunk on the output
    -- Content-Length will be set if output xml found
    log('Set Header for HTTP Connection');
    UTL_HTTP.SET_HEADER(http_req, 'Content-Type', 'application/x-www-form-urlencoded');

    -- set transfer encoding to chunked
    --UTL_HTTP.SET_HEADER(http_req, 'Transfer-Encoding', 'chunked');

    -- fix bug 4271311 - multi-bytes characters garbled
    UTL_HTTP.SET_BODY_CHARSET(http_req, 'UTF-8');

    out_xml := to_clob(p_addrval_doc);

    amount_var := MAX_LENGTH;

    -- loop through the length of clob and do write_text
    outlength := dbms_lob.getlength(out_xml);
    -- initialize outlengthb.  outlengthb is the actual length of character
    -- based on charset.  For double byte character, the actual length should
    -- be half of the outlength.
    outlengthb := 0;

    -- ** Oracle charset is 'UTF8' (without a dash, not 'UTF-8')
    IF(outlength <= MAX_LENGTH) THEN
      -- fix bug 3754442
      --outstream := out_xml;
      dbms_lob.read(out_xml,outlength,1,outstream);
      -- Count the actual length of characters to be sent by converting to UTF8 charset
      -- this outlengthb is used to set the content length
      outlengthb := LENGTHB(convert(outstream, 'UTF8'));
      log('Length of xml: '||outlengthb);
      UTL_HTTP.SET_HEADER(http_req, 'Content-Length', to_char(outlengthb));
      UTL_HTTP.WRITE_TEXT(http_req, outstream);
    ELSE
      -- Fix bug 4271311
      -- First get all data to outstreams ARRAY
      -- Count the total length of data based on UTF8 charset
      -- Set content-length
      -- Write text
      fl := floor(outlength/MAX_LENGTH);
      FOR i in 1..fl LOOP
        offset_var := ((i-1)*MAX_LENGTH)+1;
        dbms_lob.read(out_xml,amount_var,offset_var,outstream);
        --UTL_HTTP.WRITE_TEXT(http_req, outstream);
        log('Set outstreams');
        outstreams(i) := outstream;
        log('In Loop: '||i);
        outlengthb := outlengthb + LENGTHB(convert(outstream, 'UTF8'));
      END LOOP;
      amount_var := outlength-(fl*MAX_LENGTH);
      offset_var := (fl*MAX_LENGTH)+1;
      -- read only if the amount is larger than 0
      IF(amount_var > 0) THEN
        dbms_lob.read(out_xml,amount_var,offset_var,outstream);
      END IF;

      --UTL_HTTP.WRITE_TEXT(http_req, outstream);
      outstreams(fl+1) := outstream;
      outlengthb := outlengthb + LENGTHB(convert(outstream, 'UTF8'));
      log('Out of Loop: ');
      log('Length of xml: '||outlengthb);
      -- Base on charset to set the content length
      UTL_HTTP.SET_HEADER(http_req, 'Content-Length', to_char(outlengthb));
      FOR i IN 1..fl+1 LOOP
        UTL_HTTP.WRITE_TEXT(http_req, outstreams(i));
      END LOOP;
    END IF;

    -- wait for response from vendor
    log('Get Response from Vendor');
    http_resp := UTL_HTTP.GET_RESPONSE(http_req);
    log('- Resp.status_code: '||http_resp.status_code);
    log('- Resp.reason_phrase: '||http_resp.reason_phrase);
    log('- Resp.http_version: '||http_resp.http_version);
    log('- Resp.private_hndl: '||http_resp.private_hndl);
    l_resp_status := http_resp.status_code;

    -- ?? only accept response status code 200 ??
    IF(http_resp.status_code = 200) THEN
      BEGIN
      LOOP
        UTL_HTTP.READ_TEXT(http_resp, instream);
        in_xml := in_xml||instream;
      END LOOP;
      EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
          log('Location Service Transfer Finished');
        WHEN UTL_HTTP.TRANSFER_TIMEOUT THEN
          log('Location Service Timeout Occur');
          -- need message for invalid adapter
          FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_TIMEOUT');
          RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          log('Location Service Others Error Occur');
          -- need message for invalid adapter
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;

    UTL_HTTP.END_RESPONSE(http_resp);

  EXCEPTION
    /* The exception handling illustrates the use of "pragma-ed" exceptions
       like Utl_Http.Http_Client_Error. In a realistic example, the program
       would use these when it coded explicit recovery actions.
       Request_Failed is raised for all exceptions after calling
       Utl_Http.Set_Detailed_Excp_Support ( enable=>false )
       And it is NEVER raised after calling with enable=>true */
    WHEN UTL_HTTP.REQUEST_FAILED THEN
      log('REQUEST_FAILED: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
      --FND_FILE.close;
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_ERROR');
      RAISE FND_API.G_EXC_ERROR;

    -- raised by URL http://xxx.oracle.com/
    WHEN UTL_HTTP.HTTP_SERVER_ERROR THEN
      log('HTTP_SERVER_ERROR: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
      --FND_FILE.close;
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_ERROR');
      RAISE FND_API.G_EXC_ERROR;

    -- raised by URL http://otn.oracle.com/xxx
    WHEN UTL_HTTP.HTTP_CLIENT_ERROR THEN
      log('HTTP_CLIENT_ERROR: ' || UTL_HTTP.GET_DETAILED_SQLERRM);
      --FND_FILE.close;
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_ERROR');
      RAISE FND_API.G_EXC_ERROR;

    WHEN UTL_HTTP.TRANSFER_TIMEOUT THEN
      log('HTTP TRANSFER TIMEOUT: '|| UTL_HTTP.GET_DETAILED_SQLERRM);
      --FND_FILE.close;
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_ERROR');
      RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
      log('HTTP OTHER EXCEPTION: '|| UTL_HTTP.GET_DETAILED_SQLERRM);
      log('Check SQL EXCEPTION: '|| SQLERRM);
      --FND_FILE.close;
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_ERROR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- ************************************************************************************ --
  -- update log for this transaction, from the id of the log and will update the inbound doc
  -- ************************************************************************************ --
  IF(l_adapter_log_id IS NOT NULL) THEN
    save_adapter_log(
      p_create_or_update        => 'U',
      px_rowid                  => l_rowid,
      px_adapter_log_id         => l_adapter_log_id,
      p_created_by_module       => NULL,
      p_created_by_module_id    => NULL,
      p_http_status_code        => l_resp_status,
      p_request_id              => NULL,
      p_object_version_number   => 2,
      p_inout_doc               => in_xml );
  END IF;

  p_addrval_doc := to_nclob(in_xml);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Error: Aborting Location Service');
    --FND_FILE.close;
    ROLLBACK TO submit_addrval_doc_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Error: Aborting Location Service');
    --FND_FILE.close;
    ROLLBACK TO submit_addrval_doc_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    log('Error: Aborting Location Service');
    log('SQL Error: '||SQLERRM);
    --FND_FILE.close;
    ROLLBACK TO submit_addrval_doc_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

END submit_addrval_doc;

FUNCTION get_adapter_id(
  p_adapter_id       IN NUMBER DEFAULT NULL,
  p_country_code     IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS
  l_adapter_id       NUMBER;
  l_dummy            VARCHAR2(1);

  CURSOR get_country_adapter(l_country_code VARCHAR2) IS
  select la.adapter_id
  from HZ_ADAPTERS la, HZ_ADAPTER_TERRITORIES t
  where la.adapter_id = t.adapter_id
  and t.territory_code = l_country_code
  and t.enabled_flag = 'Y'
  and t.default_flag = 'Y'
  and la.enabled_flag = 'Y'
  and rownum = 1;

  CURSOR is_adapter_good(l_adapter_id NUMBER) IS
  select 'X'
  from HZ_ADAPTERS
  where adapter_id = l_adapter_id
  and enabled_flag = 'Y';

BEGIN

  -- pass adapter_id
  IF(p_adapter_id IS NOT NULL) THEN
    OPEN is_adapter_good(p_adapter_id);
    FETCH is_adapter_good INTO l_dummy;
    CLOSE is_adapter_good;
    IF(l_dummy IS NULL) THEN
      l_adapter_id := NULL;
    ELSE
      l_adapter_id := p_adapter_id;
    END IF;
  ELSE
    IF(p_country_code IS NOT NULL) THEN
      -- get default adapter of the country
      OPEN get_country_adapter(p_country_code);
      FETCH get_country_adapter INTO l_adapter_id;
      CLOSE get_country_adapter;
    END IF;

    -- try to get adapter_id from profile if not found for country_code
    IF(l_adapter_id IS NULL) THEN
      -- get default adapter from profile base
      l_adapter_id := fnd_profile.value('HZ_DEFAULT_LOC_ADAPTER');
    END IF;

  END IF;

  RETURN l_adapter_id;

END get_adapter_id;

PROCEDURE get_fromnto_value(
  p_max         IN  VARCHAR2,
  p_min         IN  VARCHAR2,
  p_op          IN  VARCHAR2,
  p_in          IN  VARCHAR2,
  p_nvl_out     OUT NOCOPY VARCHAR2,
  p_from_out    OUT NOCOPY VARCHAR2,
  p_to_out      OUT NOCOPY VARCHAR2 ) IS

BEGIN

  IF((p_op IS NULL) OR (p_in IS NULL)) THEN
    p_nvl_out := p_min;
    p_from_out := p_min;
    p_to_out := p_max;
  ELSE
    p_nvl_out := p_in;
    IF((p_op = '>') OR (p_op = '>=')) THEN
      p_from_out := p_in;
      p_to_out := p_max;
    ELSIF((p_op = '<') OR (p_op = '<=')) THEN
      p_from_out := p_min;
      p_to_out := p_in;
    ELSIF(p_op = '=') THEN
      p_from_out := p_in;
      p_to_out := p_in;
    END IF;
  END IF;

END get_fromnto_value;

/**
  * Procedure to add parameters to generate xml doc
  **/

PROCEDURE add_wf_parameters(
  p_adapter_id  IN      NUMBER,
  p_overwrite_threshold  IN VARCHAR2,
  p_country     IN      VARCHAR2,
  p_nvl_vsc     IN      VARCHAR2,
  p_from_vsc    IN      VARCHAR2,
  p_to_vsc      IN      VARCHAR2,
  p_from_lud    IN      VARCHAR2,
  p_to_lud      IN      VARCHAR2,
  p_nvl_dv      IN      VARCHAR2,
  p_from_dv     IN      VARCHAR2,
  p_to_dv       IN      VARCHAR2,
  p_num_batch   IN      NUMBER,
  p_batch_seq   IN      NUMBER,
  p_parameter_list  OUT NOCOPY wf_parameter_list_t ) IS

BEGIN
-- map code
  wf_event.AddParameterToList(
    p_name => 'ECX_MAP_CODE',
    p_value => 'LOCSERV_OUT',
    p_parameterlist => p_parameter_list);

-- adapter_id
  wf_event.AddParameterToList(
    p_name => 'ADAPTER_ID',
    p_value => p_adapter_id,
    p_parameterlist => p_parameter_list);

-- overwrite_threshold
  wf_event.AddParameterToList(
    p_name => 'OVERWRITE_THRESHOLD',
    p_value => p_overwrite_threshold,
    p_parameterlist => p_parameter_list);

-- country
  wf_event.AddParameterToList(
    p_name => 'COUNTRY',
    p_value => p_country,
    p_parameterlist => p_parameter_list);

-- last_update_date
  wf_event.AddParameterToList(
    p_name => 'FROM_LUD',
    p_value => p_from_lud,
    p_parameterlist => p_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'TO_LUD',
    p_value => p_to_lud,
    p_parameterlist => p_parameter_list);

-- date_validated
  wf_event.AddParameterToList(
    p_name => 'NVL_DV',
    p_value => p_nvl_dv,
    p_parameterlist => p_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'FROM_DV',
    p_value => p_from_dv,
    p_parameterlist => p_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'TO_DV',
    p_value => p_to_dv,
    p_parameterlist => p_parameter_list);

-- validation_status_code
  wf_event.AddParameterToList(
    p_name => 'NVL_VSC',
    p_value => p_nvl_vsc,
    p_parameterlist => p_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'FROM_VSC',
    p_value => p_from_vsc,
    p_parameterlist => p_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'TO_VSC',
    p_value => p_to_vsc,
    p_parameterlist => p_parameter_list);

-- Total number of batch required
  wf_event.AddParameterToList(
    p_name => 'NUM_BATCH',
    p_value => p_num_batch,
    p_parameterlist => p_parameter_list);

-- The batch number
  wf_event.AddParameterToList(
    p_name => 'BATCH_SEQUENCE',
    p_value => p_batch_seq,
    p_parameterlist => p_parameter_list);

END add_wf_parameters;

PROCEDURE save_adapter_log(
  p_create_or_update      IN VARCHAR2,
  px_rowid                IN OUT NOCOPY ROWID,
  px_adapter_log_id       IN OUT NOCOPY NUMBER,
  p_created_by_module     IN VARCHAR2,
  p_created_by_module_id  IN NUMBER,
  p_http_status_code      IN VARCHAR2,
  p_request_id            IN NUMBER,
  p_object_version_number IN NUMBER,
  p_inout_doc             IN CLOB ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF(p_create_or_update = 'C') THEN
    HZ_ADAPTER_LOGS_PKG.Insert_Row(
      x_adapter_log_id          => px_adapter_log_id,
      x_created_by_module       => p_created_by_module,
      x_created_by_module_id    => p_created_by_module_id,
      x_http_status_code        => p_http_status_code,
      x_request_id              => p_request_id,
      x_object_version_number   => p_object_version_number );

      UPDATE HZ_ADAPTER_LOGS
      SET out_doc = p_inout_doc
      WHERE adapter_log_id = px_adapter_log_id;
  ELSE
    HZ_ADAPTER_LOGS_PKG.Update_Row(
      x_rowid                   => px_rowid,
      x_adapter_log_id          => px_adapter_log_id,
      x_created_by_module       => NULL,
      x_created_by_module_id    => NULL,
      x_http_status_code        => p_http_status_code,
      x_request_id              => NULL,
      x_OBJECT_VERSION_NUMBER   => p_object_version_number );

      UPDATE HZ_ADAPTER_LOGS
      SET in_doc = p_inout_doc
      WHERE adapter_log_id = px_adapter_log_id;
  END IF;

  COMMIT;
END save_adapter_log;

/**
  * Procedure to write a message to the log file
  **/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put_line(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

FUNCTION get_adapter_link(p_adapter_id NUMBER)
RETURN VARCHAR2 IS
  l_adapter_url    VARCHAR2(2000);
  l_adapter_link   VARCHAR2(2000);
BEGIN
  SELECT host_address
  INTO l_adapter_url
  FROM HZ_ADAPTERS
  WHERE ADAPTER_ID = p_adapter_id;

  IF(l_adapter_url IS NOT NULL) THEN
    l_adapter_link := rtrim(ltrim(l_adapter_url));
  END IF;

  RETURN l_adapter_link;
END get_adapter_link;

FUNCTION indoc_rule (
  p_subscription_guid   IN RAW,
  p_event               IN OUT NOCOPY wf_event_t )
RETURN VARCHAR2 IS
  l_event_data          CLOB := NULL;
  l_ecx_map_code        VARCHAR2(30);
  l_adapter_id          NUMBER;
  l_overwrite_threshold VARCHAR2(30);
  l_batch_sequence      NUMBER;
  l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
BEGIN
  Log('indoc_rule called');
  l_event_data := p_event.getEventData;
  IF(l_event_data IS NOT NULL) THEN
    l_ecx_map_code := p_event.getValueForParameter('ECX_MAP_CODE');
    l_adapter_id := p_event.getValueForParameter('ADAPTER_ID');
    l_overwrite_threshold := p_event.getValueForParameter('OVERWRITE_THRESHOLD');
    l_batch_sequence := p_event.getValueForParameter('BATCH_SEQUENCE');
    Log('ECX Map Code: '||l_ecx_map_code);
    Log('Adapter_Id: '||l_adapter_id);
    Log('Overwrite_Threshold: '||l_overwrite_threshold);
    Log('Batch_Sequence: '||l_batch_sequence);

    ecx_standard.processXMLCover(
      i_map_code    =>l_ecx_map_code,
      i_inpayload   =>l_event_data,
      i_debug_level =>3
    );

  END IF;
  RETURN 'SUCCESS';
END indoc_rule;

PROCEDURE validate_mandatory_column(
   p_location_rec     IN      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
   x_return_status    IN OUT NOCOPY  VARCHAR2) IS
BEGIN

   IF(p_location_rec.address1 IS NULL OR p_location_rec.address1 = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'ADDRESS1');
     FND_MSG_PUB.ADD;
     log('Address1 is mandatory');
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(p_location_rec.country IS NULL OR p_location_rec.country = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'COUNTRY');
     FND_MSG_PUB.ADD;
     log('Country is mandatory');
     RAISE FND_API.G_EXC_ERROR;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END validate_mandatory_column;

-----------------------------------------------------------------------
-- Called from address_validation
-----------------------------------------------------------------------
-- As address_validation raise wf event to generate xml, this function
-- rule which is defined for a wf event will be called.  The wf event
-- is called oracle.apps.ar.hz.locservice.generatexml
-- This function rule will do the following
-- 1) Get the generated xml doc
-- 2) Pass the xml doc to submit_addrval_doc
-- 3) Get returned validated xml doc, raise another wf event to parse
--    the validated addresses.
------------------------------------------------------------------------
FUNCTION outdoc_rule (
  p_subscription_guid   IN RAW,
  p_event               IN OUT NOCOPY wf_event_t )
RETURN VARCHAR2 IS
  l_event_data          CLOB := NULL;
  l_event_nclob_data    NCLOB := NULL;
  l_adapter_id          NUMBER;
  l_overwrite_threshold VARCHAR2(30);
  l_batch_sequence      NUMBER;
  l_adapter_log_id      NUMBER;
  l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
  errmsg                VARCHAR2(2000);
  l_return_status       VARCHAR2(30);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_event_key           VARCHAR2(100);
BEGIN
  Log('NEWLINE');
  Log('outdoc_rule called');
  l_event_data := p_event.getEventData;
  IF(l_event_data IS NOT NULL) THEN
    l_adapter_id := p_event.getValueForParameter('ADAPTER_ID');
    l_overwrite_threshold := p_event.getValueForParameter('OVERWRITE_THRESHOLD');
    l_batch_sequence := p_event.getValueForParameter('BATCH_SEQUENCE');
    Log('Adapter Id: '||l_adapter_id);
    Log('Overwrite Threshold: '||l_overwrite_threshold);
    Log('Batch Sequence: '||l_batch_sequence);
  END IF;

  l_event_nclob_data := to_nclob(l_event_data);

  submit_addrval_doc (
    p_addrval_doc     => l_event_nclob_data,
    p_adapter_id      => l_adapter_id,
    p_country_code    => NULL,
    p_module          => 'HZ_LOCSERVICE',
    p_module_id       => hz_utility_v2pub.request_id,
    x_return_status   => l_return_status,
    x_msg_count       => l_msg_count,
    x_msg_data        => l_msg_data );

  l_event_data := to_clob(l_event_nclob_data);

  IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_parameter_list := wf_parameter_list_t();

  wf_event.AddParameterToList(
    p_name => 'ECX_MAP_CODE',
    p_value => 'LOCSERV_IN',
    p_parameterlist => l_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'ADAPTER_ID',
    p_value => l_adapter_id,
    p_parameterlist => l_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'OVERWRITE_THRESHOLD',
    p_value => l_overwrite_threshold,
    p_parameterlist => l_parameter_list);

  wf_event.AddParameterToList(
    p_name => 'BATCH_SEQUENCE',
    p_value => l_batch_sequence,
    p_parameterlist => l_parameter_list);

  -- raise event to retrieve inbound xml doc, which is indoc_rule
  l_event_key := 'HZ_LOCSERVICE_INBOUND-'||hz_utility_v2pub.request_id||'-'||l_adapter_id||'-'||to_char(sysdate,'DD-MON-YYYY HH:MI:SS') ;

  wf_event.raise(
    p_event_name => 'oracle.apps.ar.hz.locservice.parsexml',
    p_event_key  => l_event_key,
    p_event_data => l_event_data,
    p_parameters => l_parameter_list,
    p_send_date  => NULL);

  l_parameter_list.DELETE;

  RETURN 'SUCCESS';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Expected Error: Aborting Location Service for this batch');
    Wf_Core.Context('ECX_RULE', 'GENERATEXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Unexpected Error: Aborting Location Service for this batch');
    Wf_Core.Context('ECX_RULE', 'GENERATEXML', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    log('Others Error: Aborting Location Service for this batch');
    log('SQL Error: '||SQLERRM);
    Wf_Core.Context('ECX_RULE', 'GENERATEXML', p_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_event, 'ERROR');
    --return 'ERROR';
    RAISE;
END outdoc_rule;

END HZ_LOCATION_SERVICES_PUB;

/
