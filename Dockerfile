FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.3.0@sha256:904fe94f236d36d65aeb5a2462f88f2c537b8360475f6342e7599194f291fb7e AS xx

FROM --platform=$BUILDPLATFORM golang:1.21.3-alpine3.18@sha256:96a8a701943e7eabd81ebd0963540ad660e29c3b2dc7fb9d7e06af34409e9ba6 AS builder

COPY --from=xx / /

RUN apk add --update --no-cache ca-certificates make git curl clang lld

ARG TARGETPLATFORM

RUN xx-apk --update --no-cache add musl-dev gcc

RUN xx-go --wrap

WORKDIR /usr/local/src/vault-env

ARG GOPROXY

ENV CGO_ENABLED=0

COPY go.* ./
RUN go mod download

COPY . .

RUN go build -o /usr/local/bin/vault-env .
RUN xx-verify /usr/local/bin/vault-env


FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

RUN apk add --update --no-cache ca-certificates tzdata

COPY --from=builder /usr/local/bin/vault-env /usr/local/bin/vault-env

USER 65534
