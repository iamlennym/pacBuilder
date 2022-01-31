
function FindProxyForURL(url, host) {

	//        ****************************************************************************
	//        This is an example PAC file that should be edited prior to being put to use.
	//        ****************************************************************************
	    
	//        Consider the following:
	//         - Keep production PAC files small. Delete all comments if possible
	//         - Delete any examples or sections that do not fit your needs
	//         - Consolidate bypass criteria into fewer if() statements if possible
	//         - Be sure you are bypassing only traffic that *must* be bypassed
	//         - Be sure to not perform any DNS resolution in the PAC
	//         - Zscaler recommends sending bypassed internet traffic via on-premise proxy compared
	//           to the internet directly

	//        ====== Section I ==== Internal/Specific Destinations ============================== 

	//        Most special use IPv4 addresses (RFC 5735) defined within this regex.
	var privateIP = /^(0|10|127|192\.168|172\.1[6789]|172\.2[0-9]|172\.3[01]|169\.254|192\.88\.99)\.[0-9.]+$/;
	var resolved_ip = dnsResolve(host);

	/* Don't send non-FQDN or private IP auths to us */
	if (isInNet(resolved_ip, "192.0.2.0","255.255.255.0") || privateIP.test(resolved_ip))
	      return "DIRECT";

	// IP Range exclusions
	// XXX_IP_RANGE_EXCLUSIONS_XXX

	// Individual IP exclusions
	// XXX_INDIVIDUAL_IP_EXCLUSIONS_XXX

    
	//      Specific destinations can be bypassed here.
	//	Also bypass plain host names (without domain).
	//	Also possible to match direct host and domain like this : (host == "host.example.com") ||
	// XXX_DOMAIN_HOST_EXCLUSIONS_XXX
    
	//        If you have a website that is hosted both internally and externally,
	//        and you want to bypass proxy for internal version only, use the following

	//        if (shExpMatch(host, "internal.example.com"))
	//        {
	//                var resolved_ip = dnsResolve(host);
	//                if (privateIP.test(resolved_ip))
	//                        return "DIRECT";
	//        }

	//        ====== Section II ==== Special Bypasses for SAML============================== 
	//        if (shExpMatch(host, "*.okta.com") || shExpMatch(host, "*.oktacdn.com"))
	//                return "DIRECT";
	    
	//        if (shExpMatch(host, "my_iwa_server.my_example_domain.com"))
	//                return "DIRECT";

	//        ====== Section III ==== Bypasses for other protocols ============================
	//        Send everything other than HTTP and HTTPS direct
	//        Uncomment middle line if FTP over HTTP is enabled

	if ((url.substring(0,5) != "http:") &&
	//                (url.substring(0,4) != "ftp:") &&
	      (url.substring(0,6) != "https:"))
	      return "DIRECT";

	//        ====== Section IV ==== Bypasses for Zscaler ===================================
	//        Go direct for queries about Zscaler infrastructure status 
	var trust = /^(trust|ips).(zscaler|zscalerone|zscalertwo|zscalerthree|zsdemo|zscalergov|zscloud|zsfalcon|zdxcloud|zdxpreview|zdxbeta|zspreview|zsdevel|zsbetagov|zscalerten|zdxten).(com|net)$/;
	if (trust.test(host)) 
	      return "DIRECT";

	//        ====== Section V ==== Bypasses for ZPA ===================================
	/* test with ZPA*/
	if (isInNet(resolved_ip, "100.64.0.0","255.255.0.0"))
	      return "DIRECT";

	//        ====== Section VI ==== DEFAULT FORWARDING ================================ 

	//        If your company has purchased dedicated port, kindly use that in this file.
	//        Port 9400 is the default port followed by 80. If that does not resolve, we send directly:

	return "PROXY ${GATEWAY}:9400; PROXY ${SECONDARY_GATEWAY}:9400; PROXY ${GATEWAY}:80; PROXY ${SECONDARY_GATEWAY}:80; DIRECT";
}