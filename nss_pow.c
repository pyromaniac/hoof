#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <nss.h>
#include <resolv.h>
#include <arpa/inet.h>
#include <dirent.h>

int _fill_hostent (const char *name, int af, struct hostent *result)
{
  result->h_name = malloc((strlen(name) + 1) * sizeof(char));
  strcpy(result->h_name, name);

  result->h_aliases = malloc(sizeof(char *));
  *result->h_aliases = NULL;

  switch (af)
  {
  case AF_INET:
    result->h_addrtype = AF_INET;
    result->h_length = INADDRSZ;
    break;
  case AF_INET6:
    result->h_addrtype = AF_INET6;
    result->h_length = IN6ADDRSZ;
  }

  result->h_addr_list = malloc(sizeof(char *) * 2);
  *result->h_addr_list = malloc(sizeof(in_addr_t));
  in_addr_t addr = inet_addr("127.0.0.1");
  memcpy(*result->h_addr_list, &addr, sizeof(in_addr_t));
  *(result->h_addr_list + 1) = NULL;

  return 0;
}

enum nss_status
_nss_pow_gethostbyname2_r (const char *name, int af, struct hostent *result,
              char *buffer, size_t buflen, int *errnop,
              int *h_errnop)
{
  enum nss_status status = NSS_STATUS_NOTFOUND;

  char *home = getenv("HOME");
  char *home_cpy = malloc((strlen(home) + 6) * sizeof(char));
  strcpy(home_cpy, home);
  DIR *hosts_dir = opendir(strcat(home_cpy, "/.pow"));
  if (hosts_dir != NULL) {
    char *name_cpy = malloc((strlen(name) + 1) * sizeof(char));
    strcpy(name_cpy, name);

    char *pointer = strtok(name_cpy, ".");
    char *domain;
    char *zone;
    if (pointer != NULL) {
      domain = pointer;
      zone = pointer;
    }
    while (pointer != NULL)
    {
      pointer = strtok(NULL, ".");
      if (pointer != NULL) {
        domain = zone;
        zone = pointer;
      }
    }

    if (strcmp(zone, "dev") == 0) {
      struct dirent *entry;
      while ((entry = readdir(hosts_dir)) != NULL) {
        if (entry->d_type == DT_LNK && strcmp(domain, entry->d_name) == 0) {
          _fill_hostent(name, af, result);
          status = NSS_STATUS_SUCCESS;
        }
      }
    }

    closedir(hosts_dir);
  }

  return status;
}

enum nss_status
_nss_pow_gethostbyname_r (const char *name, struct hostent *result,
              char *buffer, size_t buflen, int *errnop,
              int *h_errnop)
{
  return _nss_pow_gethostbyname2_r(name, AF_INET, result, buffer, buflen, errnop, h_errnop);
}
