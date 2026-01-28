export function withRedirectParam(viewUrl) {
    if (viewUrl.includes("redirect=1")) return viewUrl;
    return viewUrl.includes("?") ? `${viewUrl}&redirect=1` : `${viewUrl}?redirect=1`;
}
