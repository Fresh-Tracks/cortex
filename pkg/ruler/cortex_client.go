package ruler

import (
	"context"
	"net/http"
	"net/url"

	"github.com/prometheus/client_golang/api"
	"github.com/weaveworks/common/user"
)

// NewClient creates a new client to be used for interacting with a Cortex instance
// via the prometheus client api
func NewClient(cfg api.Config) (api.Client, error) {
	c, err := api.NewClient(cfg)
	if err != nil {
		return nil, err
	}
	return &httpClient{c: c}, nil
}

type httpClient struct {
	c api.Client
}

func (c *httpClient) URL(ep string, args map[string]string) *url.URL {
	return c.c.URL(ep, args)
}

func (c *httpClient) Do(ctx context.Context, req *http.Request) (*http.Response, []byte, error) {
	err := user.InjectOrgIDIntoHTTPRequest(ctx, req)
	if err != nil {
		return nil, nil, err
	}
	return c.c.Do(ctx, req)
}
